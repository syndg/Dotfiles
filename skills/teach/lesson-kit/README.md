# Lesson Kit

The default frontend for teaching workspaces: a dark, product-register **docs-app** for lessons —
persistent left nav, scroll-spy table of contents, progress, an index landing, role-distinct
components, interactive checks, and Shiki-powered syntax highlighting. Vanilla **HTML/CSS/JS**, no framework, no build step. Works on
`file://` and when published. Shiki is a required dependency for workspaces that use the kit (`npm install shiki` or copy `package.template.json`).

Use this for any topic. `effect-deep-dive` is the reference instance it was extracted from.

## Files

| File | Role |
|---|---|
| `base.css` | The whole stylesheet — tokens + every component. Single source of truth for the look. |
| `nav.js` | Builds the left rail, scroll-spy TOC, progress / print button, and index rows from the manifest. Reads `window.LESSONS`. |
| `quiz.js` | Wires every `.quiz` (reads `data-ok` / `data-no`). |
| `shiki.js` | Loads Shiki and highlights every `<pre><code data-lang="ts">…</code></pre>` using the kit theme. |
| `package.template.json` | Minimal npm dependency declaration for `shiki`. |
| `manifest.template.js` | The lesson set. **The only file you edit to add a lesson.** |
| `lesson.template.html` | Content-only lesson scaffold. |
| `index.template.html` | Landing page; renders lesson/reference rows from the manifest. |
| `styleguide.html` | Living component gallery (open it to see every token + component). |
| `DESIGN.md` · `DESIGN_SYSTEM.md` | The spec (why/how) and the token+component catalog (what). |

## Set up a new workspace

```
<workspace>/
  index.html                 # from index.template.html
  assets/
    base.css  nav.js  quiz.js  shiki.js   # copied from this kit
    manifest.js                         # from manifest.template.js, filled in
  package.json                  # from package.template.json, then npm install
  lessons/NNNN-slug.html     # from lesson.template.html
  reference/*.html           # optional
```

1. `mkdir -p <workspace>/assets <workspace>/lessons` and copy `base.css`, `nav.js`, `quiz.js`, and `shiki.js` into
   `assets/`. Copy `package.template.json` to `package.json`, then run `npm install` so `shiki` is explicit in the workspace dependency graph.
2. Copy `manifest.template.js` to `assets/manifest.js`; set `brand` and add one entry per lesson.
3. Copy `index.template.html` to `index.html`; fill the hero.
4. Copy `lesson.template.html` to `lessons/0001-slug.html`; fill it. **Adding a lesson later is one
   manifest entry plus the new file** — no edits to other pages.
5. **Check it on a phone before you ship.** The kit is mobile-first: design and verify at ~375–500px
   first (open the drawer, confirm no horizontal page scroll, every diagram fits or scrolls within
   itself), then enhance up to the laptop view. See `DESIGN.md` › Responsive.
6. (Optional) copy `styleguide.html` for an in-workspace component reference.

## Theming per topic

The kit ships a dark theme with an amber accent and green/red semantic colors. To give a topic its
own identity without forking the system, override tokens in a small `:root` block (a `theme.css`
linked after `base.css`, or an inline `<style>` in `index.html`/lessons):

```css
:root{
  --accent: oklch(0.78 0.14 250);   /* a different accent hue */
  /* --ok / --bad keep their universal success/error meaning */
}
```

Keep the structure and component vocabulary; change hue, not mechanics. If a subject has a natural
semantic axis (pass/fail, before/after, three roles), map it to `--ok` / `--bad` / `--accent` and the
`.t-a` / `.t-e` / `.t-r` helpers, and carry it everywhere — color as information.

## Diagrams

`base.css` includes worked diagram components from the reference instance (`.contract`, `.decode`,
`.flow`, `.stack`) — keep them as examples or build a new mechanistic diagram per concept in the same
language. A decorative box with letters is not a diagram.

## Interactive widgets

For dynamic, interactive visualizations, include `viz.js` on the page and mark up a `.viz` figure.
The kit ships a generic **stepper** (`data-viz="stepper"`): a step-through with play / step / reset
controls, reduced-motion-safe, keyboard-operable.

```html
<figure class="viz" data-viz="stepper" aria-label="...">
  <div class="viz-cap">caption</div>
  <div class="viz-stage">
    <div class="viz-step" data-note="explanation (may be HTML)">step content</div>
    <div class="viz-step" data-note="...">...</div>
  </div>
  <div class="viz-controls"></div>
  <div class="viz-note" aria-live="polite"></div>
</figure>
<script src="../assets/viz.js"></script>
```

Bespoke / canvas / SVG visualizations are per-lesson JS that the lesson includes. Read tokens via
`getComputedStyle(document.documentElement).getPropertyValue('--accent')` so the drawing matches the
theme; honor `prefers-reduced-motion` (render a final static state); give it keyboard controls and a
static fallback. Anything app-grade (server, sockets, build, framework) belongs in the lab lane,
embedded back into the lesson via `<iframe>`. See `styleguide.html` for the stepper rendered.

## Publish

Publish the whole tree (`index.html`, `assets/`, `lessons/`, `reference/`) together; the pages depend
on the `assets/` siblings. For SynDG, use `labctl publish-static <slug> <site-dir>` (see the teach
publishing reference).

**Cache-busting.** Asset URLs carry a version query (`base.css?v=1`, `nav.js?v=1`, …). When you change
`base.css` or any shared script, **bump the number in every page** that links it (one find/replace,
e.g. `?v=1` → `?v=2`). Behind a CDN the HTML is still cached, so a content deploy needs the cache
purged regardless; the version query guarantees that once the HTML refreshes, the new CSS/JS load
immediately instead of serving a stale cached asset against fresh HTML.

## Locking a workspace

A workspace may copy `DESIGN.md` + a filled template to lock its own instance (as `effect-deep-dive`
did). Once locked, that binds for the workspace and supersedes generic guidance.
