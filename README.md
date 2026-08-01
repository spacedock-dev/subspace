# Subspace

Review one Markdown file in your terminal.

Subspace includes a companion agent skill that launches its focused reader in
Zellij, tmux, CMUX, Herdr, Ghostty, or Apple Terminal. It sends comments and
suggested edits directly back to the invoking agent, attached to exact text.

![A Markdown file in Subspace's focused reader](assets/review-one-file.gif)

## Install and try it

```sh
brew install spacedock-dev/tap/subspace-beta
```

### Linux, or macOS without Homebrew

Install the prebuilt binary directly. The installer resolves the latest
release through the canonical latest-release URL
`http://spacedock.md/latest-release/subspace`, verifies the release's
checksum before anything is placed, and installs `subspace-tui` into
`~/.local/bin`:

```sh
curl -fsSL https://raw.githubusercontent.com/spacedock-dev/subspace/main/install.sh | sh
```

Add `~/.local/bin` to your `PATH` if it is not already there.

```sh
sr path/to/file.md
```

From an agent session with the companion skill installed, invoke:

```text
/r path/to/file.md
```

In Codex, invoke:

```text
$r path/to/file.md
```

## Agent integration

Ask your agent to open the review with the Subspace skill. This example uses
tmux and lets the reviewer ask questions during the review:

```text
$r --allow-question path/to/file.md tmux
```

Press <kbd>Q</kbd> to ask about the file. The agent keeps a poller active while
the review is open. It answers from the same file that you can see in Subspace.
You can continue the review while the agent prepares the answer.

When you finish, Subspace returns comments and suggested edits to the agent.
Each item stays attached to the text that you selected.

Press <kbd>?</kbd> from any non-editor review surface to see its current
keyboard shortcuts.

![A comment attached to selected text in Subspace](assets/anchored-feedback.png)

## License

The Subspace skills are released under Apache 2.0. The `subspace-tui` tool
itself is not currently open source. The permissions and attributions for
external code linked into the tool are published in
[`THIRD_PARTY_NOTICES.txt`](THIRD_PARTY_NOTICES.txt).
