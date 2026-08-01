# subspace-tui unavailable

The selected entry's preflight refuses with exit 127, and pi's
`subspace_review` throws, when `subspace-tui` does not resolve; both print a
pointer naming this file. This file is the journey that pointer names.
Classify *why* the binary is unavailable with cheap shell you run yourself,
then name the one remedy for that reason on this platform. Do not retry the
entry, select another terminal, or guess at Homebrew before the reason is
named.

Classify in this order, stopping at the first reason that matches:

1. **Installed but not on `PATH`.** `command -v subspace-tui` failed, but an
   executable `subspace-tui` exists in a well-known prefix. Probe, in order:
   `/opt/homebrew/bin`, `/usr/local/bin`, `~/.local/bin`, `~/bin`,
   `/home/linuxbrew/.linuxbrew/bin`. Name the reason and print the fix — the
   export line for the prefix where it was found:

   ```sh
   export PATH=<prefix>:$PATH
   ```

   After the user applies it, re-invoke the same review. A fresh direct
   install that landed in `~/.local/bin` on a host where that directory is
   not on `PATH` classifies here, not as a failed install.

2. **Wrong architecture.** A resolved `subspace-tui` exists but executing it
   fails at the loader — `cannot execute binary file` or an ENOENT raised by
   the loader. Name the reason as an architecture mismatch: the binary's
   architecture against this host's `<darwin|linux>/<amd64|arm64>`. Pin that
   named reason, not the OS error text — the text varies by platform and
   shell, and macOS Rosetta can mask the class. The remedy is the build that
   matches this host, resolved through the canonical latest-release URL
   `http://spacedock.md/latest-release/subspace` — the direct-binary command
   in step 3. This is not the capability refusal: a binary that executes but
   answers the `--supports review-v1-resolution-mode-v1` probe nonzero is too
   old, keeps its `does not support … upgrade` message, and its remedy is an
   upgrade, not a reinstall.

3. **Not installed.** Neither `PATH` nor any well-known prefix carries the
   binary. Classify the platform and print exactly one remedy:

   - **macOS with Homebrew** (`uname -s` is `Darwin` and `command -v brew`
     succeeds): `brew install spacedock-dev/tap/subspace-beta`. Homebrew is
     the primary macOS path.
   - **Linux (amd64 or arm64), or macOS without Homebrew:** the direct-binary
     installer, which resolves the latest release through the canonical URL
     `http://spacedock.md/latest-release/subspace`, verifies the release's
     `checksums.txt` before anything is placed, and installs into
     `$SUBSPACE_INSTALL_DIR` (default `~/.local/bin`):

     ```sh
     curl -fsSL https://raw.githubusercontent.com/spacedock-dev/subspace/main/install.sh | sh
     ```

   - **Any other OS or architecture:** refuse by name. `subspace-tui` ships
     for darwin and linux on amd64 and arm64 only; never fall back silently
     to Homebrew or a source build.

   For either supported-platform remedy, first decide whether this runtime
   permits the command's network access and install-directory write. Use
   known runtime policy or a read-only capability check. Do not infer
   confinement from a missing binary, a container path, or a generic sandbox
   statement.

   If the runtime permits the command, show the exact command. Then ask if you
   can run that command. Wait for an explicit answer. Never run an install on
   detection alone.

   - If the user agrees, run the offered command once. Then re-invoke the same
     review with the same arguments.
   - If the user declines, print the command. Then stop. Do not download
     anything. Do not write anything.

   When the remedy lands in `~/.local/bin` and that directory is not on the
   user's `PATH`, include it in `PATH` for the retried review. Also print the
   persistent command:

   ```sh
   export PATH="$HOME/.local/bin:$PATH"
   ```

If known runtime policy or a read-only check proves a blocked capability,
attempt nothing. Name the blocked capability. Give the user the step-3
command for their own terminal, the target `~/.local/bin/subspace-tui`, and
the export line above when needed.

The classification changes nothing about the selected terminal or the
declared mode.
