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

The `learn.syndg.dev` / `*.lab.syndg.dev` publishing infrastructure currently lives on SynDG's VPS, where `~/syndg-labs`, `~/bin/labctl`, and the Cloudflare Tunnel are available. SynDG's laptop may have this skill via Dotfiles, but it should not be assumed to have the publishing root, tunnel, or `labctl`.

Before publishing, check for the publishing host by verifying the relevant paths/processes, for example:

```bash
test -d ~/syndg-labs/static && test -x ~/bin/labctl
pgrep -af cloudflared || true
```

If the infra is missing:

- Do **not** pretend the lesson was published.
- Still create the durable local lesson/reference/learning-record artifacts.
- Report that publishing requires the VPS/publishing host, or ask SynDG whether to SSH/sync to the VPS if that route is available.
- Do not surface `localhost` as a substitute for `learn.syndg.dev`.

## Static Lesson Lane

Current SynDG implementation uses the existing Cloudflare Tunnel + static root:

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

1. Copy the lesson HTML into `~/syndg-labs/static/<topic-slug>/`.
2. Copy reusable reference docs into `~/syndg-labs/static/<topic-slug>/reference/`.
3. Update `~/syndg-labs/static/<topic-slug>/index.html` with the new lesson/reference links.
4. Parse/check the local HTML files.
5. Verify public URLs with `curl -L --fail` and, for lesson pages, browser-load the final `https://learn.syndg.dev/...` URL before reporting it.

Good targets:

- local static server behind Cloudflare Tunnel for quick setup
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
