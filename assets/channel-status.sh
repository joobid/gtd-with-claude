#!/usr/bin/env bash
#
# Print what the channel is holding for this agent, as one short block, and nothing at
# all when there is nothing.
#
# It exists because of a sentence this method got half right. "No file wakes anyone up"
# is true about notifications and was being read as true about attention, and those are
# different things. Between *no push* and *the person has to remember* there is a step,
# and the person doing the remembering is the cable coming back.
#
# Wire it to whatever your tool fires on every turn. In Claude Code that is a
# `UserPromptSubmit` hook, which takes no matchers and injects text through
# `hookSpecificOutput.additionalContext`:
#
#   channel-status.sh --channel "$CLAUDE_PROJECT_DIR/.runs/exchange" --me code --json
#
# Without --json it prints plain text, which is what a tool that just wants stdout needs.
#
# READ ONLY. It never writes.
#
# WHAT COUNTS AS PENDING: addressed to me, not itself `settled`, and with no descendant
# along the `re:` chain that is `settled`. Nothing else closes a message.
#
# The first version of this closed on being *answered*, and on `open|escalated` alone. Both
# were wrong in the same direction and it took a real channel to see it. `consensus` means
# the two agents agreed; it says nothing about the work having happened, so a thread could
# end in agreement with nobody having done the thing. Until this script existed, that cost
# nothing -- no state got more attention than any other. The moment a hook started reading
# the channel every turn, `open` became the state that gets seen and `consensus` the state
# that does not, and agreed-but-unexecuted work went systematically invisible.
#
# Measured on a 64-message channel: the old derivation surfaced 2 messages, the new one 9.
# Four of the nine are noise -- threads settled somewhere other than on the reply chain --
# and that is accepted deliberately. In a check whose failure mode is silence, coverage
# beats precision: a false positive costs one line and is cleared by writing the `settled`
# that was missing, which is the behaviour we want anyway. The false negative it replaces
# hid three agreed-and-unimplemented requirements of a privacy guard.
#
# --selftest runs it against a synthetic channel that contains that exact case.

set -euo pipefail

CHANNEL="${GTD_CHANNEL:-.runs/exchange}"
ME="code"
JSON=0
SELFTEST=""

while [ $# -gt 0 ]; do
  case "$1" in
    --channel) CHANNEL="$2"; shift 2 ;;
    --me)      ME="$2";      shift 2 ;;
    --json)    JSON=1;       shift ;;
    --selftest) SELFTEST=1;  shift ;;
    --count)   MODE=count;   shift ;;
    --whoami)  MODE=whoami;  shift ;;
    --audit)   MODE=audit; RUNS="${2:-}"; if [ -n "${2:-}" ]; then shift 2; else shift; fi ;;
    -h|--help) sed -n '3,38p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "channel-status: unknown argument: $1" >&2; exit 2 ;;
  esac
done
MODE="${MODE:-notice}"; RUNS="${RUNS:-}"

# A-02 at level 1. `grep -l '^state: open' *.md` returned 33 where there were 32, three
# times in eighteen hours across three sessions: the channel keeps its own README, and
# that README documents the vocabulary with a line starting `state: open` in column 0, so
# it counts itself. Nobody was careless -- the glob was wrong and looked right.
# One helper, so a count cannot drift from the derivation that uses it.
messages() { ls -1 "$1"/2*.md 2>/dev/null || true; }

