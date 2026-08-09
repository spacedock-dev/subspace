---
name: r
description: Review one readable Markdown file for feedback or present one canonical Briefing package in the native Subspace TUI through Zellij, tmux, Herdr, CMUX, Ghostty, or Apple Terminal.
---

# Review a file or canonical Briefing

Accept one of these disjoint forms:

```text
[--allow-question] [--mode <feedback|advisory|binding>]
  [--placement <floating|right>] <file.md> [terminal]
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
own; see *Answer questions during a review*.
`--placement <floating|right>` is a third optional modifier on that same form,
declaring where the review surface opens. Placement is presentation-only: it
grants nothing and leaves the review protocol, the child invocation, and the
result untouched. An omitted token means `right` for both Zellij and tmux — a
split is part of the actual pane tree and mirrors live to every client
attached to the session, while a popup is a per-client overlay a second
attached client never sees. `floating` remains available as an explicit
opt-in on both hosts. `right` is a Zellij- and tmux-only declaration: refuse
it with every other terminal name (Herdr,
CMUX, Ghostty, Apple Terminal), and refuse every malformed placement — an
unknown value, a duplicate, or a missing value — before invoking any entry.
Pass the token only to `review-zellij` or `review-tmux`; every other entry
refuses it as unknown grammar. Never combine `--placement` with
`--allow-question` or `--review-v1`: those journeys re-invoke the entry with a
fixed argv and would silently drop it, so the combination is refused by name.
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
review-<selected-terminal> [--allow-question] [--mode <feedback|advisory|binding>] [--placement <floating|right>] <file.md>
review-<selected-terminal> --review-v1 --actor <actor>
  --mode <feedback|advisory|binding> <briefing-file>
```

Do not run a plan, prerequisite probe, version check, scratch command,
validator, cleanup, retry, or second entry in another tool call. Before
launch, select the implementation bound to the invoking runtime (see *Wait
implementations* below) and use it to keep that one call and its result alive
until it returns. A nonzero return after launch includes a recoverable
scratch path; report it and stop without another host or launch.

An armed review is the single exception. `--allow-question` cannot finish inside
one blocking call, because the session that has to answer is blocked inside it,
so that journey is a sequence of invocations of the same selected entry as
described in *Answer questions during a review*. It authorizes nothing else:
still no plan, probe, version check, scratch command, validator, cleanup, retry,
second host, or second launch.

### Wait implementations

Two implementations keep the one blocking call and its result alive until the
invoking turn can act on it; every invoking runtime is bound to exactly one.
Neither changes what the one call does or how many times it happens — only
how it is issued and awaited.

- **Implementation 1: background-job-with-wakeup.** Start the call as a
  background job and rely on the runtime's own proactive completion
  notification to resume the invoking turn. There is no polling and no
  bounded wait loop, and because the turn is never blocked on the call, no
  foreground-call ceiling applies. See *Claude Code poller* below for the
  exact mechanism.
- **Implementation 2: foreground-job-with-background-wait.** The invoking
  runtime does not rely on a passive one-shot notification; it requires an
  actively re-armed bounded wait instead, yielding and re-waiting on a
  bounded schedule rather than depending on a single notification to resume
  the turn. See *Codex poller* (Codex) or *Claude Code sub-agent/teammate
  poller* (a Claude Code sub-agent or teammate) below for the exact
  mechanism.

| Runtime | Implementation | Why |
|---|---|---|
| Claude Code, root session | 1 | Its proactive completion notification reliably wakes an idle root session; see *Claude Code poller*. |
| Claude Code, sub-agent/teammate | 2 | The same passive background+notify pattern does not reliably wake an idle sub-agent or teammate turn; see *Claude Code sub-agent/teammate poller*. |
| Codex | 2 | Already the documented, working shape of *Codex poller* below. |
| Pi | Neither — out of scope | No Pi-specific poller exists in this skill. |

A runtime absent from this table, or whose bound mechanism is unavailable in
this session, issues the plain or package-mode call in the foreground and
keeps the turn alive until it returns, unchanged from before. An armed
review has no such fallback (see *Answer questions during a review*).

