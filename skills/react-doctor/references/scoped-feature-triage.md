# Scoped feature triage notes

Use this when React Doctor is run after a feature or bug-fix diff and the goal is to leave the branch healthier without turning the PR into an architecture rewrite.

## Practical classification

1. **Fix immediately** when the warning is local, deterministic, and low-risk:
   - accessibility wiring (`label`/control association, clickable non-interactive elements, missing keyboard semantics)
   - plain `<img>` in Next.js apps when replacing with `next/image` is straightforward
   - image host config required by the local image source
   - whitespace/newline/diff hygiene
   - hook/state issues that can be localized (e.g. moving ID generation out of JSX callback construction, collapsing tightly-coupled state into `useReducer`)
2. **Defer deliberately** when the warning describes existing component shape or broad architecture:
   - giant-component warnings
   - many-related-`useState` warnings that require component splitting/domain refactor
   - route redirect or navigation patterns that are intentional and would need app-level redesign
3. **Validate the boundary** before reporting done:
   - run tests, lint, typecheck/build, `git diff --check`, and React Doctor again
   - report remaining warnings as explicit non-blocking architecture debt, not as unresolved correctness work

## Next.js build footgun

If a route fails prerendering because it uses request-only/dynamic APIs, fix the route's rendering mode (for example, mark it dynamic when appropriate) and rerun the full build. Do not treat a successful TypeScript pass as enough.

## Reporting style

For SynDG, keep the final report tight: what changed, what commands passed, what remains, and why remaining warnings are intentionally out of scope. Avoid long rule-by-rule commentary unless asked.
