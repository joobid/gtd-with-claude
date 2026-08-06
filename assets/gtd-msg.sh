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
CLOSES=""; LANDS_IN=""; DECISIONS=""; DECIDE=""; BLOCKS=""; FYI=""; RECORD=""; ACK=""
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
    --decide)  DECIDE="$2";  shift 2 ;;
    --blocks)  BLOCKS="$2";  shift 2 ;;
    --fyi)     FYI=1;        shift ;;
    --record)  RECORD=1;     shift ;;
    --ack)     ACK="$2";     shift 2 ;;
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
    elif [ -n "${SAYING:-}" ] && ! printf '%s' "$err" | grep -q -- "$SAYING"; then
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
  refuses --author code --from owner --to both --state settled --slug d1 --fyi

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
            --slug a-decision --fyi <<'EOF' >/dev/null 2>&1
## ASKED / ANSWERED
they decided
EOF
  checks=$((checks + 1))
  if bash "$0" --channel "$probe" --decisions 2>/dev/null | grep -q 'a-decision'; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  fi

  # Stderr goes to a file and the file gets grepped, rather than a heredoc feeding a
  # command inside an `if` condition with a pipe. That shape works on bash 5 and fails
  # on bash 3.2 -- which is what macOS ships, so it failed for the first person to run
  # it and passed everywhere it was developed. The check was sound and the harness was
  # not, and the two are indistinguishable from the word FAIL: the feature had to be
  # probed by hand to tell them apart. Same shape as the awk that aborts under one
  # implementation and not another, this time inside this file's own self-test.
  LABEL="writing to the person puts those decisions in front first (A-09)"
  checks=$((checks + 1))
  bash "$0" --channel "$probe" --author code --from code --to owner --state open \
            --slug gap --fyi >/dev/null 2>"$probe/.a09.err" <<'EOF'
## a gap
EOF
  if grep -q 'already decided' "$probe/.a09.err" 2>/dev/null; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  fi

  # --- Nothing reaches disk until the body is in hand ----------------------
  # The incident: a 198-byte `settled` with a valid `closes:` and an empty body, which
  # closed a thread and cannot be corrected because the channel is append-only.
  LABEL="refuses an empty body, and writes nothing"; SAYING="body is empty"
  refuses --author cowork --from cowork --to code --slug empty

  LABEL="an interrupted write leaves no file at all"
  checks=$((checks + 1))
  kdir="$probe/killdir"; mkdir -p "$kdir"
  ( bash "$0" --channel "$kdir" --author cowork --from cowork --to code --slug k \
      < <(sleep 5) >/dev/null 2>&1 ) &
  kpid=$!
  sleep 1; kill -TERM $kpid 2>/dev/null || true; wait $kpid 2>/dev/null || true
  if [ "$(ls -1 "$kdir" 2>/dev/null | wc -l | tr -d ' ')" -eq 0 ]; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"
    printf '        fix: report this -- a header was written before the body arrived\n'
    fails=$((fails + 1))
  fi
  rm -rf "$kdir"

  # An stdin that never ends wrote 686 MB into a channel before a timeout killed it,
  # found while probing the case above rather than by reading the code.
  # The cap is lowered for the assertion rather than 260 KB being generated to meet it.
  # The first version of this fed 20,000 lines of `filler` -- 140,000 bytes, comfortably
  # UNDER the cap -- so it failed, and the failure was in the fixture, not the guard. A
  # test that has to guess a magic size will keep guessing it wrong; this one sets it.
  LABEL="refuses a body over the cap"; SAYING="cap"
  bigdir="$probe/big"; mkdir -p "$bigdir"
  checks=$((checks + 1))
  if yes "filler" | head -2000 | GTD_MAX_BODY=1000 bash "$0" --channel "$bigdir" --author cowork \
       --from cowork --to code --slug big >/dev/null 2>&1; then
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  elif [ "$(ls -1 "$bigdir" 2>/dev/null | wc -l | tr -d ' ')" -eq 0 ]; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  fi
  rm -rf "$bigdir"

  # --- B-09: what reaches the person says which of two things it is -------
  LABEL="refuses a message to the person with neither --decide nor --fyi"; SAYING="--decide"
  refuses --author cowork --from cowork --to owner --slug b9a

  LABEL="refuses --decide with nothing named as blocked"; SAYING="requires --blocks"
  refuses --author cowork --from cowork --to owner --slug b9b --decide "A or B"

  LABEL="and it covers to: both, which was 10 of the 13 measured"; SAYING="--decide"
  refuses --author cowork --from cowork --to both --slug b9c

  LABEL="accepts --fyi, which stays out of their queue"
  accepts --author cowork --from cowork --to owner --slug b9d --fyi <<'EOF'
