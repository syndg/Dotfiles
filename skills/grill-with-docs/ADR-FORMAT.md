# Architectural Decisions — entry format

Architectural decisions live **inline** in the **Architectural Decisions** section of the
nearest owning `AGENTS.md`. There is no separate `docs/adr/` directory.

## Entry shape

Each decision is one entry under the section. Match the surrounding doc's style — most use a
bold/heading label plus a tight Decision/Consequences pair:

```md
### ADR-0019 — {Short title of the decision}

- **Decision:** {1-2 sentences: what we decided.}
- **Consequences:** {only the non-obvious downstream effects worth calling out.}
```

A thinner doc may use a single bullet:

```md
- **ADR-0019 — {Short title}**: {what we decided and why, in 1-3 sentences.}
```

The value is in recording *that* a decision was made and *why* — not in filling out sections.
Add **Consequences** only when there are non-obvious downstream effects.

## Numbering (global + immutable)

`ADR-NNNN` numbers are **global across the repo** and **immutable** — they are stable
cross-reference anchors, not a per-document sequence.

- Allocate a new ADR the **next unused global number** by scanning `ADR-` labels across the
  whole `AGENTS.md` tree (`grep -rhoE 'ADR-[0-9]{4}' --include=AGENTS.md`), not by scanning a
  single directory.
- Numbers are **non-contiguous within any one `AGENTS.md`** — decisions live next to the code
  they govern, so a given doc holds whatever subset applies to its subtree.
- **Never renumber or re-slug** an existing ADR. If a decision is superseded, keep its number
  and note the superseding ADR (e.g. `superseded by ADR-0024`).
- Cross-reference inherited decisions **by number** from child docs rather than restating them.

## Placement

Put the entry in the **nearest owning `AGENTS.md`** — the one whose subtree the decision
governs. A repo-wide decision goes in the root `AGENTS.md`; an app- or package-scoped one goes
in that app/package `AGENTS.md`; a subtree-specific one goes in the relevant child `AGENTS.md`.
Follow that doc's **Change Protocol**: read the DOX chain first, write the entry, keep the
**Child DOX Index** current.

## When to record an ADR

All three must be true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons.

If a decision is easy to reverse, skip it — you'll just reverse it. If it's not surprising, nobody will wonder why. If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

### What qualifies

- **Architectural shape.** "The write model is event-sourced, the read model is projected into Postgres."
- **Ownership and boundary decisions.** "X is owned by the Y scope; other scopes reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Integration patterns between scopes.** "These two scopes communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target — just the ones that would take a quarter to swap out.
- **Deliberate deviations from the obvious path.** "We use manual SQL instead of an ORM because X." Anything where a reasonable reader would assume the opposite.
- **Constraints not visible in the code.** "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If you considered GraphQL and picked REST for subtle reasons, record it — otherwise someone suggests GraphQL again in six months.
