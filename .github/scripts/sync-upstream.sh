#!/usr/bin/env bash
# Mirror upstream LibStub (SVN trunk) into the repository root, unmodified.
# Only updates files in the working tree; committing is left to the caller.
# Run from the repository root.
set -euo pipefail

SVN_URL="${SVN_URL:-https://repos.curseforge.com/wow/libstub/trunk}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Paths owned by this mirror, never deleted or overwritten by the sync.
PROTECTED='^(\.git|docs(/|$)|README\.md$|NOTICE|UPSTREAM_REVISION$|CLAUDE\.md$)'

retry() {
	local attempt
	for attempt in 1 2 3; do
		"$@" && return 0
		echo "Attempt $attempt failed: $*" >&2
		[ "$attempt" -lt 3 ] && sleep 30
	done
	return 1
}

svn_fail() {
	echo "::error::Upstream SVN unreachable or failed: $SVN_URL"
	exit 1
}

svn() { command svn --non-interactive "$@"; }

output() {
	if [ -n "${GITHUB_OUTPUT:-}" ]; then
		echo "$1" >> "$GITHUB_OUTPUT"
	fi
}

head_rev="$(retry svn info --show-item revision "$SVN_URL")" || svn_fail
rev="$(retry svn info -r "$head_rev" --show-item last-changed-revision "$SVN_URL")" || svn_fail
stage="$WORK/upstream"
retry svn export --quiet -r "$head_rev" "$SVN_URL" "$stage" || svn_fail
echo "Upstream HEAD r$head_rev, trunk last changed in r$rev"
output "revision=$rev"

(cd "$stage" && find . -mindepth 1 -maxdepth 1 -printf '%P\n') | { grep -E "$PROTECTED" || true; } | while read -r path; do
	echo "::warning::Upstream ships protected path '$path'; not mirrored."
	rm -rf "${stage:?}/$path"
done

# Tracked, non-protected files missing from the snapshot were deleted upstream.
mapfile -t removed < <(git ls-files | { grep -vE "$PROTECTED" || true; } | while read -r path; do
	[ -e "$stage/$path" ] || [ ! -e "$path" ] || echo "$path"
done)
mapfile -t changed < <(cd "$stage" && find . -type f -printf '%P\n' | sort | while read -r path; do
	cmp -s "$path" "$OLDPWD/$path" || echo "$path"
done)

if [ "${#removed[@]}" -eq 0 ] && [ "${#changed[@]}" -eq 0 ]; then
	echo "::notice::Already up to date with upstream r$rev ($SVN_URL)."
	output "changed=false"
	exit 0
fi

for path in "${removed[@]}"; do
	rm -f -- "$path"
	echo "deleted: $path"
done
for path in "${changed[@]}"; do
	mkdir -p "$(dirname "$path")"
	cp -- "$stage/$path" "$path"
	echo "updated: $path"
done
printf 'r%s\n%s\n' "$rev" "$SVN_URL" > UPSTREAM_REVISION
echo "::notice::Synced upstream r$rev (${#changed[@]} updated, ${#removed[@]} deleted)."
output "changed=true"
