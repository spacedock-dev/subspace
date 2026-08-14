---
name: dry
description: A durable, glanceable status pane for "what's the current plan" questions — investigate the project's real current state live in a pane, without naming a document to review.
---

# DRY: ask "what's the plan" without repeating yourself

There is no document to name here. The captain's question is about the
project's current state, not about a file, and this skill exists so that
question can be asked and re-asked without re-typing it to a dispatch session
each time.

This is a thin skill, not a new protocol. It reuses the existing one-file
`--allow-question` arming leg from the `r` skill completely unchanged, by
writing a small placeholder file for that leg to snapshot, and it overrides
exactly one thing the `r` skill's shared instructions say: where the answer
comes from.

## Write the placeholder

1. Create a fresh scratch directory: `mktemp -d`.
2. Resolve the project directory: the canonicalized absolute current working
   directory.
3. Write `<scratch>/dry-status.md` with this exact body, substituting
   `<project-dir>`:

   ```
   # DRY status pane

   Project: <project-dir>

   This file is a placeholder. It is never read for content — arming this
   review needed a real, readable file, and this is the one this skill wrote
   for that purpose. Press Q to ask a question; answers come from actually
   investigating this project's current state, not from this document. Press
   q (lowercase) to end this DRY status session.
   ```

   Writing this file is the ENTIRE "without an artifact" mechanism. If it
   cannot be written, nothing was armed: report the write failure and stop.
   Do not retry, and do not fall back to a real project file — the whole
   point is that no document is named.

## Arm

`dry` has no scripts of its own. The bundled scripts directory is the `r`
skill's, at `../r/scripts` relative to this skill's own directory — locate it
there, not under a `dry/scripts` that does not exist.

Follow `../r/SKILL.md`'s *Select one terminal* and *Permission and
invocation* sections exactly as written, with one substitution: invoke

```text
SUBSPACE_DRY=1 review-<selected-terminal> --allow-question <scratch>/dry-status.md
```

the plain one-file arming form, with no `--mode` and no `--placement`, plus
the `SUBSPACE_DRY=1` shell environment prefix -- a plain assignment on the
command line, not an entry argument. That prefix is the one thing that is
not byte-identical to arming any other one-file review through the `r`
skill: it is `dry`'s explicit signal that this Artifact is its own
placeholder, threaded through the shared lifecycle (`buildInvocationCommand`)
into the launched review's environment so it opens on the question rail
instead of the placeholder document. It controls startup presentation only
-- not authority, Resolution, or the portable record. Do not drop it: the
selected entry and the run directory it mints have no other way to
distinguish this Artifact from a document someone asked to review.

Some agent harnesses match Bash-tool permission rules against the literal
invoked command's prefix. Because this line prepends `SUBSPACE_DRY=1` to
the entry invocation, an allow-list rule scoped to the bare
`review-<terminal>` command no longer matches, and the harness may ask
for approval it would not otherwise ask for. This is a known, accepted
cost of the explicit-signal design — not a bug to fix here. A captain who
wants to suppress it can add a local allow-list rule covering the
`SUBSPACE_DRY=1`-prefixed form.

## Poll, answer, and report

Follow `../r/SKILL.md`'s *Answer questions during a review* section
verbatim once armed — the same poller chain, the same per-runtime
implementation, the same one-outstanding-question discipline, the same
opaque `run`/`questionId` handling — with these two overrides:

- **Sourcing.** Where that section says to answer from the pinned Artifact, a
  DRY run instead investigates the project directory named in the placeholder
  using whatever agentic actions actually answer the question — reading
  files, running `git`, `spacedock`, or other project-appropriate commands,
  whatever the question calls for. `spacedock status` (e.g. `spacedock status
  --workflow-dir docs/dev`) is one thing a spacedock-managed project's
  captain naturally asks for, not a requirement of the mechanism — a project
  with no `spacedock` installed still gets a real, grounded answer, because
  the investigation fits whatever the project actually has. Never answer from
  recall of what the plan is believed to be, and never read the
  placeholder's own content as a source of the answer — actually take the
  actions the question calls for, then compose the answer from what was
  actually found. Name the action(s) taken as the first line of the answer
  text itself (e.g. "Sourced from: `spacedock status --workflow-dir
  docs/dev`", or "Sourced from: reading `package.json` and `git log -5`"),
  then the answer composed from what they returned — the answer leg does not
  yet carry a separate structured evidence field (tracked separately:
  `evidence-threading-in-questiontransport`), so naming the action has to
  travel inside the answer text to stay visible and checkable. Submit with
  the ordinary answer leg and nothing else: `--answer-question --for-question
  <questionId> --text-file <file> --run <run>`.
- **A quit is not a failure.** When the receiver returns `result` (pressing
  lowercase `q`, the documented and normal way to end a feedback-only
  session — `../r/SKILL.md`'s `finishFeedback` path) or `aborted` (any other
  exit), report plainly that the DRY status session ended — never phrase it
  as a review that "completed with no feedback" or "ended with no result,"
  and never treat either as an error. Nothing was under review, so there is
  nothing that failed or that needed feedback to complete.

Every other returned `state` (`question`, `answered`, `waiting`, `abandoned`,
`declined`, `expired`) is handled exactly as `../r/SKILL.md` describes,
with no DRY-specific change.

## Act within existing authority

An answer composed here carries no authority: no Decision, no Resolution, no
binding surface, and no edit to anything. It is prose describing what the
investigation found at the moment it ran, and it may already be stale by the
time it is read. Say so when reporting an answer. Never call it a plan
approval, a verdict, or anything more durable than the investigation it was
composed from.
