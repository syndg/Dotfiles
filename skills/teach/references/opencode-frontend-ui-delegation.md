# OpenCode delegation for teaching frontend UI

Use this whenever a teaching artifact includes frontend UI: standalone lesson HTML, reference pages, live labs, demos, quizzes, or interactive explainers.

## Rule

For SynDG-facing teaching UI, OpenCode originates the visual design. Hermes teaches, coordinates, verifies, and patches objective defects.

Default model:

```bash
$HOME/.bun/bin/bunx opencode-ai@latest run \
  'Read prompt.md and create the requested standalone artifact. Do not inspect or reuse existing project HTML/CSS.' \
  --model opencode-go/glm-5.2 \
  --agent build \
  -f /tmp/<clean-workspace>/prompt.md
```

## Prompt shape

Give OpenCode only:

- audience and learning objective
- required lesson content / teaching meat
- required interactions
- accessibility constraints
- technical constraints: standalone/static, inline CSS/JS if appropriate, no external deps if requested
- anti-references: generic AI lesson pages, glassmorphism, huge hero, repeated card grids, cramped code/diagrams
- exact output path

Do not attach the current lesson HTML/CSS or screenshots unless the user explicitly asks for modification instead of a fresh design.

## Verification after generation

Hermes must verify before publishing:

1. File exists and HTML parses.
2. Copy to canonical project/publish path only after generation completes.
3. Public URL returns HTTP 200 when publishing.
4. Browser renders the exact public URL.
5. No page-level horizontal overflow.
6. Quiz/interaction works after any delayed aria-live updates.
7. Visual QA: hero/footer not oversized, code/table columns not cramped, body text readable.
8. Patch only objective defects or missing requirements. Do not replace OpenCode’s visual direction unless the user asks.

## Known objective defects to watch for

- Comparison tables with a too-narrow label column on desktop; prefer `grid-template-columns:minmax(220px,.72fr) 1fr` or stack on mobile.
- Hidden feedback/status panels that CSS accidentally displays before interaction.
- `aria-live` feedback that updates after a short timeout; verify after a delay, not only immediately after click.
- Mobile code/type signatures forcing page-level overflow; confine scroll to the code block or wrap intentionally.
