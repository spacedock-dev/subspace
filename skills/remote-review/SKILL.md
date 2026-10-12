---
name: remote-review
description: Publish a Markdown file for review on Spacedock Review and hand the user the share link plus an owner link that opens the review as them. Also covers `rr device` (is this device bound to an account) and `rr unbind`. Use when asked to share a file for review, to get an owner link, or to check or end this device's account binding.
---

# Spacedock Review: publish a file, hand over the links

This skill is a thin layer over `subspace-relay-client`, which owns transport and
the device credential. `rr` is the same program when it is on PATH; this skill
always calls it by its full name because the `rr` alias is skipped on machines
where that name is taken.

## Check the program first

Run `command -v subspace-relay-client`. If it prints nothing, stop and show the
install command, then ask before running it:

- macOS with `brew`: `brew install spacedock-dev/tap/subspace-beta`
- otherwise: `curl -fsSL https://raw.githubusercontent.com/spacedock-dev/subspace/main/install.sh | sh`

A plugin install gives this skill, not the program. If the user declines, stop.

## Publish

Only when the user asks to share a file.

1. Run `subspace-relay-client publish <file> --dry-run`. Tell the user the
   `destination:` it prints and that anyone holding the link can read the copy
   until it expires. Do this before the first publish of a file.
2. Run `subspace-relay-client publish <file>`.
3. Hand over, copied verbatim from its output:
   - `share-url:` is for reviewers; send this one.
   - `owner-link:` is for the user alone: it opens the review as them, works
     once, and `owner-link-valid:` says how many seconds it lives. A new one
     comes from publishing the same file again (same share link).
4. If the output has `owner-link: unavailable (...)`, relay the reason and still
   give the share link. If it has no `owner-link:` line at all, the installed
   client predates owner links: say so and show the install command above.

## Wait for the decision

Only when the user asked for the decision, after the links are handed over.
Wait the way `/r` waits: run `subspace-relay-client decision <share-url>` as
the one blocking call, through the implementation `../r/SKILL.md` binds to your
runtime (*Wait implementations*). Do not poll `feedback` yourself.

- Exit 0: stdout is the owner's verified decision, one JSON object. Report its
  `resolution.decision` and `resolution.reason`, and what it `includes`. Its
  authority is the owner mark the relay set, not `resolution.by`. Reporting it
  is not permission to edit: act only within the authority the user already gave.
- Exit 3: no decision within 12 hours; the link is still live. Say so.
- Exit 4: the link was revoked or expired before anyone decided. Say so.
- Exit 1: relay the one `decision:` line from stderr.

`subspace-relay-client feedback <share-url>` is the one-shot read. It prints
`binding: yes` on the owner's decision and `binding: no (...)` on any other
decision-shaped Result; treat only the first as the owner's.

## Device and unbind

- `subspace-relay-client device` is read-only and prints `binding:`. Exit 1 with
  `binding: unknown` means the relay does not report it.
- `subspace-relay-client unbind` only when the user asks. First repeat its
  `effect:` line back to them: it ends every browser that owned this device's
  reviews.

## Never

- Open, fetch or test the owner link yourself: it is one use, and your request
  would spend it.
- Print, read, copy or quote the credential file, a device id or a secret. The
  `credentials:` line is a path; that is all you may relay.
- Set `XDG_STATE_HOME` or `--relay-url` to anything the user did not ask for.
- Store the owner link in a file, a commit or a ticket.