if [ "$MODE" = count ]; then
  n=$(messages "$CHANNEL" | grep -c . || true)
  other=$(ls -1 "$CHANNEL"/*.md 2>/dev/null | grep -cv '/2[0-9]' || true)
  echo "EXAMINED: $CHANNEL"
  echo "  messages:     $n"
  echo "  not messages: $other  (README and template -- never counted, never grepped as messages)"
  exit 0
fi

# A-08 at level 1. Each side can observe its own store and nothing else. An agent asked
# about the other side's install measured its OWN and reported it as the other's -- and it
# had no way to notice, because the measurement succeeded. So the only honest instrument
# measures this side and hands you a line to publish; the other side publishes its own.
if [ "$MODE" = whoami ]; then
  found=""; v=""
  for d in "$HOME/.claude/skills/gtd-with-agents" ".claude/skills/gtd-with-agents"; do
    if [ -d "$d" ]; then
      found="$found $d"
      if [ -z "$v" ]; then
        v=$(sed -n 's/^  version: *//p' "$d/SKILL.md" 2>/dev/null | head -1)
      fi
    fi
  done
  echo "EXAMINED: this side only. Nothing here can see the other agent's store."
  if [ -z "$found" ]; then
    echo "  gtd-with-agents: not installed on this side"
  else
    echo "  gtd-with-agents:${found}  version ${v:-unknown}"
  fi
  echo "  Publish this as a message. Do not write it into the other agent's row."
  exit 0
fi

# A-07 and A-20 at level 3: what cannot be refused at the moment of the act, but can be
# found afterwards -- on the condition C attaches, that an alarm with no scheduled reading
# is not a control. This is the reading. It belongs at a milestone boundary.
if [ "$MODE" = audit ]; then
  fails=0
  echo "=== consensus that never landed (A-07) ==="
  n=0; bad=0
  for f in $(messages "$CHANNEL"); do
    p=$(sed -n 's/^lands-in: *//p' "$f" | head -1)
    [ -n "$p" ] || continue
    n=$((n + 1))
    if [ ! -e "$p" ]; then
      echo "  MISSING   $p   ($(basename "$f"))"; bad=$((bad + 1))
    elif git ls-files --error-unmatch "$p" >/dev/null 2>&1; then
      echo "  tracked   $p"
    else
      echo "  UNTRACKED $p   ($(basename "$f"))"; bad=$((bad + 1))
    fi
  done
  echo "EXAMINED: $n messages carrying lands-in, $bad of them not in version control"
  [ "$bad" -eq 0 ] || fails=$((fails + 1))

  echo
  echo "=== personal data in the run directory (A-20) ==="
  if [ -z "$RUNS" ]; then RUNS=$(dirname "$CHANNEL"); fi
  if [ ! -d "$RUNS" ]; then
    echo "  BLIND: $RUNS is not a directory. This is not a pass."
    exit 2
  fi
  files=$(find "$RUNS" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "$files" -gt 0 ] || { echo "  BLIND: no files under $RUNS. This is not a pass."; exit 2; }
  # Each grep is captured on its own line, and the no-match case is made explicit.
  # Piping grep straight into wc under `set -o pipefail` kills the script when there
  # is nothing to find: exit 1 propagates, the assignment fails, and the report stops
  # mid-section looking finished. The empty result is the common path, so the scanner
  # died silently exactly when it had good news -- found by running it, not by reading it.
  mhits=$(grep -rlE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$RUNS" 2>/dev/null || true)
  ihits=$(grep -rhoE '\b[0-9]{8}[A-HJ-NP-TV-Z]\b' "$RUNS" 2>/dev/null | sort -u || true)
  mail=$(printf '%s' "$mhits" | grep -c . || true)
  idn=$(printf '%s' "$ihits" | grep -c . || true)
  echo "  files scanned:            $files"
  echo "  files containing an email:  $mail"
  echo "  distinct national-ID shapes: $idn"
  echo "EXAMINED: two patterns over $files files under $RUNS."
  echo "NOT EXAMINED: names, addresses, phone numbers, bank details, and any identifier"
  echo "  whose shape this does not know. A clean result here is not a clean directory."
  if [ "$mail" -gt 0 ] || [ "$idn" -gt 0 ]; then
    echo
    echo "  This directory is normally outside version control, so the project's own barrier"
    echo "  has never looked at it. Outside git is not outside disk: talking about a value"
    echo "  copies it here, and removing it from the tree does not remove it from here."
    fails=$((fails + 1))
  fi
  echo
  [ "$fails" -eq 0 ] && { echo "AUDIT CLEAN on what it examined."; exit 0; }
  echo "AUDIT: $fails of 2 areas need a decision."
  exit 1
fi
# `owner` is here because "what is waiting on the person" is the objective this whole method
# promises, and it is the same derivation with a different audience. Leaving it out meant the
# only way to ask it was a hand-written query that nobody kept in step with this one.
case "$ME" in code|cowork|owner) ;; *) echo "channel-status: --me must be code, cowork or owner" >&2; exit 2 ;; esac