## nothing here needs you
EOF

  # --- 0.7.0 -------------------------------------------------------------
  # Cheapest satisfying input for each, named as the round requires. All three are
  # accepted because what they let through is VISIBLY thin -- four stub headings read
  # as four stub headings. The failure they replace was invisible: a flag whose text
  # said the opposite of the truth, and options sitting complete in the channel while
  # the chat got a pointer to them.
  LABEL="refuses --record unless --from is owner"; SAYING="must be owner"
  refuses --author cowork --from cowork --to both --slug r1 --record

  # Needs a body: the empty-body guard is also a content check and fires first, so
  # `refuses` with </dev/null would report a refusal for the wrong reason.
  LABEL="refuses a --decide missing the four sections"
  secdir="$probe/sec"; mkdir -p "$secdir"
  checks=$((checks + 1))
  if printf '## something\nprose\n' | bash "$0" --channel "$secdir" --author cowork \
       --from cowork --to owner --slug r2 --decide "A or B" --blocks "x" >/dev/null 2>&1; then
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  elif [ "$(ls -1 "$secdir" 2>/dev/null | wc -l | tr -d ' ')" -eq 0 ]; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  fi
  rm -rf "$secdir"

  # --- 0.8.0: the acknowledgement -----------------------------------------
  # Three assertions, and the third is the one that matters. An --ack naming a file
  # that does not exist has to be refused, or a typo acknowledges nothing and says so
  # to nobody -- the silent pass this whole script is built against.
  LABEL="refuses --ack naming a message that does not exist"; SAYING="not a message under"
  refuses --author code --from code --to cowork --slug a1 --ack "20260101-000000-nobody-nothing.md"

  LABEL="refuses --ack on a settled: acknowledging is not closing"; SAYING="not closing"
  refuses --author code --from code --to cowork --state settled --slug a2 \
          --re "$target" --closes "The thing being asked" --ack "$target"

  LABEL="accepts --ack naming a real message, and records it in the front matter"
  checks=$((checks + 1))
  ackout=$(bash "$0" --channel "$probe" --author code --from code --to cowork \
                     --slug a3 --ack "$target" <<'EOF' 2>&1
## read it
EOF
  ) || true
  if [ -f "$ackout" ] && grep -qE "^ack: .*$target" "$ackout"; then
    printf '  ok    %s\n' "$LABEL"
  else
    printf '  FAIL  %s\n' "$LABEL"; fails=$((fails + 1))
  fi

  printf 'EXAMINED: %d checks, exercising the shipped writer against %s\n' "$checks" "$probe"
  # Said rather than implied. The tty guard is real and one line long, and the obvious
  # way to assert it -- run the writer under `script` with a fake terminal -- hangs the
  # whole suite against any build that still waits on stdin, which is exactly the build
  # you would be testing. `script`'s flags differ between macOS and Linux on top of that.
  # An assertion that can hang is worse than one nobody wrote, so this one is declared
  # missing instead of being written badly.
  printf 'NOT EXAMINED: the terminal guard. Try it by hand: run the writer with no heredoc.\n'
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

