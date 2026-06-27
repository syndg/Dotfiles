# Durable lesson workflow pitfalls

Use this when a teaching session moves from discussion into a new lesson or the user says phrases like “next lesson”, “let’s go”, “move on”, “publish”, or asks why the workspace was not updated.

## Core correction from SynDG

Do not treat a new lesson request as only a conversational explanation. The `teach` skill is stateful: the durable workspace is the product.

## Required workflow

1. Read `MISSION.md`, `RESOURCES.md`, and recent `learning-records/` before choosing the lesson angle.
2. Teach one tightly scoped concept.
3. Create the lesson artifact under `lessons/NNNN-<dash-case>.html` unless the user explicitly asks for pure chat/Q&A only.
4. Record what changed in `learning-records/NNNN-<dash-case>.md`.
5. Create/update reference material when the concept is reusable beyond the lesson.
6. Publish by default for SynDG-generated lessons unless he explicitly says not to. For other users/workspaces, publish when asked or when the workspace convention already requires a visitable URL.
7. Verify the exact artifact: HTML parse/build if applicable, public URL when published, browser render, no horizontal overflow, and any interactions.
8. Report the artifact URL/path and verification tersely.

## Pitfall

If the user says “let’s move to the next lesson”, do not answer with only a Discord mini-lesson. That skips the workspace contract. A mini-explanation is fine as a preview, but the turn is not complete until the lesson HTML and learning record exist or the user explicitly opts out.
