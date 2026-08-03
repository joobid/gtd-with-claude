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
#
# --selftest runs the writer against a scratch directory and reports what it examined. It is
# an install step, not a developer convenience: the question is never "which systems does this
# support" but "does it work on this machine", and only running it answers that.

set -euo pipefail

AUTHOR=""; FROM=""; TO=""; RE="-"; STATE="open"; SLUG=""; SELFTEST=""
CLOSES=""; LANDS_IN=""; DECISIONS=""
CHANNEL="${GTD_CHANNEL:-.runs/exchange}"

while [ $# -gt 0 ]; do
  case "$1" in
    --author)  AUTHOR="$2";  shift 2 ;;
    --from)    FROM="$2";    shift 2 ;;
    --to)      TO="$2";      shift 2 ;;
    --re)      RE="$2";      shift 2 ;;
    --state)   STATE="$2";   shift 2 ;;
    --slug)    SLUG="$2";    shift 2 ;;
    --closes)  CLOSES="$2";  shift 2 ;;
    --lands-in) LANDS_IN="$2"; shift 2 ;;
    --channel) CHANNEL="$2"; shift 2 ;;
    --decisions) DECISIONS=1; shift ;;
    --selftest) SELFTEST=1; shift ;;
    -h|--help) sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "gtd-msg: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# The person's decisions, as an index: filename and first heading, never bodies.
#
# This is a level-1 mechanism and the distinction is the point. The rule used to
# read "check what the person already decided before declaring something missing",
# and it was obeyed 23 seconds too late: the gap was published, and the answer had
# been on the channel for nine minutes. An instruction you have to remember at the
# right moment is not a control. So the writer runs the query itself, below.
#
# The index, not the messages: 23 decisions is more than half a real channel by
# volume, and printing them would destroy the stopping rule it exists to serve.
# ---------------------------------------------------------------------------
decision_index() {
  ( cd "$1" 2>/dev/null || return 0
    ls -1 2*.md >/dev/null 2>&1 || return 0
    for f in $(grep -lE '^from: +owner$' 2*.md 2>/dev/null || true); do
      h=$(grep -m1 '^#' "$f" 2>/dev/null | sed 's/^#* *//')
      printf '  %s  %s\n' "$f" "$h"
    done )
}

