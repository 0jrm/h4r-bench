#!/usr/bin/env bash
# usage: ./test.sh
# Checks the install without a model: the scorers' unit tests, then the honest scripted agent on seed 1 of every
# chore and version, built, played in the sandbox and scored. Exit 1 when any verdict differs from task.json.
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
"$here/env/prereq.sh" test.sh || exit 2
python3 -m unittest discover -s "$here/tests" -q || exit 1
failed=0
for chore in t1-walltime t3-entity-overlap t8-fixture; do
  for version in trap control; do
    if out=$("$here/bench" "$chore" "$version" --seed 1 --scripted 2>&1); then
      echo "ok   $chore $version seed 1: $(grep '^verdict:' <<<"$out")"
    else
      failed=1
      echo "FAIL $chore $version seed 1:"
      tail -5 <<<"$out" | sed 's/^/     /'
    fi
  done
done
exit $failed
