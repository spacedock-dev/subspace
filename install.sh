#!/bin/sh
# ABOUTME: Universal curl|sh installer — fetch the checksum-verified Subspace
# ABOUTME: release tarball for this host's OS/arch and install every binary in it.
#
# Usage (Linux or macOS without Homebrew):
#   curl -fsSL https://raw.githubusercontent.com/spacedock-dev/subspace/main/install.sh | sh
#
# Behavior:
#   * Detects OS (darwin|linux) and arch (amd64|arm64) from uname.
#   * Resolves the asset to fetch from one of two sources, same extract/verify/
#     install path for both:
#       - SUBSPACE_INSTALL_FROM unset (production): the release named by the
#         canonical latest-release URL
#         http://spacedock.md/latest-release/subspace (which redirects to the
#         subspace releases/latest API). No release-asset path or version
#         is spelled in this script; both come from that resolution.
#       - SUBSPACE_INSTALL_FROM=<dir|url-base> (tests / pinned mirror): a local
#         goreleaser `dist/` directory or a URL prefix holding the same
#         `subspace_<ver>_<os>_<arch>.tar.gz` + `checksums.txt` layout.
#   * Verifies the tarball sha256 against the matching `checksums.txt` line and
#     ABORTS (installs nothing) on any mismatch — the gate is fail-closed.
#   * Extracts every binary the archive's `BINARIES.txt` inventory names, plus
#     that inventory's symlinks, into SUBSPACE_INSTALL_DIR (default
#     ~/.local/bin). The archive carries the inventory because this script runs
#     on a user's machine with nothing but the tarball in hand.
#   * Replaces a link name only when it already holds a symlink to the binary
#     being installed. A link name held by anything this installer did not
#     create — a symlink to a different target, a directory, or a plain file —
#     is left alone, named on stderr, and does not fail the install: both
#     binaries still land and the summary names every alias that was skipped.
#
# SUBSPACE_PRINT_TARGET=1 runs the detection + URL-construction path and prints
# the resolved os/arch/asset/tarball/checksums, then exits before any download —
# the inspection seam a live-URL test asserts against.
#
# macOS Homebrew (`brew install spacedock-dev/tap/subspace-beta`) remains the
# primary mac path; this script is the Linux and non-Homebrew install path.
set -eu

REPO="spacedock-dev/subspace"
LATEST_URL="http://spacedock.md/latest-release/subspace"
INSTALL_DIR="${SUBSPACE_INSTALL_DIR:-$HOME/.local/bin}"

err() { printf 'install.sh: %s\n' "$*" >&2; }
die() { err "$*"; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }

# detect_os maps `uname -s` to the goreleaser goos token. Only darwin and linux
# ship release tarballs; anything else is unsupported here.
detect_os() {
	case "$(uname -s)" in
		Darwin) echo darwin ;;
		Linux) echo linux ;;
		*) die "unsupported OS $(uname -s); Subspace ships darwin/linux only" ;;
	esac
}

# detect_arch maps `uname -m` to the goreleaser goarch token. The release builds
# amd64 + arm64; uname reports several spellings for each.
detect_arch() {
	case "$(uname -m)" in
		x86_64 | amd64) echo amd64 ;;
		arm64 | aarch64) echo arm64 ;;
		*) die "unsupported arch $(uname -m); release ships amd64 + arm64 only" ;;
	esac
}

# sha256_of prints the lowercase hex sha256 of a file, using whichever tool the
# host carries: sha256sum (Linux), or `shasum -a 256` (macOS).
sha256_of() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | awk '{print $1}'
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | awk '{print $1}'
	else
		die "no sha256 tool found (need sha256sum or shasum)"
	fi
}

# fetch copies a source ref (local file path or http(s) URL) to a destination
# file. A missing local file or a non-2xx HTTP status is a hard failure so the
# caller never proceeds on a partial download.
fetch() {
	src="$1"
	dst="$2"
	case "$src" in
		http://* | https://*)
			curl -fsSL -o "$dst" "$src" || die "download failed: $src"
			;;
		*)
			[ -f "$src" ] || die "file not found: $src"
			cp "$src" "$dst"
			;;
	esac
}

# resolve_latest_tag asks the canonical latest-release URL for the repo's
# latest release tag (e.g. v0.9.0). $LATEST_URL redirects to the GitHub
# releases/latest API for $REPO; curl follows the redirect and a non-2xx
# final status fails (-f) with no tag and no download. Unauthenticated; the
# public releases endpoint needs no token.
resolve_latest_tag() {
	curl -fsSL "$LATEST_URL" \
		| grep '"tag_name"' \
		| head -n 1 \
		| sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/'
}

# asset_name builds the goreleaser archive name for a version/os/arch. The
# version carries no leading `v` (goreleaser stamps the bare semver into the
# `{{ .Version }}` template); the tag does, so callers strip it.
asset_name() {
	printf 'subspace_%s_%s_%s.tar.gz' "$1" "$2" "$3"
}

