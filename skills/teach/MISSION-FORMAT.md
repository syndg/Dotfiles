# MISSION.md Format

`MISSION.md` lives at the workspace root. It captures the _reason_ the user is learning this topic. Every teaching decision — what to teach next, which resources to surface, which exercises to design — should trace back to this document.

## Template

```md
# Mission: {Topic}

## Why
{1-3 sentences. The concrete real-world goal the user is chasing. What changes in their life or work when they have this skill? Avoid abstract framings like "to understand X" — push for the underlying outcome.}

## Success looks like
- {A specific, observable thing the user will be able to do}
- {Another specific thing}
- {…}

## Constraints
- {Time, budget, prior commitments, learning preferences, anything that bounds the approach}

## Out of scope
- {Adjacent topics the user explicitly does not want to chase right now — protects the zone of proximal development}
```

## Rules

- **One _root_ mission per workspace.** If the user wants to learn two _unrelated_ things, that is two workspaces. _Related_ parallel tracks of a single subject (e.g. usage vs internals, theory vs practice, language vs framework) may instead live as **sub-missions** nested inside the same workspace — see [Sub-missions](#sub-missions).
- **Concrete over abstract.** "Run a half marathon by October" beats "get fitter." "Ship a Rust CLI to my team" beats "learn Rust."
- **Push back on vagueness.** If the user cannot articulate why, interview them before writing anything. A bad mission is worse than no mission.
- **Revise when reality shifts.** Missions change. When the user's goal moves, update this file — don't leave a stale mission steering future sessions.
- **Keep it short.** If `MISSION.md` runs past a screen, it has stopped being a compass and started being a plan.

## Sub-missions

A single subject sometimes has **parallel tracks** that share context but advance independently — e.g. learning a library's _usage_ alongside its _internals_, or a sport's _theory_ alongside its _practice_. These are too related to split into separate workspaces (they cross-reference constantly), yet too independent to flatten into one mission (each has its own zone of proximal development and pacing).

For these, nest each track as a **sub-mission**: a subdirectory that is itself a self-contained teaching workspace.

```
workspace/
  README.md                 # indexes the tracks (recommended once >1 mission exists)
  MISSION.md                # the root / primary mission
  lessons/  learning-records/  reference/   # the root mission's own materials
  <track>/                  # a sub-mission, e.g. internals/
    MISSION.md              # this track's mission (same format as this file)
    lessons/                # its own 0001-… counter, independent of root
    learning-records/       # its own 0001-… counter, independent of root
    reference/  NOTES.md    # optional, track-local
```

### Rules for sub-missions

- **Self-contained.** Each sub-mission has its own `MISSION.md` and its own `lessons/` and `learning-records/` with **independent numbering** (a track's `0001` is unrelated to root's `0001`). ZPD is computed _per sub-mission_ from its own records.
- **Related, not unrelated.** Sub-missions are tracks of _one_ subject. Genuinely unrelated topics are still separate workspaces. If two sub-missions never cross-reference and share no glossary, they probably want to be two workspaces.
- **Root stays a valid mission or an index.** The root `MISSION.md` is either the primary track itself, or — if every track is a sub-mission — a short orientation that points at them (a top-level `README.md` can carry the index instead).
- **Cross-link freely.** A sub-mission lesson may cite another track's lessons/records (e.g. internals citing usage lesson 0003). That cross-referencing is the reason they share a workspace.
- **Shared glossary by default.** Prefer one `GLOSSARY.md` at the root so terminology is consistent across tracks; only give a sub-mission its own glossary if its nomenclature genuinely diverges.
- **Don't over-nest.** One level of sub-missions is almost always enough. Deeper nesting is a smell — reconsider whether you really have that many independent tracks.