### Host-owned placement

- Zellij resolves `ZELLIJ_PANE_ID` through one validated caller-tab inventory,
  then by default opens a right split of the caller's tab — the split lands
  relative to the tab's focused pane — with tab targeting, blocking, and the
  child invocation unchanged. With `--placement floating` it substitutes one
  blocking floating pane with the exact `--tab-id` for the split instead.
- tmux validates the exact caller pane, then by default opens a blocking
  right split of the caller's pane — `split-window` does not block like a
  popup does, so the entry polls the split's own liveness instead, which also
  bounds cancellation (closing or killing the split directly) the same way
  every other placement's cancellation is bounded — then closes the split.
  With `--placement floating` it opens a blocking popup targeted at that pane
  instead: a popup is a per-client overlay, invisible to any other client
  attached to the same session, so no client-count precondition applies to
  either placement.
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

## subspace-tui unavailable

The selected entry's preflight refuses with exit 127, and pi's
`subspace_review` throws, when `subspace-tui` does not resolve; both print a
pointer naming `skills/r/references/subspace-tui-unavailable.md`. That file
is the deferred journey for this refusal: on seeing the pointer, stop and
read `skills/r/references/subspace-tui-unavailable.md` before anything else.
It classifies *why* the binary is unavailable and names the one remedy for
that reason on this platform. Do not retry the entry, select another
terminal, or guess at Homebrew before the reason is named.

## Answer questions during a review

`--allow-question` lets the reviewer ask this session questions about the
document while the review is open, and read the answer in the same surface. Pass
it when the user asks for a review they may want to interrogate; otherwise leave
it off.

Arming changes this skill's completion contract, and the change lands even when
nobody asks anything. Each invocation returns as soon as it has something to
report rather than when the review ends, so a finished review is learned by
invoking the entry again — never by assuming that a quiet return means nothing
happened.

The arming invocation begins the **poller** chain. Retain its returned `run`
value as opaque identity. Every later poller is the same selected entry invoked
with `--poll-question --run <run>`. Pass that same `--run <run>` to every answer
and decline command so concurrent armed reviews never depend on inference.

**While an armed review has not returned `result` or `aborted`, ensure exactly
one poller supported by the invoking runtime is running; after either terminal
state, no poller is required.**

Before launch, select the implementation for the invoking runtime below and
verify that its wake-capable mechanism is available. Do not improvise a
different mechanism.

### Codex poller

For each common poller command, start one `functions.exec` task. Inside that
task, run the command as its foreground helper with `tools.exec_command` and
`yield_time_ms: 30000`. If it exits inside that yield, return its JSON. If it
yields a `session_id`, keep the same outer task alive and wait on that helper
with `tools.write_stdin` until it exits, then return its complete JSON. This
wait follows the shell session; it does not query Subspace state.

While the task runs, it is the sole poller visible in `/ps`. Before the first
foreground wait, tell the user: "Waiting for the review. Press Esc to talk. The
review listener will continue to run." Then install `functions.wait` on the
outer task. Reinstall that wait silently after chat input while the task remains
active. Do not narrate listener changes, run identity, successful answer
delivery, or wait installation. Keep terminal results and failures visible.
Never let the outer task end at a shell-session yield.

### Claude Code poller

Invoke the selected entry with the Bash tool's `run_in_background: true`.
Retain the returned background task ID as the running poller. Claude Code's
proactive completion notification wakes the root session; after that
notification, read the task's output file once for the complete receiver JSON.
Do not poll the task output while it runs. If background tasks are disabled or
the completion notification is unavailable, the armed journey is unsupported
in that Claude Code session.

**Sub-agent/teammate note:** for a Claude Code sub-agent or teammate session,
the completion notification above still fires internally on schedule but
does not reliably surface as a wake for that session — a delivery gap, not
an unavailable mechanism, so the blanket unsupported fallback above does not
apply here. Use *Claude Code sub-agent/teammate poller* below instead of
this poller's background+notify wake.

### Claude Code sub-agent/teammate poller

