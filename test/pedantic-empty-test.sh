#!/bin/sh

cd "$(dirname "$0")"

# Can't detect sourcing in sh, so immediately terminate the attempt to parse
JSONSH_SOURCED=yes
. ../JSON.sh </dev/null

# make test output TAP compatible
# http://en.wikipedia.org/wiki/Test_Anything_Protocol

fails=0
tests=8
i=0

echo "1..${tests}"

# Note: weird whitespaces and end-of-lines below are intended
# TODO: populate by printf?
for DOC in \
    "" \
    " " \
    "
" \
"
  
 " \
; do
  i="$(expr $i + 1)"
  JSONSH_OUT="$(echo "$DOC" | jsonsh_cli 2>/dev/null)" ; JSONSH_RES=$?
  if [ "$JSONSH_RES" = 0 ]
  then
    echo "ok $i - empty input '$DOC' is okay in non-pedantic mode"
  else
    echo "not ok $i - empty input '$DOC' was rejected in non-pedantic mode"
    fails="$(expr $fails + 1)"
    echo "RETRACE >>>"
    (set -x ; echo "$DOC" | jsonsh_cli )
    echo "<<<"
  fi

  i="$(expr $i + 1)"
  JSONSH_OUT="$(echo "$DOC" | jsonsh_cli -P 2>/dev/null)" ; JSONSH_RES=$?
  if [ "$JSONSH_RES" = 0 ]
  then
    echo "not ok $i - empty input '$DOC' should be rejected in pedantic mode"
    fails="$(expr $fails + 1)"
    echo "RETRACE >>>"
    (set -x ; echo "$DOC" | jsonsh_cli -P)
    echo "<<<"
  else
    echo "ok $i - empty input '$DOC' was rejected in pedantic mode"
  fi
done

echo "$i test(s) executed"
echo "$fails test(s) failed"
exit $fails

# vi: expandtab sw=2 ts=2
