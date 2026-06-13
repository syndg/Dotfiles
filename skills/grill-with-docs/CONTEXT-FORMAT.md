# Ubiquitous Language — section format

Domain language lives **inline** in the **Ubiquitous Language** section of the nearest owning
`AGENTS.md`. There is no separate `CONTEXT.md` or `CONTEXT-MAP.md`.

## Entry shape

Each term is a canonical name, a tight definition, and the aliases to avoid:

```md
## Ubiquitous Language

**Order**:
A customer's request to purchase one or more items, tracked from placement to fulfillment.
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request
```

A doc may also use a compact table when it manifests many terms from a parent contract:

```md
| Term | Definition | Avoid |
|------|------------|-------|
| **Order** | A customer's request to purchase items. | Purchase, transaction |
```

## Rules

- **Be opinionated.** When multiple words exist for one concept, pick the best and list the rest under `_Avoid_`.
- **Keep definitions tight.** One or two sentences. Define what it IS, not what it does.
- **Only context-specific terms.** General programming concepts (timeouts, error types, utility patterns) don't belong even if used heavily. Ask: is this unique to this domain, or general? Only the former belongs.
- **Group under subheadings** when natural clusters emerge; a flat list is fine if all terms share one cohesive area.

## Scope and inheritance (DOX)

Terms live at the **nearest owning `AGENTS.md`** and are inherited down the tree:

- A term shared across an app/package goes in that app/package `AGENTS.md`.
- A child `AGENTS.md` defines **only** terms its subtree introduces or specially manifests; for
  shared terms it **references the parent** rather than restating the definition.
- If the same word means different things in two subtrees, that is a smell — surface it and pick
  one canonical term, or qualify each (e.g. `Persona (candidate)` vs `Persona (ID-verification SDK)`).

When grilling, challenge new or fuzzy terms against the **Ubiquitous Language** of the nearest
`AGENTS.md` and every parent up to the root, and capture resolutions inline per that doc's
**Change Protocol**. The Ubiquitous Language section is a glossary and nothing else — keep
implementation detail, specs, and scratch notes out of it.
