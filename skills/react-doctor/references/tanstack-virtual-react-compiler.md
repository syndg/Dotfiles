# TanStack Virtual + React Compiler lint warnings

Use this when a React/Next feature adds `@tanstack/react-virtual` or a similar virtualizer and validation produces React Compiler diagnostics around refs or memoization.

## Pattern observed

A virtualized list can be the right fix for large client-rendered collections: keep the server/query pagination bounded, then render only visible rows with `useVirtualizer`.

React Compiler/ESLint may warn around virtualizer internals or render-time ref wiring, especially messages like:

- `Cannot access refs during render`
- compiler skipped memoization / non-memo-safe virtualizer functions

If `eslint` exits `0`, treat this as a compiler optimization warning, not a failing validation. Still verify runtime correctness with tests, typecheck, build, and a focused smoke check where possible.

## Practical implementation checklist

- Keep filtering/sorting logic in a pure helper that can be unit-tested separately from React rendering.
- For paginated backends, avoid filtering only the first loaded page. If search/filter terms are active and there are more pages, keep prefetching until enough matches are found or pagination is exhausted.
- Use a bounded page size, e.g. 50–100 rows, and virtualize the display layer.
- Do not rewrite a correct TanStack Virtual integration just to silence a non-fatal React Compiler warning. Fix only actual lint errors or warnings introduced by bad ref access in your own component code.
- Report the warning plainly in the final validation summary if it remains non-fatal.

## Verification bundle

For a React/Next feature touching virtualization or paginated lists, prefer:

```bash
bun test
bun run lint
bunx tsc --noEmit
bun run build
npx react-doctor@latest --verbose --scope changed
```

Adjust package manager commands to the repo, but keep the same validation intent: unit behavior, lint, types, production build, and changed-file React doctor scan.