Invoke the selected entry with the Bash tool's `run_in_background: true` and
capture the returned `bash_id`. On a bounded schedule, call
`BashOutput(bash_id=...)` only to check `status` — never to extract output
while `status` is `"running"`, since that call drains output already
written and can consume the receiver JSON before completion. Sleep briefly
between checks rather than blocking the invoking turn on one wait. Once
`status` reports `"completed"`, read the task's output file once for the
complete receiver JSON and proceed. This active status check does not
depend on the completion notification *Claude Code poller* above relies on.

Any invoking runtime without a section above is unsupported for an armed
review.

There is no foreground fallback for `--allow-question`. Before invoking the
selected entry, determine whether the invoking/root session can provide its
listed wake-capable poller. If it cannot, refuse to arm:
tell the user this host cannot continue a question-enabled review nonblockingly,
and invoke no entry, create no run, and launch no review. The remedy is to use a
supported runtime implementation, then start the arming invocation as its
poller.

When a receiver returns `question`, immediately start its replacement through
the selected runtime implementation with `--poll-question --run <run>` —
**before** reading the Artifact, composing the answer, or forwarding it.
Copy the returned opaque `questionId` without parsing it.
Then answer from the pinned Artifact and run a separate, short command:
`--answer-question --for-question <questionId> --text-file <file> --run <run>`.
The answer command ends when the review consumes that answer; it never becomes
the next receiver. Keep exactly one receiver continuously active until it
returns `result` or `aborted`.

A successful `question` return durably advances an internal delivery cursor, so
the replacement receiver waits instead of returning that question again while
its answer is outstanding. If a receiver is killed before successful return,
the cursor was not advanced and a replacement safely redelivers the question.
If answer forwarding is killed before publishing a valid answer, invoke the
same answer command again; interrupted bytes are not a claim. If it is killed
after the answer file is valid, the reviewer can still consume it and the
already-running receiver remains live. Do not start a second receiver during
recovery.

Each invocation returns exactly one JSON object naming a `state`. Act on it:

- `question` — the reviewer asked. Start the replacement receiver first. Then
  answer from the pinned Artifact at the reported `artifact` path, write the
  answer to one private text file, and invoke the entry once with the exact
  returned identity:
  `--answer-question --for-question <questionId> --text-file <file> --run <run>`.
- `answered` — the review took the answer. Leave the already-running receiver
  alone; do not invoke another poll.
- `waiting` — nothing is decided yet and the review is untouched; only a leg
  you bounded with an explicit `--machine-budget` reports this. Invoke again.
  This never means the review is idle and never means it is over.
- `abandoned` — the reviewer left the question before the answer arrived. The
  review is unaffected. Leave the already-running receiver alone.
- `declined` — this session gave up on the question. The review is unaffected.
  Leave the already-running receiver alone.
- `expired` — the question lapsed unanswered while an answer was open: the
  review waited its answer budget and stopped, and no answer for it can still
  be read. A lapsed question is never handed out again; the reviewer may ask
  again. Leave the already-running receiver alone.
- `result` — the review finished. Report it exactly as *Report the returned
  record* requires and stop.
- `aborted` — the review ended with no result. Report the returned `reason` and
  `hostReason` and stop without another host or launch.

Every replacement receiver uses `--poll-question --run <run>` and nothing else.
Start it only when the receiver chain begins or immediately after `question`,
as described above; an `answered`, `abandoned`, `declined`, or `expired`
response from answer forwarding never starts another receiver. A receiver with
an explicit `--machine-budget <seconds>` may return `waiting`; immediately
start its replacement through the same runtime implementation. The normal
receiver omits that bound and wakes the root session once per event.
Answer with
`--answer-question --for-question <questionId> --text-file <file> --run <run>` and nothing
else. Give up on a question with
`--decline-question --for-question <questionId> --reason <text> --run <run>` and nothing
else, rather than leaving a reviewer watching for an answer that is not coming.
Both identities are opaque: retain the returned `run` and copy the exact
`questionId` returned with that question; never derive, split, validate, or
substitute either. Never interpret `run` as a directory, and never invoke a
bundled script other than the selected entry.

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