main() {
	need uname
	need curl
	need tar
	need mktemp
	need readlink

	os="$(detect_os)"
	arch="$(detect_arch)"

	# Resolve the asset name + the source refs (tarball + checksums) for either
	# source. The SAME verify/extract/install path runs below for both.
	if [ -n "${SUBSPACE_INSTALL_FROM:-}" ]; then
		from="${SUBSPACE_INSTALL_FROM%/}"
		# A local dist directory embeds the snapshot version in the filename, not
		# known a priori, so glob for the os/arch tarball. A URL base must carry a
		# resolvable version, so SUBSPACE_INSTALL_VERSION pins it.
		case "$from" in
			http://* | https://*)
				ver="${SUBSPACE_INSTALL_VERSION:?SUBSPACE_INSTALL_VERSION required when SUBSPACE_INSTALL_FROM is a URL}"
				asset="$(asset_name "$ver" "$os" "$arch")"
				tarball_src="$from/$asset"
				checksums_src="$from/checksums.txt"
				;;
			*)
				[ -d "$from" ] || die "SUBSPACE_INSTALL_FROM is not a directory or URL: $from"
				asset="$(cd "$from" && ls subspace_*_"${os}"_"${arch}".tar.gz 2>/dev/null | head -n 1)"
				[ -n "$asset" ] || die "no subspace_*_${os}_${arch}.tar.gz in $from"
				tarball_src="$from/$asset"
				checksums_src="$from/checksums.txt"
				;;
		esac
	else
		tag="$(resolve_latest_tag)"
		[ -n "$tag" ] || die "could not resolve the latest release tag from $LATEST_URL"
		ver="${tag#v}"
		asset="$(asset_name "$ver" "$os" "$arch")"
		base="https://github.com/$REPO/releases/download/$tag"
		tarball_src="$base/$asset"
		checksums_src="$base/checksums.txt"
	fi

	# Inspection mode: print the resolved target and stop before any download or
	# install. This runs the EXACT production detection + URL-construction path
	# above (no divergent branch) so a test can assert the asset name + URL the
	# real installer would fetch against the live release.
	if [ -n "${SUBSPACE_PRINT_TARGET:-}" ]; then
		printf 'os=%s\narch=%s\nasset=%s\ntarball=%s\nchecksums=%s\n' \
			"$os" "$arch" "$asset" "$tarball_src" "$checksums_src"
		return 0
	fi

	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' EXIT

	fetch "$tarball_src" "$tmp/$asset"
	fetch "$checksums_src" "$tmp/checksums.txt"

	# Checksum gate (fail-closed). Pull THIS asset's expected hash from
	# checksums.txt by exact filename, compute the downloaded tarball's hash, and
	# abort installing anything on any mismatch or a missing checksum line.
	expected="$(awk -v f="$asset" '$2 == f {print $1}' "$tmp/checksums.txt" | head -n 1)"
	[ -n "$expected" ] || die "no checksum line for $asset in checksums.txt — refusing to install"
	actual="$(sha256_of "$tmp/$asset")"
	if [ "$expected" != "$actual" ]; then
		die "checksum mismatch for $asset (expected $expected, got $actual) — refusing to install"
	fi

	# Only after the checksum passes do we touch the install dir.
	tar -xzf "$tmp/$asset" -C "$tmp" || die "could not extract $asset"
	[ -f "$tmp/BINARIES.txt" ] || die "tarball carries no BINARIES.txt inventory — refusing to install"
	mkdir -p "$INSTALL_DIR"
	installed=""
	skipped=""
	while read -r name links; do
		[ -n "$name" ] || continue
		[ -f "$tmp/$name" ] || die "tarball inventory names $name but the archive has no such binary"
		install -m 0755 "$tmp/$name" "$INSTALL_DIR/$name" 2>/dev/null \
			|| { cp "$tmp/$name" "$INSTALL_DIR/$name" && chmod 0755 "$INSTALL_DIR/$name"; }
		installed="$installed $name"
		for link in $links; do
			# `rr` is also Mozilla's record-and-replay debugger, so a link name
			# can hold a program this installer must not remove. An occupied
			# alias is a skipped convenience, not a failed install: warn, leave
			# the occupant untouched, and keep going.
			if [ -L "$INSTALL_DIR/$link" ]; then
				existing="$(readlink "$INSTALL_DIR/$link")"
				if [ "$existing" != "$name" ]; then
					err "$INSTALL_DIR/$link is a symlink to $existing, not to $name — leaving it, skipping the $link alias"
					skipped="$skipped $link"
					continue
				fi
				rm -f "$INSTALL_DIR/$link"
			elif [ -d "$INSTALL_DIR/$link" ]; then
				err "$INSTALL_DIR/$link is a directory, not a symlink to $name — leaving it, skipping the $link alias"
				skipped="$skipped $link"
				continue
			elif [ -e "$INSTALL_DIR/$link" ]; then
				err "$INSTALL_DIR/$link is a file this installer did not create — leaving it, skipping the $link alias"
				skipped="$skipped $link"
				continue
			fi
			ln -s "$name" "$INSTALL_DIR/$link" || die "could not link $link to $name in $INSTALL_DIR"
			installed="$installed $link"
		done
	done < "$tmp/BINARIES.txt"
	[ -n "$installed" ] || die "tarball inventory named no binaries — refusing to report an install"

	printf 'install.sh: installed%s from %s to %s\n' "$installed" "$asset" "$INSTALL_DIR" >&2
	[ -z "$skipped" ] || printf 'install.sh: skipped alias(es)%s — see warnings above for why\n' "$skipped" >&2
	case ":$PATH:" in
		*":$INSTALL_DIR:"*) ;;
		*) err "note: $INSTALL_DIR is not on PATH; add it to run these directly" ;;
	esac
}

main "$@"
