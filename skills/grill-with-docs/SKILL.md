---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model and decisions recorded in AGENTS.md, sharpens terminology, and updates AGENTS.md inline as decisions crystallise. Use when the user wants to stress-test a plan against the project's language and documented decisions.
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

</what-to-do>

<supporting-info>

## Domain awareness

During codebase exploration, look for the AGENTS.md hierarchy. Read the nearest AGENTS.md and every parent AGENTS.md up to the repo root before proposing changes.

### File structure

The relevant docs live in AGENTS.md files along the path from root to the work area:

```
/
├── AGENTS.md                       ← root DOX rail + monorepo contracts
├── apps/
│   └── invyte-new/
│       └── AGENTS.md               ← app-specific language + decisions
└── packages/
    └── design-system/
        └── AGENTS.md               ← package-specific contracts
```

AGENTS.md is the single durable contract. Domain language lives in its **Ubiquitous Language** section. Architectural decisions live in its **Architectural Decisions** section.

Create files lazily — only when you have something to write. If no AGENTS.md exists at the work area, create one when the first term or decision is resolved. If a child folder becomes a durable boundary, create a child AGENTS.md and add it to the parent's **Child DOX Index**.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the **Ubiquitous Language** in the nearest AGENTS.md, call it out immediately. "Your AGENTS.md defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update AGENTS.md inline

When a term is resolved, update the **Ubiquitous Language** section of the nearest AGENTS.md right there (format: [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md)). When a decision is resolved, update the **Architectural Decisions** section (format and global ADR numbering: [ADR-FORMAT.md](./ADR-FORMAT.md)). Don't batch these up — capture them as they happen.

Follow the AGENTS.md **Change Protocol** on every edit: read the DOX chain first, update the nearest owning AGENTS.md after, and keep the **Child DOX Index** current.

### Offer architectural decisions sparingly

Only add an entry to **Architectural Decisions** when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the entry.

## AGENTS.md shape

When creating or updating AGENTS.md, prefer this section order:

1. **Purpose** — what this folder owns and why it exists
2. **Ownership** — who/what is responsible, and what belongs here vs. parent/child
3. **Change Protocol** — the self-documenting contract for reading and updating this doc
4. **Local Contracts** — binding rules for this subtree
5. **Ubiquitous Language** — canonical terms and "avoid" aliases (was CONTEXT.md)
6. **Architectural Decisions** — inline ADR entries (was docs/adr/)
7. **Work Guidance** — patterns, conventions, stack, commands, examples
8. **Verification** — commands, checks, tests
9. **Child DOX Index** — direct child AGENTS.md files

</supporting-info>
