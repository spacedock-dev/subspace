---
name: r
description: Review one readable Markdown file for feedback or present one canonical Briefing package in the native Subspace TUI through Zellij, tmux, Herdr, CMUX, Ghostty, or Apple Terminal.
---

# Review a file or canonical Briefing

Accept one of these disjoint forms:

```text
[--allow-question] [--mode <feedback|advisory|binding>] <file.md> [terminal]
--review-v1 --actor <actor> --mode <feedback|advisory|binding>
  <briefing-file> [terminal]
```

The terminal is
`zellij`, `tmux`, `herdr`, `cmux`, `ghostty`, or `apple-terminal`. Reject every
other name and every extra argument before any terminal probe or launch. The
terminal chooses presentation wiring only; never pass its name to an entry or
the TUI. The explicit `--review-v1` token selects package mode. Never infer a
profile from a suffix or file content.

For a plain file, resolve its relative, absolute, or symlinked Markdown locator
to one readable regular target with a searchable resolved parent. The selected
entry owns physical resolution and SHA-256 pinning. On a plain file `--mode` is
optional and defaults to `feedback`: omitting it requests no authority, so
nothing is inferred. Declaring `advisory` or `binding` is how authority is
asked for, and Subspace never infers it from the source shape or from comparing
identities. `--allow-question` is a second independent optional modifier on that
same form — the same review, optionally questionable — and never a form of its
own; see *Answer one question during a review*.
Package mode requires only one readable regular Briefing file plus
a non-empty actor and a declared mode. Its filename, relative or absolute
spelling, parent permissions, and Unix mode are not Review v1 preconditions.
The canonical loader establishes that the content is a valid Briefing.

The selected fixed entry owns path resolution, revision pinning, exact
`subspace-tui` resolution, the literal
`review-v1-provider-package-v1` and `review-v1-resolution-mode-v1` capability
checks, allocation of one fresh
retained provider package, host preflight, launch, delivery, canonical
validation, and cleanup. The caller never chooses Result, log, inventory,
diagnostics, staging, title, or mode mechanics. Do not duplicate those checks
with model-authored shell commands.

Both journeys probe `review-v1-resolution-mode-v1` and refuse to launch against
a binary that cannot carry a declared mode. No exact release label is consulted
for either journey.

## Select one terminal

An explicit terminal wins. Otherwise inspect inherited caller signals without
running a command and select the first family present in this fixed order:
Zellij, tmux, Herdr, CMUX, Ghostty, then Apple Terminal.

1. Zellij signals are `ZELLIJ_SESSION_NAME` and `ZELLIJ_PANE_ID`.
2. tmux signals are `TMUX` and `TMUX_PANE`.
3. Herdr signals are `HERDR_ENV=1` and `HERDR_PANE_ID`.
4. CMUX signals are `CMUX_WORKSPACE_ID` and `CMUX_SURFACE_ID`.
5. Ghostty's signal is `TERM_PROGRAM=ghostty` on macOS.
6. Apple Terminal's signal is `TERM_PROGRAM=Apple_Terminal` on macOS.

For the first family with any signal present, require all of its listed signals
and specified values. A partial family stops with the missing signal; it never
falls through. Complete signals select a terminal but do not prove its host is
healthy. A missing binary, unavailable operation, ambiguous caller, inaccessible
server, malformed probe, or broken selected host also stops without trying a
later terminal. If no family is present and the operating system is macOS,
select Apple Terminal and invoke
`review-apple-terminal [--mode <feedback|advisory|binding>] <file.md>` exactly once. On other
operating systems, report the supported names and ask for an explicit terminal.
Never probe two hosts.

The automatic Apple Terminal selection is final. Permission refusal, structural
preflight failure, Automation denial, launch or post-launch uncertainty, and
result, delivery, or cleanup failure all stop without re-entering selection,
retrying the entry, or opening another surface.

## Permission and invocation

