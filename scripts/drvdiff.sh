#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
drvdiff - what moved between two revisions of this config, by derivation path

  scripts/drvdiff.sh [REF]     compare the working tree against REF (default HEAD)
  scripts/drvdiff.sh --help

WHAT IT COMPARES
  Every output under `checks`, `packages` and `containers`, on both sides, by
  .drv path. A drvPath is a transitive fingerprint: equal drvPath means nothing
  anywhere in that derivation's build-time closure changed - not a package, not
  an option, not an input. That is what makes it usable as a regression oracle
  for changes that are supposed to be pure refactors.

WHY THE REVISION IS FORCED
  `core` bakes the git revision into a `nixos-revision` script that ends up in
  every system closure. A naive before/after comparison therefore reports every
  host as moved on every commit, and tells you nothing.

  So both sides are pinned to the same revision: REF is extracted with
  `git archive` (which yields no .git) and handed a fake HEAD, and the working
  tree is passed `--arg rev`. What survives that is real change.

VERDICTS
  MOVED     same output, different .drv - its closure changed
  added     present now, absent in REF
  removed   present in REF, absent now
  fixed     did not evaluate in REF, does now
  BROKEN    evaluated in REF, does not now

EXIT STATUS
  0  nothing moved - a refactor stayed a refactor
  1  something moved - expected of a real change, so CI does not fail on it
  2  REF is not a commit
  3  an output stopped evaluating - always a bug, and what CI gates on

IMPLEMENTATION NOTE
  Each output kind is evaluated in one go, falling back to one evaluation per
  output when that fails. Nix cannot contain every error itself - `tryEval`
  catches `throw` and `assert`, but not a missing attribute and not a missing
  path - so containment happens here instead. Otherwise a single broken output
  hides every other answer, which is how `packages.vm-*` stayed dead unnoticed.
EOF
}

if [ "${1:-}" = --help ] || [ "${1:-}" = -h ]; then
  usage
  exit 0
fi

base="${1:-HEAD}"
repo="$(git rev-parse --show-toplevel)"
old="$(mktemp -d)"
trap 'rm -rf "$old"' EXIT

git -C "$repo" rev-parse --verify --quiet "$base^{commit}" >/dev/null || {
  echo "drvdiff: '$base' is not a commit" >&2
  exit 2
}

git -C "$repo" archive --format=tar "$base" | tar -x -C "$old"

mkdir -p "$old/.git"
printf 'drvdiff' >"$old/.git/HEAD"

KINDS=(checks packages containers)

drvOf='v: let r = builtins.tryEval (if v ? drvPath then v.drvPath else "NOT-A-DERIVATION");
          in if r.success then r.value else "EVAL-FAILED"'

load() {
  printf 'let c = import %s; in if builtins.isFunction c then c { rev = "drvdiff"; } else c' "$1"
}

nixeval() { nix eval --impure --raw --expr "$(load "$1")" --apply "$2" 2>/dev/null; }

snap() {
  local dir="$1" kind names name drv
  for kind in "${KINDS[@]}"; do
    if nixeval "$dir" "c: builtins.concatStringsSep \"\n\" (
         map (n: \"$kind.\${n} \" + (($drvOf) c.$kind.\${n})) (builtins.attrNames (c.$kind or { })))"
    then
      echo
      continue
    fi

    names="$(nixeval "$dir" "c: builtins.concatStringsSep \" \" (builtins.attrNames (c.$kind or { }))")" || {
      echo "$kind.* ENUMERATION-FAILED"
      continue
    }
    for name in $names; do
      drv="$(nixeval "$dir" "c: ($drvOf) c.$kind.\"$name\"")" || drv=EVAL-FAILED
      echo "$kind.$name $drv"
    done
  done
}

echo "drvdiff: $base -> working tree"
snap "$old" | grep . | LC_ALL=C sort >"$old/.a"
snap "$repo" | grep . | LC_ALL=C sort >"$old/.b"

LC_ALL=C join -j1 -a1 -a2 -e MISSING -o 0,1.2,2.2 "$old/.a" "$old/.b" |
  awk '
    $3 ~ /FAILED$/  { broken++;  print "  BROKEN  ", $1; next }
    $2 ~ /FAILED$/  { fixed++;   print "  fixed   ", $1; next }
    $2 == "MISSING" { added++;   print "  added   ", $1; next }
    $3 == "MISSING" { removed++; print "  removed ", $1; next }
    $2 == $3        { same++; next }
                    { moved++;   print "  MOVED   ", $1 }
    END {
      printf "\n%d unchanged, %d moved, %d added, %d removed, %d fixed, %d broken\n",
        same+0, moved+0, added+0, removed+0, fixed+0, broken+0
      # distinct codes: a move is expected of a real change, an output that no
      # longer evaluates never is. CI gates on the latter only.
      if (broken) exit 3
      if (moved) exit 1
    }'
