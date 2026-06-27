# Lesson Kit — Design Spec

The *why/how* of the kit. Catalog of exact tokens + components is in `DESIGN_SYSTEM.md`; the rendered
view is `styleguide.html`; setup is `README.md`. All values live in `base.css`.

## Register & theme

- **Register:** product. The design serves the content; a lesson is a tool re-read while working, not
  a marketing surface. Consistency screen to screen is a virtue.
- **Theme:** dark by default, justified by the scene of a learner reviewing focused material. A topic
  may re-theme (see README) but should keep the structure.

## Architecture (shared assets, vanilla)

Pages are content-only. Everything shared lives in `assets/`: `base.css` (look), `manifest.js` (the
lesson set — the only file edited to add a lesson), `nav.js` (builds rail + scroll-spy TOC + progress
+ index from the manifest), `quiz.js` (interactive checks). No framework, no build; works on
`file://`. A JS manifest (not JSON) is used so it loads via `<script src>` without a server.

Per-page wiring: `<aside class="rail" data-rail data-root="../" data-kind="lesson|reference">`;
sections as `<section id data-toc="Short label">`; index lists as `<div class="list" data-list="lessons" data-root="">`.

## Color

OKLCH, tinted neutrals (hue 264), never `#000`/`#fff`. **One accent.**

- Surfaces `--bg` / `--bg-rail` / `--bg-2` / `--bg-code`; lines `--line` / `--line-soft`; text
  `--ink` / `--muted` / `--faint`; accent `--accent` (+ `--accent-lo`, `--on-accent`).
- **Semantic colors:** `--ok` (green) and `--bad` (red) carry universal success/error, "right"/"wrong".
  Helpers `.t-a` (ok), `.t-e` (bad), `.t-r` (accent) are three semantic-accent slots — map a subject's
  natural axis onto them and use them **everywhere** that axis appears. Color is information, not
  decoration.
- Code tokens are restrained: `.blue` keyword, `.green` string, `.yellow` literal, `.purple` type,
  `.com` comment, `.red` error.

## Typography

Native system sans; mono for code (a first-class artifact). Fixed rem scale (no fluid `clamp()`):
h1 ~33/680, h2 ~22/660, lead ~18.5, body ~16.5. Prose capped ~74–76ch; code may run wider.

## Layout

`.app` = 264px rail + fluid reading column (`.col`, max 1000px). Rail (built by `nav.js`): brand →
nav groups → hairline → "On this page" TOC → progress (or Print). At ≤900px it becomes a sticky top
bar; ≤680px compare/multi-column diagrams collapse and code wraps.

## Components

Reach by role; never invent a new box style. Diagrams (one per concept, must carry real information),
callouts distinct by role (`.rule` amber law / `.pitfall` red trap / `.good` green safe-rule),
`.compare` ✗/✓ pairs, `.codecard`, `.tbl`, `.quiz[data-ok][data-no]`, `a.next` / `.next.soon`, index
`.row`s. See `DESIGN_SYSTEM.md` for the full list and `styleguide.html` for renders.

## Motion · A11y · Print

150–160ms ease on interactive state only; `prefers-reduced-motion` honored. WCAG AA, `:focus-visible`
ring, `aria-live` quiz feedback, no page-level horizontal overflow. A global `@media print` block
inverts to a light one-pager (rail hidden) so reference pages PDF cleanly.

## Anti-patterns (hard no)

Decorative gradients, glassmorphism, card-grid soup, thick colored side-stripe borders, gradient
text, hero-metric SaaS templates. If a page reads as "generic AI dev-docs," rework it.

## Build a lesson (checklist)

1. Copy `lesson.template.html` to `lessons/NNNN-slug.html`; fill title, eyebrow, h1, lead.
2. **Add one entry to `assets/manifest.js`** — the only place the lesson set is edited.
3. Build the lesson's diagram (reuse a pattern or design a new mechanistic one; keep the semantic
   coloring).
4. Write sections with `id` + `data-toc`; the TOC + scroll-spy generate themselves.
5. Point `.next` at the following lesson (or `.next.soon`).
6. Open locally, then publish the tree.