# ---------------------------------------------------------------------------
# Anything reaching the person says which of two things it is.
#
# `to: owner` meant both *decide this* and *for your information*, and nothing told them
# apart, so both counted the same as pending. Measured on a real channel: 13 items waiting
# on the person, **0 of them carrying an executable block**, with headings like "What this
# settles" and "I recorded X as decided". Minutes, not requests.
#
# `--decide` also requires `--blocks`: if you cannot name what stops until they answer, it
# is not a decision, it is information. That is a selection guard like `--closes` -- it
# never classifies, it makes you pick.
#
# It covers `both` as well as `owner`, and that is not tidiness: of those 13, **10 were
# `to: both` and 3 were `to: owner`**, so a guard on `owner` alone would have reached
# under a quarter of the queue it exists for.
# ---------------------------------------------------------------------------
if [ "$TO" = "owner" ] || [ "$TO" = "both" ]; then
  n_kinds=0
  [ -n "$DECIDE" ] && n_kinds=$((n_kinds + 1))
  [ -n "$FYI" ]    && n_kinds=$((n_kinds + 1))
  [ -n "$RECORD" ] && n_kinds=$((n_kinds + 1))
  if [ "$n_kinds" -gt 1 ]; then
    echo "gtd-msg: --decide, --fyi and --record are three cases. Pick one." >&2; exit 2
  fi
  if [ "$n_kinds" -eq 0 ]; then
    echo "gtd-msg: a message reaching the person needs --decide '<the choice>', --fyi or --record." >&2
    echo "  --fyi   nothing here needs them" >&2
    echo "  --record  their own words, written down by whoever heard them" >&2
    exit 2
  fi
  # `--record` is `from: owner` by construction: it is the person speaking, transcribed.
  # Measured the day it was missing: all 13 records written that day carried `--fyi`, whose
  # text says *nothing here needs you* -- false in the other direction, because it IS them.
  # Ten of them then carried a hand-written line explaining what the flag really meant.
  # A guard satisfied at minimum cost is the level-2 failure mode, and this was it.
  # Cheapest satisfying input, and the note this replaces covered the OLD harm rather
  # than the one the flag creates. `--from owner` on something that is not the person's
  # words now enters the decision index, and both agents treat an entry there as settled.
  # The risk existed before -- `from: owner` already fed that index -- but the friction
  # just dropped, and a guard that lowers the cost of a wrong claim owes that sentence.
  # Accepted, because the alternative is worse: without the flag, all thirteen records in
  # one day carried `--fyi`, whose text says the opposite of the truth.
  if [ -n "$RECORD" ] && [ "$FROM" != "owner" ]; then
    echo "gtd-msg: --record is for the person's own words, so --from must be owner." >&2; exit 2
  fi
  if [ -n "$DECIDE" ] && [ -z "$BLOCKS" ]; then
    echo "gtd-msg: --decide requires --blocks '<what stops until they answer>'." >&2
    echo "  If nothing stops, it is not a decision -- it is information. Use --fyi." >&2
    exit 2
  fi
fi

# ---------------------------------------------------------------------------
# --ack: the only thing that takes a broadcast out of an agent's queue.
#
# The obvious design is a clock -- drop broadcast FYIs after N days -- and its failure
# mode is that an FYI nobody read disappears in silence while the queue reports itself
# smaller. That is a control whose failure mode is to report success, which is the shape
# this whole method is written against. Gate it on an acknowledgement and the failure
# inverts: unread means it stays.
#
# It is a CLAIM, not an observation, and that is its correct form. An agent can
# acknowledge thirty files without opening one. It is not verifiable when written -- it is
# CITABLE when it fails, the moment that agent asks something an acknowledged message
# answered, because both files are on a channel that is never edited. Same class as
# `head:`, which does not prevent a stale read and makes one detectable afterwards.
#
# A header field on an ordinary message, never a side file. The derivation already closes
# by citation over a header field and the writer already emits the front matter one line
# per key, so the field costs one line at each end; a `.ack-<agent>` file would invent a
# storage class outside the protocol, need the same derivation change, and be mutable
# where a message is not. One message can acknowledge thirty, so the cost argument does
# not favour the file either.
#
# NO GRACE PERIOD, and that is a decision rather than an omission. Queues are per-agent:
# when A acknowledges, it leaves A's queue and B's is untouched. A delay after the ack
# only buys a window in which an agent is still nagged by something it has declared read.
#
# The guard is a SELECTION, like --closes: every name must be a message that exists. A
# typo that silently acknowledged nothing would be the same silent pass as everything
# else here.
# ---------------------------------------------------------------------------
if [ -n "$ACK" ]; then
  if [ "$STATE" = settled ]; then
    echo "gtd-msg: --ack says you read it. --state settled says it is closed." >&2
    echo "  Acknowledging is not closing: a thread both agents have read is still open." >&2
    exit 2
  fi
  for a in $ACK; do
    if [ ! -f "$CHANNEL/$a" ]; then
      echo "gtd-msg: --ack names $a, which is not a message under $CHANNEL." >&2
      echo "  Name the files as the derivation prints them. An ack for nothing is silent." >&2
      exit 2
    fi
  done
