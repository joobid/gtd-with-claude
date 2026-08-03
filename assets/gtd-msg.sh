#!/usr/bin/env bash
#
# Write a channel message.
#
# This is an executable asset rather than a block to type, and the reason is measured:
# building the filename by substitution and feeding a heredoc is a shape no permission
# pattern can cover -- `contains shell syntax that cannot be statically analyzed` -- so the
# most frequent operation in the whole method prompted the person every single time, and the
# only relief on offer was the standing approval this skill spends a page warning against.
#
# A named entry point is allowed once and is reviewable in the repository. It is the rule the
# skill already gives for `python3 -c`, turned on the skill's own machinery.
#
#   gtd-msg.sh --author cowork --from cowork --to code \
#              --re 20260802-...md --state open --slug short-hyphenated  <<'EOF'
#   ## body in markdown
#   EOF
#
# The body is read from stdin. The path of the message it wrote is printed on stdout.
#
# --channel defaults to .runs/exchange under the current directory, or $GTD_CHANNEL if set.
# A project without a repository will point it somewhere else; nothing here assumes git.

set -euo pipefail

AUTHOR=""; FROM=""; TO=""; RE="-"; STATE="open"; SLUG=""
CHANNEL="${GTD_CHANNEL:-.runs/exchange}"

while [ $# -gt 0 ]; do
  case "$1" in
    --author)  AUTHOR="$2";  shift 2 ;;
    --from)    FROM="$2";    shift 2 ;;
    --to)      TO="$2";      shift 2 ;;
    --re)      RE="$2";      shift 2 ;;
    --state)   STATE="$2";   shift 2 ;;
    --slug)    SLUG="$2";    shift 2 ;;
    --channel) CHANNEL="$2"; shift 2 ;;
    -h|--help) sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "gtd-msg: unknown argument: $1" >&2; exit 2 ;;
  esac
done

for v in AUTHOR FROM TO SLUG; do
  if [ -z "${!v}" ]; then
    echo "gtd-msg: missing --$(echo "$v" | tr 'A-Z' 'a-z')" >&2; exit 2
  fi
done

# The four vocabularies of the protocol, enforced rather than remembered.
case "$AUTHOR" in code|cowork) ;; *) echo "gtd-msg: --author must be code or cowork" >&2; exit 2 ;; esac
case "$FROM"   in code|cowork|owner) ;; *) echo "gtd-msg: --from must be code, cowork or owner" >&2; exit 2 ;; esac
case "$TO"     in code|cowork|owner|both) ;; *) echo "gtd-msg: --to must be code, cowork, owner or both" >&2; exit 2 ;; esac
case "$STATE"  in open|consensus|settled|escalated) ;; *) echo "gtd-msg: --state must be open, consensus, settled or escalated" >&2; exit 2 ;; esac

# `state: consensus` with `re: -` is one agent asserting a two-party fact. The protocol says
# so; here it refuses rather than relying on the agent having read it.
if [ "$STATE" = "consensus" ] && [ "$RE" = "-" ]; then
  echo "gtd-msg: state consensus requires --re pointing at a message from the other agent" >&2
  exit 2
fi

mkdir -p "$CHANNEL"

# A commit reference is a property of the project and supports a staleness check. A clock
# reading is not, and says so, so nobody compares it for equality.
if HEAD=$(git rev-parse --short HEAD 2>/dev/null); then
  HEAD="sha:$HEAD"
else
  HEAD="clock:$(date -u +%Y%m%dT%H%M%SZ)"
fi

# One second of resolution is not enough, and this was measured: two messages written in the
# same call landed with the same second in their names, the second answering the first, and
# the ordering survived only because the slugs happened to sort in causal order. An agent
# that records a decision and then notifies the other writes two files back to back, so this
# is the common case rather than the edge one.
TS=$(date -u +%Y%m%d-%H%M%S)
while ls "$CHANNEL/$TS"-*.md >/dev/null 2>&1; do
  sleep 1
  TS=$(date -u +%Y%m%d-%H%M%S)
done
MSG="$CHANNEL/$TS-$AUTHOR-$SLUG.md"

# `>` is safe here because the timestamp plus the collision guard make the file new by
# construction. Everywhere else, `>` on an existing file is the wide scope of writing files.
{
  echo "---"
  echo "from: $FROM"
  echo "to: $TO"
  echo "re: $RE"
  echo "state: $STATE"
  echo "head: $HEAD"
  echo "---"
  echo
  cat
} > "$MSG"

echo "$MSG"