if [ -n "$SELFTEST" ]; then
  # The fixture is the finding. Four threads, each a shape the derivation has to tell
  # apart, and the first one is the case that went invisible in the field.
  probe="${TMPDIR:-/tmp}/channel-status-selftest-$$"
  rm -rf "$probe"; mkdir -p "$probe"
  trap 'rm -rf "$probe"' EXIT
  w() { printf -- '---\nfrom: %s\nto: %s\nre: %s\nstate: %s\nhead: clock:x\n---\n\n## %s\n' \
        "$2" "$3" "$4" "$5" "$1" > "$probe/$1.md"; }

  # Thread A is the field case, reproduced in its real shape: cowork asks, code replies,
  # cowork agrees -- and nobody ever does the thing or writes a closing note.
  w 20260101-000001-cowork-a-ask    cowork code   -                                 open      "ask"
  w 20260101-000002-code-a-reply    code   cowork 20260101-000001-cowork-a-ask.md   open      "reply"
  w 20260101-000003-cowork-a-agree  cowork code   20260101-000002-code-a-reply.md   consensus "agreed, not done"
  # B closes properly.
  w 20260101-000004-cowork-b-ask    cowork code   -                                 open      "ask"
  w 20260101-000005-code-b-close    code   cowork 20260101-000004-cowork-b-ask.md   settled   "done"
  # C is the accepted noise: a decision settled without naming what it closes.
  w 20260101-000006-cowork-c-ask    cowork code   -                                 open      "ask"
  w 20260101-000007-owner-c-decide  owner  both   -                                 settled   "closes nothing"
  # D is not this agent's business.
  w 20260101-000008-code-d-ask      code   cowork -                                 open      "not for code"

  out=$(bash "$0" --channel "$probe" --me code 2>&1) || true
  fails=0; checks=0
  expect() {
    checks=$((checks + 1))
    if printf '%s' "$out" | grep -q "$2"; then r=hit; else r=miss; fi
    if [ "$r" = "$1" ]; then printf '  ok    %s\n' "$3"
    else printf '  FAIL  %s\n' "$3"; fails=$((fails + 1)); fi
  }

  expect hit  '000003-cowork-a-agree' 'a consensus nobody closed stays pending  <- THE FINDING'
  expect hit  '000001-cowork-a-ask'   'and so does its ancestor, since no descendant settled'
  expect miss '000004-cowork-b-ask'   'a thread with a settled reply is closed'
  expect miss '000005-code-b-close'   'the settled message itself is not pending'
  expect hit  '000006-cowork-c-ask'   'a settled with re: - closes nothing (accepted noise)'
  expect miss '000008-code-d-ask'     'a message addressed to the other agent is not shown'

  # --me owner is the query the method exists for, so it gets an assertion of its own.
  # The `to: both` decision reaches the person; nothing addressed to code alone does.
  own=$(bash "$0" --channel "$probe" --me owner 2>&1) || true
  checks=$((checks + 1))
  if printf '%s' "$own" | grep -q '000001-cowork-a-ask'; then
    printf '  FAIL  --me owner does not pick up messages addressed to the agents\n'
    fails=$((fails + 1))
  else
    printf '  ok    --me owner does not pick up messages addressed to the agents\n'
  fi

  # --- Added this round, each with its positive control ---------------------
  assert() {
    checks=$((checks + 1))
    if printf '%s' "$2" | grep -q "$3"; then printf '  ok    %s\n' "$1"
    else printf '  FAIL  %s\n' "$1"; fails=$((fails + 1)); fi
  }

  # A-02. The README goes in carrying the exact line that caused three wrong counts,
  # in column 0. If the count is 8 the non-messages were excluded; if it is 9 they
  # were not. Without this file in the fixture the assertion proves nothing.
  printf -- '# Channel\n\nstate: open | consensus | settled | escalated\n' > "$probe/README.md"
  assert "counts messages and never the README (A-02)" \
         "$(bash "$0" --channel "$probe" --count 2>&1)" "messages: *8"

  assert "--whoami says out loud that it measured this side only (A-08)" \
         "$(bash "$0" --whoami 2>&1)" "this side only"

  # A-07 level 3: a lands-in path that does not exist has to be named.
  printf -- '---\nfrom: code\nto: cowork\nre: -\nstate: consensus\nlands-in: docs/nowhere.md\nhead: clock:x\n---\n\n## c\n' \
    > "$probe/20260101-000009-code-lands.md"
  assert "--audit names a lands-in path that is not there (A-07)" \
         "$(bash "$0" --channel "$probe" --audit "$probe" 2>&1 || true)" "MISSING *docs/nowhere.md"

  # A-20. A scanner is trusted only after it has been seen to fire, so the fixture
  # carries one address of the shape it looks for.
  printf 'contact: someone@example.org\n' > "$probe/run.log"
  assert "--audit finds an address left in the run directory (A-20)" \
         "$(bash "$0" --channel "$probe" --audit "$probe" 2>&1 || true)" "containing an email: *1"

  # And the failure mode that matters more than any hit: nothing to look at must not
  # read as nothing to find.
  empty="${TMPDIR:-/tmp}/cs-empty-$$"; mkdir -p "$empty"
  assert "--audit aborts on an empty directory instead of approving" \
         "$(bash "$0" --channel "$empty" --audit "$empty" 2>&1 || true)" "BLIND"
  rmdir "$empty" 2>/dev/null || true

  printf 'EXAMINED: %d assertions over %d messages in a synthetic channel at %s\n' \
         "$checks" "$(ls -1 "$probe"/2*.md | wc -l | tr -d ' ')" "$probe"
  [ "$fails" -eq 0 ] || { printf 'NOT CORRECT HERE: %d of %d failed.\n' "$fails" "$checks"; exit 1; }
  printf 'CORRECT HERE.\n'
  exit 0
