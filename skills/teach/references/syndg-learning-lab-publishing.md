# SynDG Learning Lab Publishing

Use this when a teaching session should produce visitable URLs, live demos, or lesson archives for SynDG.

## Preferred URL Shape

SynDG owns `syndg.dev` and manages it in Cloudflare. Prefer two lanes:

- `learn.syndg.dev` — permanent/static lessons, reference docs, printable HTML, course indexes.
- `*.lab.syndg.dev` — live interactive demos/apps spun up for a lesson or exploration.

Examples:

- `https://learn.syndg.dev/typescript-dsa/lessons/0001-arrays.html`
- `https://event-loop.lab.syndg.dev`
- `https://react-reconciliation.lab.syndg.dev`

## Publishing Decision

1. First determine whether you are running on SynDG's VPS/publishing host or on another machine.
2. If the artifact is a plain lesson/reference document, publish statically. Do not keep a live Node server running just to serve static HTML.
3. If the artifact needs interactivity, APIs, WebSockets, hot reload, or a running process, publish it as a lab app.
4. Return the final public URL, not just local file paths or localhost ports.

## Host Awareness

The canonical `learn.syndg.dev` / `*.lab.syndg.dev` infrastructure lives on SynDG's VPS (SSH alias `synclaw`), where `~/syndg-labs`, the VPS-side `labctl`, and the Cloudflare Tunnel run. **Static publishing now also works from the laptop**: a laptop `labctl` (symlinked from Dotfiles `bin/labctl`) pushes static artifacts to the VPS over SSH/rsync — it hosts nothing locally and needs no local tunnel. The laptop still has **no** live-lab infra; interactive lab apps require the VPS.

Before publishing, check what's available:

```bash
command -v labctl                       # static publishing available (laptop pushes to VPS, or you're on the VPS)
test -d ~/syndg-labs/static             # true only when you're actually on the VPS host
pgrep -af cloudflared || true           # the tunnel runs on the VPS
```

- If `labctl` is available → use the static lane below (`labctl publish-static`). It works whether you're on the laptop (SSH/rsync to `synclaw`) or on the VPS.
- If `labctl` is missing or SSH to the VPS fails:
  - Do **not** pretend the lesson was published.
  - Still create the durable local lesson/reference/learning-record artifacts.
  - Report that publishing requires the VPS (or SSH access to it), and surface the local file path.
  - Do not surface `localhost` as a substitute for `learn.syndg.dev`.

## Static Lesson Lane

### Preferred: `labctl publish-static`

Use the `labctl` wrapper instead of hand-running scp/rsync. It works from the laptop (SSH/rsync to `synclaw`) or on the VPS, uploads to `~/syndg-labs/static/<slug>/`, verifies the public URL with `curl -L --fail`, and prints the final `https://learn.syndg.dev/<slug>/...` URL.

```bash
# one lesson file (basename preserved)
labctl publish-static effect-deep-dive ./lessons/0004-something.html

# a whole built topic directory (mirrored into the slug dir with --delete)
labctl publish-static effect-deep-dive ./build/effect-deep-dive/

# re-verify a known file later
labctl verify-static effect-deep-dive 0004-something.html
```

Notes:

- Slugs are conservative (`[a-zA-Z0-9.-]`); `labctl` rejects `..`/traversal.
- A directory publish uses `rsync --delete` scoped to the slug dir — it **mirrors**, so only point it at a dir whose contents should be the entire public set for that slug.
- `labctl` does **not** manage `index.html`; index updates remain this workflow's job (step 3 below).
- Config via env: `LABCTL_VPS_HOST` (default `synclaw`), `LABCTL_REMOTE_STATIC_ROOT`, `LABCTL_PUBLIC_BASE`.

### Layout and index management

The static root (on the VPS) is:

```text
~/syndg-labs/static/
  index.html
  <topic-slug>/
    index.html
    <lesson-file>.html
    reference/
      <reference-file>.html
```

Public URL mapping:

```text
~/syndg-labs/static/<topic-slug>/... -> https://learn.syndg.dev/<topic-slug>/...
```

For a new static lesson:

1. Publish the lesson HTML with `labctl publish-static <topic-slug> <file-or-dir>` (or copy into `~/syndg-labs/static/<topic-slug>/` directly when on the VPS).
2. Publish reusable reference docs under the topic's `reference/` (e.g. publish a directory that already contains a `reference/` subfolder).
3. Update `<topic-slug>/index.html` with the new lesson/reference links — `labctl` leaves index management to you.
4. Parse/check the local HTML files.
5. Verify public URLs with `curl -L --fail` and, for lesson pages, browser-load the final `https://learn.syndg.dev/...` URL before reporting it. (`labctl` already runs a `curl -L --fail` check on publish.)

Good targets:

- Cloudflare Tunnel + static root on the VPS (current)
- Cloudflare Pages later for durable/static hosting

## Live Lab Lane

Suggested workspace:

```text
~/syndg-labs/
  apps/<slug>/
  registry.json
```

A future `labctl`-style wrapper should:

- allocate a port
- run the app command in the background
- update a local reverse-proxy route
- expose `<slug>.lab.syndg.dev`
- verify the public URL before reporting success
- list/stop/cleanup old lab apps

## Cloudflare/VPS Pattern

The VPS can run `cloudflared` plus a local reverse proxy such as Caddy:

```text
*.lab.syndg.dev  -> Cloudflare Tunnel -> local Caddy -> 127.0.0.1:<app-port>
learn.syndg.dev  -> Cloudflare Tunnel -> static file server/Caddy root
```

Cloudflare Tunnel handles public HTTPS, so the local proxy can speak plain HTTP internally.

## Pitfalls

- Do not surface `localhost:<port>` as the deliverable when the user asked for something visitable.
- Do not overuse live servers for static lessons; they are more fragile than static publishing.
- Do not claim a public URL works until it has been checked from the public hostname.
- Keep generated lesson URLs stable enough for later review; avoid random slugs unless the user wants disposable demos.
