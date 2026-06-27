# Lesson Kit — Token & Component Reference

The catalog (the *what*). For the *why/how* see `DESIGN.md`; for the rendered version open
`styleguide.html`. All values live in `base.css` — edit there, never inline.

## Color tokens

OKLCH; hue 264 (blue-violet) neutrals, hue 79 (amber) accent. Never `#000` / `#fff`.

### Surfaces & lines

| Token | Value | Role |
|---|---|---|
| `--bg` | `oklch(0.160 0.013 264)` | page / reading surface |
| `--bg-rail` | `oklch(0.186 0.014 264)` | left rail (second neutral layer) |
| `--bg-2` | `oklch(0.205 0.014 264)` | raised panels |
| `--bg-code` | `oklch(0.135 0.012 264)` | recessed code wells |
| `--line` | `oklch(0.320 0.020 264)` | borders |
| `--line-soft` | `oklch(0.255 0.016 264)` | hairline separators |

### Text

| Token | Value | Role |
|---|---|---|
| `--ink` | `oklch(0.965 0.006 264)` | primary text |
| `--muted` | `oklch(0.765 0.020 264)` | body / secondary |
| `--faint` | `oklch(0.605 0.022 264)` | meta, labels, mono captions |

### Accent & semantic

| Token | Value | Role | Helper |
|---|---|---|---|
| `--accent` | `oklch(0.835 0.130 79)` | links, active nav, focus, highlights | `.t-r` |
| `--accent-lo` | amber / 0.13 | active-nav bg, selection | |
| `--on-accent` | `oklch(0.205 0.030 79)` | text on amber | |
| `--ok` | `oklch(0.800 0.150 152)` | success / "right" / first semantic | `.t-a`, `.pane.good`, `.callout.good` |
| `--bad` | `oklch(0.725 0.165 25)` | error / "wrong" / second semantic | `.t-e`, `.pane.bad`, `.callout.pitfall` |

`.t-a` / `.t-e` / `.t-r` are three semantic-accent slots; map a subject's natural axis onto them and
use consistently everywhere.

### Code syntax tokens

| Class | Token | Use |
|---|---|---|
| `.blue` | `--kw` `oklch(0.800 0.090 300)` | keywords |
| `.green` | `--str` `oklch(0.830 0.120 150)` | strings |
| `.yellow` | `--accent` | literals / numbers |
| `.purple` | `--typ` `oklch(0.800 0.100 245)` | types |
| `.com` | `--faint` italic | comments |
| `.red` | `--bad` | error tokens |
| `.white` | `--ink` | plain identifiers |

## Typography

System sans; mono `"SF Mono", ui-monospace, ...`. Fixed rem scale:

| Element | Size / weight | Notes |
|---|---|---|
| `h1` | 33px / 680, `-0.022em` | max ~21ch |
| `.h2 h2` | 22px / 660 | preceded by mono `.k` number |
| `.lead` | 18.5px / muted | max ~68ch |
| body `p` | 16.5px / 1.66 / muted | max ~76ch |
| code / `pre` | 13.5px mono | recessed wells |
| labels / caps | 11–12px mono, uppercase, tracked | `--faint` |

## Spacing & radii

`.col` max 1000px, padding `62px 64px 100px` (mobile `36/24`, `30/18`). Section rhythm `46px` top.
Radii 11–14px (cards/diagrams), 5–9px (chips/buttons), 99px (bars). Borders 1px; no thick side-stripes.

## Component library

| Component | Class(es) | Purpose |
|---|---|---|
| Eyebrow | `.eyebrow` + `.num` | lesson number chip + label |
| Section head | `.h2` + `.k` + `h2` | mono number + heading |
| Rule callout | `.callout.rule` | the law (amber) |
| Pitfall callout | `.callout.pitfall` | the trap (red) |
| Good callout | `.callout.good` | the safe rule (green) |
| Wrong/right | `.compare` + `.pane.bad` / `.pane.good` | ✗/✓ paired code |
| Code card | `.codecard` + `.cap` | labeled standalone code |
| Table | `.tbl` + `td.key.a\|e\|r` | reference rows |
| Quiz | `.quiz[data-ok][data-no]` + `.opts button[data-answer]` | interactive check |
| Next | `a.next` / `.next.soon` | next link / unbuilt teaser |
| Index row | `.list` + `.row` (+`.ref`) | landing rows |
| Diagram examples | `.contract` / `.decode` / `.flow` / `.stack` | worked mechanistic diagrams (reference instance); build new ones per topic in the same language |

## Rules

One accent; semantic colors mean what they mean everywhere; callouts distinct by role; every diagram
carries real information; AA contrast, focus-visible, reduced-motion, no horizontal overflow. Bans:
decorative gradients, glassmorphism, card-grid soup, side-stripe borders, gradient text.