if [ -n "$DECISIONS" ]; then
  # A wrong directory returns nothing, and so does a channel where the person has decided
  # nothing. Those are opposite facts with the same output, so the empty channel aborts
  # rather than reporting a clean result -- the same rule this method applies to every
  # other verifier. Caught by the repository's own claim checker, not by reading.
  n=$(ls -1 "$CHANNEL"/2*.md 2>/dev/null | grep -c . || true)
  if [ "$n" -eq 0 ]; then
    echo "BLIND: no messages under $CHANNEL. Wrong directory, or no channel yet. This is not a pass." >&2
    exit 2
  fi
  out=$(decision_index "$CHANNEL")
  if [ -z "$out" ]; then
    echo "EXAMINED: $n messages under $CHANNEL. None carries from: owner -- nothing decided yet."
  else
    printf 'EXAMINED: %s messages. DECISIONS ON RECORD (%s):\n%s\n' \
           "$n" "$(printf '%s\n' "$out" | grep -c .)" "$out"
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# --selftest
#
# Six checks, each naming its own fix. Together they cover everything a list of
# supported operating systems would try to predict, plus the cases a list cannot
# see -- an exec bit dropped by a filesystem that does not carry one, a bash old
# enough to miss a construct, a `date` that rejects the format string.
#
# It exercises the real writer rather than a copy of its logic. A self-test that
# reimplements what it checks passes while the shipped thing is broken.
# ---------------------------------------------------------------------------
if [ -n "$SELFTEST" ]; then
  fails=0
  checks=0
  report() {
    checks=$((checks + 1))
    if [ "$1" = ok ]; then
      printf '  ok    %s\n' "$2"
    else
      printf '  FAIL  %s\n' "$2"
      printf '        fix: %s\n' "$3"
      fails=$((fails + 1))
    fi
  }

  printf 'gtd-msg --selftest on %s, bash %s\n' "$(uname -s)" "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"

  if [ "${BASH_VERSINFO[0]}" -ge 3 ]; then
    report ok "bash is 3.2 or newer"
  else
    report fail "bash is 3.2 or newer" "install a current bash and put it ahead on PATH"
  fi

  # Not cosmetic. The documented invocation is ./gtd-msg.sh, and a permission rule
  # naming that path matches that text and no other. A filesystem that does not carry
  # an exec bit -- an NTFS mount seen from WSL, some sync clients -- leaves the file
  # present, looking installed, and refusing to run.
  if [ -x "$0" ]; then
    report ok "the script is executable"
  else
    report fail "the script is executable" \
      "chmod +x '$0' -- and if chmod does not stick, the filesystem carries no exec bit: move the project onto a native one"
  fi

  if date -u +%Y%m%d-%H%M%S >/dev/null 2>&1; then
    report ok "date -u accepts the timestamp format"
  else
    report fail "date -u accepts the timestamp format" "install coreutils, or put a POSIX date ahead on PATH"
  fi

  probe="${TMPDIR:-/tmp}/gtd-msg-selftest-$$"
  mkdir -p "$probe"
  trap 'rm -rf "$probe"' EXIT

  if out=$(bash "$0" --channel "$probe" --author code --from code --to cowork \
                     --state open --slug selftest <<'EOF' 2>&1
## selftest
EOF
  ) && [ -f "$out" ]; then
    report ok "writes a message and prints its path"
    missing=""
    for k in from to re state head; do
      grep -qE "^$k: " "$out" || missing="$missing $k"
    done
    if [ -z "$missing" ]; then
      report ok "the message carries all five front-matter keys"
    else
      report fail "the message carries all five front-matter keys" "report this: keys missing:$missing"
    fi
  else
    report fail "writes a message and prints its path" "report this verbatim: $out"
    report fail "the message carries all five front-matter keys" "blocked by the previous failure"
  fi

  before=$(ls -1 "$probe" | wc -l)
  if bash "$0" --channel "$probe" --author code --from code --to cowork \
               --state consensus --slug bad </dev/null >/dev/null 2>&1; then
    report fail "refuses state consensus without --re" "report this: a malformed call was accepted"
  elif [ "$(ls -1 "$probe" | wc -l)" -eq "$before" ]; then
    report ok "refuses state consensus without --re, and writes nothing"
  else
    report fail "refuses state consensus without --re, and writes nothing" \
      "report this: the call was refused but a file appeared anyway"
  fi

  # --- The guards this round added, each with its positive control ---------
  # Every one of these must fail against the writer as it shipped in v0.3.0.
  # A guard that passes on the tree it was written for has proved nothing.
  # A refusal is not enough: it has to be THIS refusal. Checked against the v0.3.0
  # writer, "rejects --closes text that is not there" passed because that writer had
  # never heard of --closes and died on "unknown argument" -- a green light for the
  # wrong reason, in the round whose subject is green lights for the wrong reason.
  # So $SAYING names a word the real refusal must contain.
  refuses() {
    n0=$(ls -1 "$probe" | wc -l)
    if err=$(bash "$0" --channel "$probe" "$@" </dev/null 2>&1 >/dev/null); then
      report fail "$LABEL" "report this: the call was accepted"
    elif [ "$(ls -1 "$probe" | wc -l)" -ne "$n0" ]; then
      report fail "$LABEL" "report this: refused, and a file appeared anyway"
    elif printf '%s' "$err" | grep -q "unknown argument"; then
      report fail "$LABEL" "this build does not know the flag -- it refused for the wrong reason"
    elif [ -n "${SAYING:-}" ] && ! printf '%s' "$err" | grep -q "$SAYING"; then
      report fail "$LABEL" "refused, but not for this reason: $err"
    else
      report ok "$LABEL"
    fi
  }
  accepts() {
    if bash "$0" --channel "$probe" "$@" >/dev/null 2>&1; then
      report ok "$LABEL"
    else
      report fail "$LABEL" "report this: a well-formed call was refused"
    fi
  }

  LABEL="refuses state settled without --closes (A-06, M19)"; SAYING="requires --closes"
  refuses --author code --from owner --to both --state settled --slug d1

  target=$(bash "$0" --channel "$probe" --author cowork --from cowork --to code \
                     --state open --slug question <<'EOF'
## The thing being asked
body
EOF
  )
  target=$(basename "$target")

  LABEL="refuses --closes text that is not in the message it closes"; SAYING="does not appear in"
  refuses --author code --from code --to cowork --state settled --slug d2 \
          --re "$target" --closes "something nobody wrote"

  LABEL="accepts --closes quoting a heading of that message"
  accepts --author code --from code --to cowork --state settled --slug d3 \
          --re "$target" --closes "The thing being asked" <<'EOF'
## done
EOF

  LABEL="refuses state consensus without --lands-in (A-07)"; SAYING="requires --lands-in"
  refuses --author code --from code --to cowork --state consensus --slug c1 --re "$target"

  # A-09 at level 1. The index has to reach the agent at the moment of writing to
  # the person, not sit in a paragraph. `--from owner` above put a decision on the
  # probe channel, so there is something to find; on an empty one this asserts nothing.
  LABEL="--decisions lists what the person has decided"
  bash "$0" --channel "$probe" --author cowork --from owner --to both --state open \
            --slug a-decision <<'EOF' >/dev/null 2>&1