fi

# ---------------------------------------------------------------------------
# The body is read in full BEFORE anything is created on disk.
#
# It used to stream: `{ echo header...; cat; } > "$MSG"` opened the file and wrote the
# front matter, then waited on stdin. Anything that went wrong from there left a file
# that is a complete, well-formed, permanently empty message -- and the channel is
# append-only, so it cannot be fixed, only answered.
#
# Measured on a real channel: a 198-byte `state: settled` with a valid `closes:` and a
# body of zero bytes. It closed a thread. Every guard this writer has passed cleanly,
# because all seven of them check the envelope and none checks the contents.
#
# Two routes produce it and both were reproduced: an empty stdin, and an interruption
# between the header and the end of `cat`. A third appeared while probing -- an stdin
# that never ends wrote 686 MB into the channel before the timeout -- so the read is
# capped as well. Holding the body in memory first turns all three into a refusal.
# ---------------------------------------------------------------------------
if [ -t 0 ]; then
  echo "gtd-msg: stdin is a terminal. The body is read from stdin:" >&2
  echo "    gtd-msg.sh ... --slug x <<'EOF'" >&2
  echo "    ## heading" >&2
  echo "    EOF" >&2
  exit 2
fi

BODY=$(head -c "${GTD_MAX_BODY:-262144}")
if [ "$(printf '%s' "$BODY" | wc -c)" -ge "${GTD_MAX_BODY:-262144}" ]; then
  echo "gtd-msg: body reached the ${GTD_MAX_BODY:-262144}-byte cap and was not written." >&2
  echo "  A message is a message, not a log. Put the output in a run log and cite its path." >&2
  exit 2
fi

# The minimum member of the family of guards that check CONTENT rather than envelope.
# A settled that closes a thread with nothing in it is the incident this exists for.
if [ -z "$(printf '%s' "$BODY" | tr -d '[:space:]')" ]; then
  echo "gtd-msg: the body is empty. Nothing was written." >&2
  echo "  A message with a correct envelope and no contents passes every other guard here" >&2
  echo "  and cannot be corrected afterwards, because the channel is append-only." >&2
  exit 2
fi

