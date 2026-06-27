# Lesson Frontend — Design Reference

How to build lessons that look and navigate well: a single polished page, or a whole navigable
**lesson site** (index + left nav + cross-lesson navigation). Vanilla **HTML/CSS/JS only — no
framework, no build step**. Pages must work opened as `file://` and when published.

This is a *house reference*, not a mandate to over-build. A one-off lesson can be a single
self-contained HTML file. Reach for the shared-asset site once a workspace has several lessons and
the duplication starts to hurt.

## Two delivery modes

**A. Self-contained single file** — one `.html` with inline `<style>` and `<script>`. Simplest,
maximally portable. Good for the first one or two lessons, or a standalone reference. Cost: styles +
nav are copied per file, so a growing set accrues a duplication tax.

**B. Shared-asset lesson site** — when the set grows, extract to siblings so adding a lesson is one
entry, not an edit to every page:

```
workspace/<track>/
  index.html                 # landing: hero + auto-rendered lesson list
  assets/
    site.css                 # the whole stylesheet (single source of truth for the look)
    manifest.js              # window.SITE = { lessons:[...], reference:[...] }  ← the only file you edit to add a lesson
    nav.js                   # builds rail + on-this-page TOC + scroll-spy + progress + index, from the manifest
    quiz.js                  # wires interactive checks generically (reads data-* for feedback)
  lessons/NNNN-slug.html     # content only: links assets, leaves the rail empty for nav.js to fill
  reference/*.html
```

Each page is content-only: `<link rel="stylesheet" href="../assets/site.css">`, an empty
`<aside class="rail" data-rail data-root="../">`, the content, then the three `<script>`s.

**Why a JS manifest, not JSON:** `fetch()` is blocked on `file://` in Chrome. Load the manifest as a
`<script src>` that sets a global — that works everywhere with no server.

## The docs-app shell (the navigable pattern)

What makes a lesson set feel like a product, not a pile of pages:

- **Persistent left rail:** the course nav (every lesson + reference, current one marked
  `aria-current="page"` by filename), an **"On this page" TOC with scroll-spy**, and a **progress**
  indicator. On mobile it collapses to a sticky top bar.
- **Reading column:** focused max-width (~1000px), prose capped ~74ch, code/diagrams may run wider.
- **Index landing:** a short hero + a list of lessons (number, title, one-line), rendered from the
  manifest so it never goes stale.
- **Cross-lesson nav:** a "Next" card at the foot of each lesson.

`nav.js` derives all of this from the manifest + the page's own `<section id data-toc="...">`
elements. Adding a lesson = append one manifest entry; every page's nav, the index, and progress
update automatically.

### Minimal nav.js shape (sketch)

```js
(function () {
  var S = window.SITE, rail = document.querySelector("[data-rail]");
  var root = rail ? rail.getAttribute("data-root") || "" : "";
  var here = location.pathname.split("/").pop();
  // 1. nav: for each manifest item -> <a href=root+file> mark active if basename(file)===here
  // 2. TOC: for each <main section[id]> -> <a href=#id> label = data-toc || h2 text; IntersectionObserver toggles .active
  // 3. progress: index of current file in lessons -> "n / total" + bar width
  // 4. index pages: fill [data-list] containers with rows from the manifest
})();
```

Keep it boring DOM construction (`createElement`, `textContent` for anything user-authored so `&`
etc. stay safe). No dependencies.

## Visual design principles (product register)

Lessons are tools re-read while working, so the design *serves* the content (see the impeccable
`product.md` register). Distinctiveness matters less than trust and legibility; consistency screen to
screen is a virtue.

- **Theme by scene, not reflex.** Write one sentence about who reads this, where, in what light; let
  it force dark or light. Don't pick dark "because code."
- **Color:** OKLCH, tinted neutrals (never `#000`/`#fff`), **one accent**. If the subject has a
  natural semantic axis (e.g. success/error/needs, pass/fail, before/after), assign it **meaning
  colors** and carry them everywhere — color as information, not decoration.
- **Type:** system sans is legitimate; mono for code. Fixed rem scale with real weight/size contrast.
- **Components, distinct by role:** a "rule/law" callout must not look like a "pitfall" must not look
  like a wrong/right pair. Recessed code wells. One diagram per lesson that carries *real
  information* about the mechanism, not a decorative box.
- **Motion:** 150–200ms on interactive state only; honor `prefers-reduced-motion`.
- **A11y:** WCAG AA, visible `:focus-visible`, `aria-live` on quiz feedback, no page-level horizontal
  overflow, code wraps on mobile.
- **Reference pages** should carry a print path (`@media print` to a light one-pager) so they PDF
  cleanly — these are the pages a learner keeps.

## Anti-patterns (hard no)

Decorative gradients, glassmorphism/backdrop-blur as default, card-grid soup (every block the same
rounded box), thick colored side-stripe borders, gradient text, hero-metric SaaS templates. If a page
could be captioned "AI made a generic dev-docs page," rework it.

## Workspace lock-in

A workspace may **lock its own** system: a `DESIGN.md` (spec) and/or a `lessons/_TEMPLATE.html`
(scaffold whose shared assets are the source of truth). If either exists, it is **binding** — build
new lessons from it rather than restyling ad hoc. `effect-deep-dive` is the reference implementation
of this whole pattern (dark docs-app shell, amber accent, A=green/E=red/R=amber meaning colors,
manifest-driven rail + index).