Obtain host permission before any probe of the selected terminal. Explain once
that Subspace will pin the named Artifact and exact binary, inspect only the
selected caller, create one provider-owned invocation package, open one
interactive review surface, wait for its result, invoke
`validate-one-file-result` exactly once, return the trusted bytes, and clean
only successful transient scratch. State
that it performs no network, package-manager, or repository write and no retry,
fallback, Briefing construction, workflow routing, or suggestion application.
Do not ask a separate natural-language yes/no question.

For an automatic Apple Terminal selection, also explain that the fixed entry
checks the system Terminal app and AppleScript prerequisites, asks macOS to let
the invoking host automate Terminal, opens one fresh targetless tab, and then
follows the same wait, validation, delivery, and cleanup boundary. It never
retries, falls back, or opens a second surface.

Use the host's supported access boundary. Manual permission mode lets the host
show its one approval dialog for the selected command. Automatic permission
mode executes that same command with zero human stops. Refusal, unavailable
permission, or confinement stops with zero terminal probes and zero launches
and names the access needed. Do not infer permission from a prior run or probe
before permission.

Locate the bundled scripts directory relative to this skill and invoke
exactly one selected fixed entry point in one tool call with separate argv
entries:

```text
review-<selected-terminal> [--allow-question] [--mode <feedback|advisory|binding>] <file.md>
review-<selected-terminal> --review-v1 --actor <actor>
  --mode <feedback|advisory|binding> <briefing-file>
```

Do not run a plan, prerequisite probe, version check, scratch command,
validator, cleanup, retry, or second entry in another tool call. Keep the one
blocking call and invoking turn alive until it returns. A nonzero return after
launch includes a recoverable scratch path; report it and stop without another
host or launch.

An armed review is the single exception. `--allow-question` cannot finish inside
one blocking call, because the session that has to answer is blocked inside it,
so that journey is a sequence of invocations of the same selected entry as
described in *Answer one question during a review*. It authorizes nothing else:
still no plan, probe, version check, scratch command, validator, cleanup, retry,
second host, or second launch.

### Host-owned placement

- Zellij resolves `ZELLIJ_PANE_ID` through one validated caller-tab inventory
  and opens one blocking floating pane with the exact `--tab-id`.
- tmux validates the exact caller pane and attached client, then opens one
  blocking popup targeted at that pane.
- Herdr creates one right split with `--no-focus` and submits one private child
  capsule to that owned pane.
- CMUX creates one terminal surface in the caller pane, starts its child
  atomically, then closes only that surface and restores the caller surface.
- Ghostty makes one LaunchServices request for a new app instance and waits for
  its private child completion.
- Apple Terminal uses targetless `do script`, activates only after the new tab
  exists, and reports Automation error `-1743` without fallback.

Each entry retains its host-specific prerequisite and caller-identity checks.
The shared private lifecycle contains no terminal selection or host command.
Every entry crosses its host-changing boundary once, waits for the
host-appropriate child/result delivery barrier, and returns the canonical
validator's trusted record byte-for-byte. Zellij and tmux continue waiting when
the blocking host command returns just before the same invocation atomically
publishes its result; that wait is not a retry or relaunch.

In package mode, common mechanics allocate one fresh retained provider package
and the fixed entry starts one private provider supervisor. The supervisor
launches the exact `subspace-tui --review-v1 --actor <actor> --mode
<feedback|advisory|binding> --provider-package <provider-root> <briefing-file>`
child, waits for
that PID, and atomically records its exit. `--provider-package` is private
Subspace wiring, never caller grammar. Result publication, pane creation, and
launcher return never authorize validation or delivery. The common lifecycle
calls the canonical validator once only after an exit-zero child. It retains
the unchanged Result, log, presented inventory, argv, child exit, stderr,
capability evidence, and diagnostics together on success and failure.

Dispatch is irreversible. Never retry, fall back, relaunch, open another
terminal, or invoke the binary or entry again after the first host-changing
command starts. Preflight failure removes empty owned scratch and launches
nothing. Cancellation, timeout, malformed completion, missing or invalid
result, failed delivery, cleanup failure, or uncertain terminal state after
launch preserves the recovery path and possible host residue.

