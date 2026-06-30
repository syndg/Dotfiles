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
+ index from the manifest), `quiz.js` (interactive checks), `shiki.js` (syntax highlighting), and
`viz.js` (optional interactive widgets, included only by pages that use one). No framework, no build;
works on `file://`. A JS manifest (not JSON) is used so it loads via `<script src>` without a server.
Workspaces using the kit should include `shiki` in `package.json` (`package.template.json` ships this).

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
- Code highlighting is Shiki-powered via `assets/shiki.js`; raw blocks should be authored as `<pre><code data-lang="ts">…</code></pre>`. The Shiki theme maps keywords, strings, literals, types, comments, and invalid/error scopes into the same restrained palette (`--kw`, `--str`, `--accent`, `--typ`, `--faint`, `--bad`).

## Typography

Native system sans; mono for code (a first-class artifact). Fixed rem scale (no fluid `clamp()`):
h1 ~33/680, h2 ~22/660, lead ~18.5, body ~16.5. Prose capped ~74–76ch; code may run wider.

## Layout

`.app` = 264px rail + fluid reading column (`.col`, max 1000px). Rail (built by `nav.js`): brand →
**page list (scrolls)** → hairline → "On this page" TOC → progress (or Print). The page list is the
only part that scrolls (`.railnav`); brand above and TOC/progress below stay pinned, so they never
leave the viewport however many lessons accumulate.

## Responsive — mobile-first

**Design and verify the phone first, then enhance up.** A lesson is re-read on a phone as often as a
laptop; if it only looks good at 1000px it is not done. The non-negotiables:

- **No page-level horizontal scroll, ever.** Wide things (tabular diagrams, long signatures) shrink
  and wrap to fit, or scroll *inside their own container* — never the page.
- **Diagrams must degrade, not just shrink.** Every diagram needs a defined small-screen form:
  multi-column flows stack (`.flow-track`→1fr), the stacking table shrinks its columns + wraps
  (`.srow`), summary/type lines wrap instead of truncating, oversized display code scales down.
- **Tighten, don't just reflow.** Desktop padding (22–24px) is too generous on a phone; the phone tier
  pulls it to ~14–16px so the reading measure stays full. Display type scales down a step.
- **Touch + reachability.** Tap targets ≥40px; the nav is a thumb-reachable drawer, not a top strip.

Breakpoints (all in `base.css`): **≤900px** the rail becomes a left off-canvas **drawer** (shadcn
Sheet style) behind a hamburger in a slim top bar, over a scrim (Esc / scrim / link / resize close it);
**≤680px** compare + multi-column diagrams collapse to one column and code wraps; **≤560px** the phone
tier tightens padding, scales display type, and makes wide tabular diagrams fit. Verify a new lesson at
~375–500px **before** publishing — the kit was built laptop-first once and it showed.

## Components

Reach by role; never invent a new box style. Diagrams (one per concept, must carry real information),
callouts distinct by role (`.rule` amber law / `.pitfall` red trap / `.good` green safe-rule),
`.compare` ✗/✓ pairs, `.codecard`, `.tbl`, `.quiz[data-ok][data-no]`, `a.next` / `.next.soon`, index
`.row`s, and interactive widgets (the `.viz` frame + `viz.js`, e.g. a reduced-motion-safe stepper).
See `DESIGN_SYSTEM.md` for the full list and `styleguide.html` for renders.

**Interactive visualizations.** Light, reusable widgets (steppers, timelines, toggles) live in the
kit and mount by `data-viz` like `quiz.js`. Bespoke or canvas/SVG visualizations are per-lesson JS
that the lesson includes; they read design tokens via `getComputedStyle` so they match the theme, and
honor `prefers-reduced-motion` (render a final static state, no autoplay). Anything app-grade (needs a
server, sockets, or a build) graduates to the lab lane and is embedded back via `<iframe>`.

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
6. **Verify at phone width (~375–500px) first** — open the drawer, confirm no horizontal page
   scroll, and that every diagram fits or scrolls within itself. Then check the laptop view.
7. Open locally, then publish the tree.