## ASKED / ANSWERED
they decided
EOF
  checks=$((checks + 1))
  if bash "$0" --channel "$probe" --decisions 2>/dev/null | grep -q 'a-decision'; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  fi

  LABEL="writing to the person puts those decisions in front first (A-09)"
  checks=$((checks + 1))
  if bash "$0" --channel "$probe" --author code --from code --to owner --state open \
             --slug gap <<'EOF' 2>&1 >/dev/null | grep -q 'already decided'
## a gap
EOF
  then printf '  ok    %s\n' "$LABEL"
  else printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1)); fi

  printf 'EXAMINED: %d checks, exercising the shipped writer against %s\n' "$checks" "$probe"
  if [ "$fails" -gt 0 ]; then
    printf 'NOT USABLE HERE: %d of %d checks failed.\n' "$fails" "$checks"
    exit 1
  fi
  printf 'USABLE HERE.\n'
  exit 0
fi

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

# ---------------------------------------------------------------------------
# `settled` has to name what it closes, and name it out of the other message.
#
# A guard that demands a SELECTION beats one that attempts a CLASSIFICATION. The
# first fails loudly when the writer has not looked; the second fails silently
# whenever the text does not resemble the pattern. Measured: a proposed detector
# for "this settled also asks something" -- refuse if the body has a line ending
# in `?` -- fired on 0 of 29 real messages, including both true positives, because
# the buried question was written as prose.
#
# `--closes` never judges. Recall is 100% by construction, and picking the section
# forces a read of the message being closed, which a boolean flag would not.
#
# It also closes M19. Twenty-three decisions by the person were written `settled`
# with `re: -`, and the derivation excludes `settled`, so all twenty-three were
# invisible to the other agent -- one answer arrived nine minutes before an agent
# asked the same thing again. A decision that opens work is not closed: it is
# `open`, addressed to whoever has to act, and now it cannot be written otherwise.
# ---------------------------------------------------------------------------
if [ "$STATE" = "settled" ]; then
  if [ -z "$CLOSES" ]; then
    echo "gtd-msg: state settled requires --closes '<text from the message it closes>'." >&2
    echo "  settled means closed. If this opens work, it is --state open addressed to whoever acts." >&2
    exit 2
  fi
  if [ "$RE" = "-" ]; then
    echo "gtd-msg: --closes needs --re naming the message being closed" >&2; exit 2
  fi
  if [ ! -f "$CHANNEL/$RE" ]; then
    echo "gtd-msg: --re names $CHANNEL/$RE, which does not exist" >&2; exit 2
  fi
  if hit=$(grep -i -m1 -e "^#.*$CLOSES" "$CHANNEL/$RE" 2>/dev/null); then
    echo "gtd-msg: closes heading -- $hit" >&2
  elif hit=$(grep -i -m1 -e "$CLOSES" "$CHANNEL/$RE" 2>/dev/null); then
    echo "gtd-msg: closes line -- $(printf '%s' "$hit" | cut -c1-72)" >&2
  else
    echo "gtd-msg: --closes '$CLOSES' does not appear in $RE. Quote it from that message." >&2
    exit 2
  fi
fi

# `consensus` that never leaves the channel is a decision living outside the project.
# Measured: an approved sprint plan lived a full day in a channel that is outside version
# control. The field is required here; whether the path exists and is tracked is a
# different question, and `channel-status.sh --audit` is where it gets asked.
if [ "$STATE" = "consensus" ] && [ -z "$LANDS_IN" ]; then
  echo "gtd-msg: state consensus requires --lands-in <path> -- the permanent file this changes." >&2
  echo "  If it changes no file, it is not a consensus about the work: use --state open." >&2
  exit 2
fi

mkdir -p "$CHANNEL"

# A-09 at level 1: the query runs here, not in a paragraph somebody has to recall.
if [ "$TO" = "owner" ] || [ "$TO" = "both" ]; then
  idx=$(decision_index "$CHANNEL")
  if [ -n "$idx" ]; then
    echo "gtd-msg: before this reaches them, what they have already decided:" >&2
    printf '%s\n' "$idx" >&2
    echo "gtd-msg: if one of those answers what you just wrote, correct it with a new message." >&2
  fi
fi

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
  if [ -n "$CLOSES" ]; then echo "closes: $CLOSES"; fi
  if [ -n "$LANDS_IN" ]; then echo "lands-in: $LANDS_IN"; fi
  echo "head: $HEAD"
  echo "---"
  echo
  cat
} > "$MSG"

echo "$MSG"