For Markdown, the binary alone constructs the Briefing and snapshots the
Artifact. For package mode, it loads the supplied Briefing unchanged. In both
profiles, the binary renders the TUI and atomically publishes the result; the
entries own lifecycle and host placement. Do not add a second result, parser,
generic adapter, or terminal registry.

## Answer one question during a review

`--allow-question` lets the reviewer ask this session one question about the
document while the review is open, and read the answer in the same surface. Pass
it when the user asks for a review they may want to interrogate; otherwise leave
it off.

Arming changes this skill's completion contract, and the change lands even when
nobody asks anything. Each invocation returns as soon as it has something to
report rather than when the review ends, so a finished review is learned by
invoking the entry again — never by assuming that a quiet return means nothing
happened. Expect roughly one extra invocation per ninety seconds the reviewer
spends reading. That cost is why the flag is opt-in and not the default.

Each invocation returns exactly one JSON object naming a `state`. Act on it:

- `question` — the reviewer asked. Answer it from the pinned Artifact at the
  reported `artifact` path, write the answer to one private text file, and
  invoke the entry once with `--answer-question --text-file <file>`.
- `answered` — the review took the answer and is still open. Invoke again.
- `waiting` — nothing is decided yet and the review is untouched. Invoke again.
  This never means the review is idle and never means it is over.
- `abandoned` — the reviewer left the question before the answer arrived. The
  review is unaffected. Invoke again.
- `declined` — this session gave up on the question. The review is unaffected.
- `result` — the review finished. Report it exactly as *Report the returned
  record* requires and stop.
- `aborted` — the review ended with no result. Report the returned `reason` and
  `hostReason` and stop without another host or launch.

Invoke again with `--poll-question` and nothing else. Answer with
`--answer-question --text-file <file>` and nothing else. Give up on a question
with `--decline-question --reason <text>` and nothing else, rather than leaving
a reviewer watching for an answer that is not coming. The selected entry finds
the review each of these belongs to on its own; when more than one review is
open it refuses and names the documents in play rather than guessing. Never
construct, parse, store, or pass a run directory, and never invoke a bundled
script other than the selected entry.

Answer only from the pinned Artifact and what the user's request already
established. The answer is prose the reviewer reads: it carries no checked
evidence and no authority of its own, and answering never records a Decision,
grants binding authority, or edits the Artifact. Say plainly when the document
does not settle the question.

An armed review implements `feedback` only. Declaring `advisory` or `binding`
alongside `--allow-question` is refused by name before anything is created.

## Report the returned record

The bundled `validate-one-file-result` executable is the only result authority.
The selected entry calls its preserved four-argument interface once for
Markdown or its explicit package profile once for a canonical Briefing. Do not
author or run a decoder, parser, or independent validator in the skill.

On success, use the trusted record only to report feedback with ordered annotations
in normal prose, say the review completed with no feedback when
its ordered annotations are empty, or say the review remains open and name its
continuation. Never call a plain-file outcome an approval, Decision,
Resolution, verdict, or gate result. Never expose raw Review JSON.

For package mode, return the trusted retained Result without changing it and
report the provider-package location emitted by the fixed entry. The declared
mode alone decides authority: `feedback` returns Annotations with no decision
surface, while `advisory` and `binding` return the same Resolution-carrying
Result differing only in `binding`. No Result names a second identity. The presented
inventory states the exact ordered Artifacts and recursively reached References
Subspace displayed. A future scaffold request may bind an arbitrary Briefing
locator plus canonical id/digest, actor, and mode into this same invocation. That composition seam
does not authorize this skill to prepare requests, construct associations, call
the recorder, interpret Routing, or continue a workflow.

## Act within existing authority

Feedback is input to the invoking session, never authorization to edit the
Artifact. Apply a suggestion only when the user's request already authorized
that edit; otherwise report it or ask first. Preserve an open continuation
without choosing a route. This neutral skill does not record a Decision, route
workflows, grant binding authority, commit changes, or advance task state.
