---
name: react-doctor
description: Use when finishing a feature, fixing a bug, before committing React code, or when the user types `/doctor`, asks to scan, triage, or clean up React diagnostics. Covers lint, accessibility, bundle size, architecture. Includes a regression check and a full local-triage workflow that fetches the canonical playbook.
version: "1.1.0"
---

# React Doctor

Scans React codebases for security, performance, correctness, and architecture issues. Outputs a 0–100 health score.

## After making React code changes:

Run `npx react-doctor@latest --verbose --diff` (or `npx react-doctor@latest --verbose --scope changed` when the CLI warns that `--diff` is deprecated) and check the score did not regress.

If the score dropped, fix direct regressions before committing. Do not blindly chase broad warnings that merely reflect existing architecture or accepted local style (e.g. already-large components, many-related-`useState` component shape, known route redirects) unless they are introduced by the current change or cheap/safe to repair. Fix small, clear issues immediately — especially accessibility wiring like labels/controls, clickable static elements that should be real buttons, straightforward Next `<Image>` conversions plus host config, local hook/state cleanups, and whitespace/newline hygiene — then rerun lint/typecheck/doctor.

For scoped feature cleanup, use the triage boundary in `references/scoped-feature-triage.md`: fix local low-risk correctness/accessibility/performance warnings, but explicitly defer giant-component or broad architecture warnings that would muddy the feature diff.

For virtualized React lists, especially TanStack Virtual, use `references/tanstack-virtual-react-compiler.md`: React Compiler may emit non-fatal ref/memoization warnings even when lint exits 0. Fix real errors in your own code, but do not churn a correct virtualizer just to silence a compiler optimization warning; validate with tests, lint, typecheck, build, and changed-file doctor.

## For general cleanup or code improvement:

Run `npx react-doctor@latest --verbose` (without `--diff`) to scan the full codebase. Fix issues by severity — errors first, then warnings.

## /doctor — full local triage workflow

When the user types `/doctor`, says "run react doctor", or asks for a full triage / cleanup pass (not just a regression check), fetch the canonical local-triage playbook and follow every step in it:

```bash
curl --fail --silent --show-error \
  --header 'Cache-Control: no-cache' \
  https://www.react.doctor/prompts/react-doctor-agent.md
```

The playbook is the single source of truth — a scan → filter → triage → fix → validate loop that edits the working tree directly (never commits, never opens PRs). Updating the prompt at its source updates every agent on its next fetch — no skill reinstall needed.

Pair it with the matching per-rule prompts at `https://www.react.doctor/prompts/rules/<plugin>/<rule>.md` (fetched on demand inside the playbook) so each fix uses the canonical, reviewer-tested recipe.

## Command

```bash
npx react-doctor@latest --verbose --diff
```

| Flag        | Purpose                                       |
| ----------- | --------------------------------------------- |
| `.`         | Scan current directory                        |
| `--verbose` | Show affected files and line numbers per rule |
| `--diff`    | Only scan changed files vs base branch        |
| `--score`   | Output only the numeric score                 |