# What reaches the person has a fixed shape, and the shape is what does the work.
# Style cannot be mechanised -- detecting "no adjectives that do not change a decision"
# is a classifier, and this series has the case of one that fired on 0 of 29 messages
# including both it existed to catch. Four required sections and a word cap leave no
# room for narration, which is a different thing from forbidding it.
#
# Cheapest satisfying input: four headings with a word under each. Accepted, because it
# is visibly empty -- a reader sees four stubs and knows. The failure this replaces was
# not visible: options and costs sitting complete in the channel while the chat got
# "the three options are in the channel with their cost". The template cannot make
# somebody think; it can stop them handing over a pointer instead of the thing.
if [ -n "$DECIDE" ]; then
  miss=""
  printf '%s' "$BODY" | grep -qi "what you have to do\|qué tienes que hacer" || miss="$miss 1"
  printf '%s' "$BODY" | grep -qi "options\|opciones"                        || miss="$miss 2"
  printf '%s' "$BODY" | grep -qi "stops\|queda parado\|blocked"            || miss="$miss 3"
  printf '%s' "$BODY" | grep -qi "evidence\|evidencia"                      || miss="$miss 4"
  if [ -n "$miss" ]; then
    echo "gtd-msg: --decide needs the four sections. Missing:$miss" >&2
    echo "  1 what you have to do (or: nothing)   2 options and their cost" >&2
    echo "  3 what stops if you do not answer     4 evidence: a path or a command" >&2
    echo "  The reasoning that produced them stays in the channel. This is what they read." >&2
    exit 2
  fi
# THERE IS NO WORD CAP, and that was decided by measuring rather than by taste. A 400-word
# cap shipped for one round; against the real channel, 8 of 9 `--decide` bodies were over it
# -- 1015, 777, 704, 642, 593, 558, 502, 480, 400. The number had been picked by judgement,
# which is the same class as the guard that fired on 0 of 29.
#
# The deeper reason: a hard cap cannot tell COMPRESSING from HIDING. Faced with 700 words and
# a limit of 400, an agent can write less, split in two, or leave a summary and point at the
# channel for the rest. All three produce a 400-word message, and the third is exactly M23 --
# "the three options are in the channel with their cost" -- the defect the four sections exist
# to close. A cap rewards compressing and hiding equally, and hiding is cheaper.
#
# The complaint it was answering was "paragraphs I cannot follow, with no clear actions", not
# "too much information". Locatable actions, not volume. Nothing caps --record either: those
# are the person's own words, and real ones reach 919.
fi

mkdir -p "$CHANNEL"

# A-09 at level 1: the query runs here, not in a paragraph somebody has to recall.
if [ "$TO" = "owner" ] || [ "$TO" = "both" ]; then
  idx=$(decision_index "$CHANNEL")
  if [ -n "$idx" ]; then
    # AND THE INTERACTION WITH `--record`, which neither change examined on its own.
    # The index now shows 8 of 60. A wrong `from: owner` written twenty decisions ago is
    # invisible by default, where all sixty used to print. Accepted: sixty unread lines
    # caught nothing either -- that was M25 -- and `--decisions` prints the lot on demand.
    # What is genuinely lost is the accidental re-reading of an old entry, and the thing
    # that replaces it is a person correcting a record they can now actually see.
    #
    # Capped, and the cap is a SELECTION rather than a CLASSIFIER. Filtering by relevance
    # -- words of this message against the slugs of the decisions -- was the other option
    # on the table, and this series already has the case: a guard that matched by pattern
    # fired on 0 of 29 real messages, including both it existed to catch. A classifier
    # fails silently on the one that does not look like the rest; a cap degrades legibly,
    # and the count tells you what it is not showing.
    ntot=$(printf '%s\n' "$idx" | grep -c . || true)
    ncap="${GTD_INDEX_CAP:-8}"
    echo "gtd-msg: before this reaches them, what they have already decided ($ntot):" >&2
    printf '%s\n' "$idx" | tail -n "$ncap" >&2
    if [ "$ntot" -gt "$ncap" ]; then
      echo "gtd-msg: showing the $ncap most recent. The rest: gtd-msg.sh --decisions" >&2
    fi
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
  if [ -n "$DECIDE" ]; then echo "decide: $DECIDE"; fi
  if [ -n "$BLOCKS" ]; then echo "blocks: $BLOCKS"; fi
  if [ -n "$FYI" ]; then echo "fyi: true"; fi
  if [ -n "$RECORD" ]; then echo "record: true"; fi
  if [ -n "$ACK" ]; then echo "ack: $ACK"; fi
  echo "head: $HEAD"
  echo "---"
  echo
  printf '%s\n' "$BODY"
} > "$MSG"

echo "$MSG"
