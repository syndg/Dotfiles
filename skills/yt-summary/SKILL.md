---
name: yt-summary
description: >
  Extract YouTube video transcriptions and generate summaries at multiple detail levels.
  Auto-trigger on YouTube URLs (youtube.com, youtu.be) in conversation when user wants
  content extracted, summarized, or transcribed. Also trigger on: "summarize this video",
  "get transcript", "transcribe this", "what does this video say", "what's this video about",
  or any request involving YouTube video content extraction or summarization.
  Manually invokable via /yt-summary. Saves transcripts as Obsidian-compatible markdown
  to ~/Knowledge/Life/Transcriptions organized by topic.
---

# YouTube Transcript Extraction & Summarization

## Prerequisites

- `yt-dlp` installed via brew (`brew install yt-dlp`)
- Chrome browser (cookies extracted automatically via `--cookies-from-browser chrome`)

## Workflow

### 1. Extract Transcript

```bash
python3 ~/.claude/skills/yt-summary/scripts/extract_transcript.py "<URL>" --topic "<Topic>"
```

Args:
- `--topic` — subfolder in `~/Knowledge/Life/Transcriptions/<Topic>/`. Infer from content if not specified.
- `--no-timestamps` — omit timestamps from saved transcript
- Script prints plain text to stdout; saved `.md` includes timestamps + YAML frontmatter

### 2. Summarize

Read the stdout output from the script. Summarize at the requested level (default: `standard`).

**brief** — 3-5 bullet points, one sentence each, core ideas only.

**standard** — Structured with H3 topic headers, 2-3 sentences per topic, key takeaways at end.

**detailed** — Comprehensive: all major/minor points, impactful quotes, timestamped references
formatted as clickable links `[MM:SS](<url>&t=<seconds>)`, core thesis + arguments + examples,
actionable takeaways section.

### 3. Save Summary

Append summary under `## Summary` in the saved transcript file using Edit tool.

## Topic Inference

When unspecified, infer topic from content:
- Programming/coding -> "Software Engineering"
- AI/ML/agents -> "AI"
- Business/startups -> "Business"
- Design/UX -> "Design"
- Productivity/tools -> "Productivity"
- Other -> best judgment, keep broad

## Output Structure

```
~/Knowledge/Life/Transcriptions/
└── <Topic>/
    └── <video-slug>.md    # frontmatter + transcript + summary
```