fi

[ -d "$CHANNEL" ] || exit 0
cd "$CHANNEL"
# `2*.md` and not `*.md`: the channel carries its own README and message template, and a
# bare glob counts both as messages. Same reason the documented queries use it.
ls -1 2*.md >/dev/null 2>&1 || exit 0

# Closure propagates upward. Every `settled` message closes its parent, that parent's
# parent, and so on to the root of its own reply chain -- and nothing else. A `settled`
# with `re: -` therefore closes nothing, which is not a bug: on the real channel 9 of 24
# settled messages were `re: -`, because a decision recorded with `from: owner` opens a
# topic rather than answering one.
closed=""
for s in $(grep -lE '^state: +settled$' 2*.md 2>/dev/null || true); do
  cur="$s"; depth=0
  while [ "$depth" -lt 500 ]; do
    depth=$((depth + 1))
    parent=$(sed -n 's/^re: *//p' "$cur" | head -1)
    [ -n "$parent" ] || break
    [ "$parent" != "-" ] || break
    [ -f "$parent" ] || break
    if printf '%s' "$closed" | grep -qx "$parent"; then break; fi
    closed="$closed$parent"$'\n'
    cur="$parent"
  done
done

waiting=""
for f in $(grep -lE "^to: +($ME|both)\$" 2*.md 2>/dev/null || true); do
  if grep -qE '^state: +settled$' "$f"; then continue; fi
  if printf '%s' "$closed" | grep -qx "$f"; then continue; fi
  waiting="$waiting$f"$'\n'
done

[ -z "$waiting" ] && exit 0
n=$(printf '%s' "$waiting" | grep -c . || true)

body=$( {
  echo "CHANNEL: $n message(s) addressed to you that nothing has closed."
  printf '%s' "$waiting" | while IFS= read -r f; do
    [ -n "$f" ] || continue
    st=$(sed -n 's/^state: *//p' "$f" | head -1)
    printf '  %-10s %s/%s\n' "$st" "$CHANNEL" "$f"
  done
  echo "An open one needs an answer. A consensus one is agreed and not yet done: do it, or"
  echo "close it with a settled whose re: names this file. Only settled closes anything."
} )

if [ "$JSON" -eq 1 ]; then
  printf '%s' "$body" | python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.stdin.read()}}))'
else
  printf '%s\n' "$body"
fi
