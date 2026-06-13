#!/usr/bin/env python3
"""Capture a YouTube transcript into the wiki's raw/ layer.

Capture-only: downloads + cleans the transcript and writes it to raw/ as an
immutable source. Summarizing, cross-linking, and indexing are the wiki-ingest
skill's job — this script never writes to wiki/ and never produces a summary.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def get_video_info(url: str) -> dict:
    """Get video metadata without downloading."""
    result = subprocess.run(
        ["yt-dlp", "--cookies-from-browser", "chrome", "--skip-download",
         "--print", '{"title":%(title)j,"id":%(id)j,"channel":%(channel)j,"upload_date":%(upload_date)j,"duration":%(duration)j}',
         url],
        capture_output=True, text=True, timeout=60
    )
    if result.returncode != 0:
        print(f"Error getting video info: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout.strip())


def download_subtitles(url: str, tmp_dir: str, video_id: str) -> str:
    """Download subtitles and return path to VTT file."""
    result = subprocess.run(
        ["yt-dlp", "--cookies-from-browser", "chrome",
         "--write-auto-sub", "--write-subs", "--sub-lang", "en-orig,en",
         "--sub-format", "vtt", "--skip-download",
         "-o", f"{tmp_dir}/%(id)s.%(ext)s", url],
        capture_output=True, text=True, timeout=120
    )
    if result.returncode != 0:
        print(f"Error downloading subtitles: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    # Prefer en-orig over en, scoped to this video's ID
    for suffix in [".en-orig.vtt", ".en.vtt"]:
        path = Path(tmp_dir) / f"{video_id}{suffix}"
        if path.exists():
            return str(path)

    print("No English subtitles found.", file=sys.stderr)
    sys.exit(1)


def parse_vtt(vtt_path: str, include_timestamps: bool = True) -> str:
    """Parse VTT file into clean transcript text."""
    with open(vtt_path) as f:
        content = f.read()

    # Remove VTT header
    content = re.sub(r'WEBVTT.*?\n\n', '', content, count=1, flags=re.DOTALL)

    blocks = content.strip().split('\n\n')
    lines_out = []
    seen = set()

    for block in blocks:
        lines = block.strip().split('\n')
        if not lines:
            continue

        timestamp = None
        text_parts = []
        for line in lines:
            ts_match = re.match(r'(\d{2}:\d{2}:\d{2})\.\d{3}\s*-->', line)
            if ts_match:
                timestamp = ts_match.group(1)
                # Strip leading zeros from hours
                timestamp = re.sub(r'^00:', '', timestamp)
                continue
            # Remove VTT tags
            clean = re.sub(r'<[^>]+>', '', line).strip()
            if clean:
                text_parts.append(clean)

        for text in text_parts:
            if text not in seen:
                seen.add(text)
                if include_timestamps and timestamp:
                    lines_out.append(f"[{timestamp}] {text}")
                    timestamp = None  # Only stamp first unseen line per block
                else:
                    lines_out.append(text)

    return '\n'.join(lines_out)


def slugify(text: str) -> str:
    """Convert text to filesystem-safe slug."""
    text = text.lower().strip()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_]+', '-', text)
    text = re.sub(r'-+', '-', text)
    return text[:80].strip('-')


def main():
    parser = argparse.ArgumentParser(description="Capture a YouTube transcript into the wiki's raw/ layer")
    parser.add_argument("url", help="YouTube video URL")
    parser.add_argument("--no-timestamps", action="store_true", help="Exclude timestamps from the transcript")
    parser.add_argument("--raw-dir", default=os.path.expanduser("~/Knowledge/raw"),
                        help="Wiki raw/ directory to write the transcript into")
    parser.add_argument("--tmp-dir", default="/tmp/yt-transcripts", help="Temp directory for VTT files")
    args = parser.parse_args()

    os.makedirs(args.tmp_dir, exist_ok=True)
    raw_dir = Path(args.raw_dir)
    raw_dir.mkdir(parents=True, exist_ok=True)

    print("Fetching video info...", file=sys.stderr)
    info = get_video_info(args.url)

    print(f"Downloading subtitles for: {info['title']}", file=sys.stderr)
    vtt_path = download_subtitles(args.url, args.tmp_dir, info['id'])

    transcript = parse_vtt(vtt_path, not args.no_timestamps)

    slug = slugify(info['title'])
    output_path = raw_dir / f"{slug}.md"

    # Format duration
    duration_s = int(info.get('duration', 0) or 0)
    duration_fmt = f"{duration_s // 3600}h {(duration_s % 3600) // 60}m" if duration_s >= 3600 else f"{duration_s // 60}m {duration_s % 60}s"

    # Format upload date
    upload_raw = info.get('upload_date', '')
    upload_fmt = f"{upload_raw[:4]}-{upload_raw[4:6]}-{upload_raw[6:8]}" if len(upload_raw) == 8 else upload_raw

    md_content = f"""---
type: youtube
title: "{info['title']}"
channel: "{info.get('channel', 'Unknown')}"
date: {upload_fmt}
duration: {duration_fmt}
url: {args.url}
extracted: {datetime.now().strftime('%Y-%m-%d')}
---

# {info['title']}

## Transcript

{transcript}
"""

    output_path.write_text(md_content)

    # Report metadata only — not the transcript body. wiki-ingest reads the file.
    word_count = len(transcript.split())
    print(json.dumps({
        "raw_path": str(output_path),
        "slug": slug,
        "title": info["title"],
        "channel": info.get("channel", "Unknown"),
        "duration": duration_fmt,
        "url": args.url,
        "word_count": word_count,
    }, indent=2))


if __name__ == "__main__":
    main()
