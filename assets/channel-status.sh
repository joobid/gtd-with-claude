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

# The version this file IS. A deployed copy lives outside the skill tree by design, so
# until this constant existed nothing could ask a running script which release it came
# from. Measured the day it was missing: a skill upgraded to 0.8.0 left both executables
# byte-for-byte at 0.7.0 -- identical to the previous release's assets, not drifted -- and
# both agents read documentation for two flags their machine did not have. The install log
# had the evidence and nobody read it as one: 18 assertions in the asset's selftest, 13 in
# the deployed one, same day, same page.
GTD_VERSION="0.9.0"

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
    --audit)   MODE=audit; RUNS="${2:-}"; if [ -n "${2:-}" ] && [ "${2#-}" = "$2" ]; then shift 2; else RUNS=""; shift; fi ;;
    --accept)  ACCEPT=1;   shift ;;
    --fyi)     MODE=fyi;   shift ;;
    --delegation) MODE=deleg; shift ;;
    --blocked) MODE=blocked; shift ;;
    --balance) MODE=balance; shift ;;
    --version) echo "channel-status.sh $GTD_VERSION"; exit 0 ;;
    --paths)   PATHS="$2"; shift 2 ;;
    -h|--help) sed -n '3,38p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "channel-status: unknown argument: $1" >&2; exit 2 ;;
  esac
done
MODE="${MODE:-notice}"; RUNS="${RUNS:-}"; ACCEPT="${ACCEPT:-0}"; PATHS="${PATHS:-gtd-config.md}"

# ---------------------------------------------------------------------------
# Is what runs here the same as what the skill ships?
#
# Step 4 copies this file and the writer OUT of the skill tree on purpose: the
# implementing tool cannot read the reviewing tool's plugin cache, so an asset that lives
# only there cannot be executed from the other side. Correct, and it creates two files
# with independent lives and no way to notice they have separated. Upgrading the skill
# upgrades the DOCUMENTATION BOTH AGENTS READ and touches NOTHING EITHER OF THEM RUNS.
#
# IT FAILS OPEN, and that direction is the whole design. In Cowork the skill lives under a
# regenerated temporary path, so "I cannot find the asset" and "the asset differs" are
# different facts and only the second is worth a line. A checker that shouted at the first
# would be switched off inside a week, which is the fate of every rule that obstructs safe
# work -- this file already says that about the declared-scope check.
#
# It reports. It does not deploy, and it must not: `.claude/**` is the person's row in
# every configuration this method writes, so redeployment waits for their turn.
#
# THE HASH COMMAND IS NOT THE SAME ON BOTH PLATFORMS, and the first version of this got it
# wrong in the direction that says nothing: `command -v sha256sum || return 0` fails open
# on macOS, where the command is `shasum -a 256` -- so the check never ran at all on the
# platform the person uses, silently, in the release that added it. This file already
# carried the correct pattern a hundred lines below, in the A-20 scanner.
hash_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" 2>/dev/null | cut -d' ' -f1
  elif command -v shasum   >/dev/null 2>&1; then shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1
  fi
}
version_drift() {
  self=$(hash_of "$0")
  [ -n "$self" ] || return 0
  for d in "$PWD/.claude/skills/gtd-with-agents" "$HOME/.claude/skills/gtd-with-agents"; do
    a="$d/assets/$(basename "$0")"
    [ -f "$a" ] || continue
    theirs=$(hash_of "$a")
    [ -n "$theirs" ] || return 0
    [ "$self" = "$theirs" ] && return 0
    av=$(sed -n 's/^GTD_VERSION="\(.*\)"$/\1/p' "$a" | head -1)
    echo "DRIFT: this is $GTD_VERSION and the installed skill ships ${av:-an unlabelled version}." >&2
    echo "  running: $0" >&2
    echo "  shipped: $a" >&2
    echo "  Redeploy BOTH this and gtd-msg.sh, or neither: one writes a header the other reads." >&2
    return 0
  done
  return 0
}

# A-02 at level 1. `grep -l '^state: open' *.md` returned 33 where there were 32, three
# times in eighteen hours across three sessions: the channel keeps its own README, and
# that README documents the vocabulary with a line starting `state: open` in column 0, so
# it counts itself. Nobody was careless -- the glob was wrong and looked right.
# One helper, so a count cannot drift from the derivation that uses it.
messages() { ls -1 "$1"/2*.md 2>/dev/null || true; }

# Age in hours from a message's own filename. TWO DATE IMPLEMENTATIONS, and the difference
# is silent: `date -u -d` is GNU and macOS has no `-d` at all, so every age fell through
# the fallback and printed 0h on the platform the person uses. Not a crash -- a column of
# zeros that reads like a fresh channel, which is worse. BSD needs `-j -f <format>`.
age_h() {
  ts="$1"                                   # YYYYMMDD-HHMMSS from the filename
  d="${ts%%-*}"; t="${ts#*-}"
  hm="$(echo "$d" | cut -c1-8) $(echo "$t" | cut -c1-2):$(echo "$t" | cut -c3-4)"
  then_s=$(date -u -d "$hm" +%s 2>/dev/null \
        || date -u -j -f "%Y%m%d %H:%M" "$hm" +%s 2>/dev/null \
        || echo "")
  if [ -z "$then_s" ]; then echo "?"; return 0; fi
  echo $(( ( $(date -u +%s) - then_s ) / 3600 ))
}

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
  #
  # RFC 2606 is matched on the domain SUFFIX. Anchoring it to the exact domain flagged
  # `dev@mail.example.org` and `alguien@servidor.invalid` on a real directory: two false
  # positives in a scanner whose whole value is that a hit means something.
  mhits=$(grep -rhoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$RUNS" 2>/dev/null \
          | grep -vEi '@([a-z0-9.-]*\.)?(example\.(com|net|org)|test|invalid|localhost)$' \
          | sort -u || true)
  # The check letter, not the shape. A value that cannot belong to anybody is not a
  # finding, and this is the same boundary RFC 2606 draws for addresses: not a list of
  # things we trust, a set that by construction is nobody's.
  ihits=$(grep -rhoE '\b[0-9]{8}[A-HJ-NP-TV-Z]\b' "$RUNS" 2>/dev/null | sort -u \
          | awk 'BEGIN{t="TRWAGMYFPDXBNJZSQVHLCKE"}
                 {n=substr($0,1,8)+0; if (substr(t, n%23+1, 1) == substr($0,9,1)) print}' || true)

  # Values already reviewed are recorded as HASHES, never as values. That is the whole
  # design: an exception list holding the real strings would be the one place in the tree
  # nothing scans -- which is exactly where a real identifier hid the last time somebody
  # remediated one. A hash cannot leak what it exempts, and a new value has a new hash.
  SEEN="$RUNS/.a20-reviewed"
  if command -v sha256sum >/dev/null 2>&1; then H() { sha256sum | cut -c1-16; }
  else H() { shasum -a 256 | cut -c1-16; }; fi
  new=""; known=0
  for v in $mhits $ihits; do
    h=$(printf '%s' "$v" | H)
    if [ -f "$SEEN" ] && grep -q "^$h" "$SEEN" 2>/dev/null; then
      known=$((known + 1))
    else
      new="$new$h  $v"$'\n'
    fi
  done
  nnew=$(printf '%s' "$new" | grep -c . || true)

  echo "  files scanned:        $files"
  echo "  distinct values:      $((known + nnew))   reviewed: $known   NEW: $nnew"
  echo "EXAMINED: two patterns over $files files under $RUNS, minus RFC 2606 domains and"
  echo "  identifiers whose check letter is invalid."
  echo "NOT EXAMINED: names, addresses, phone numbers, bank details, and any identifier"
  echo "  whose shape this does not know. A clean result here is not a clean directory."
  if [ "$nnew" -gt 0 ]; then
    echo
    printf '%s' "$new" | sed 's|^|  NEW  |'
    echo
    echo "  Outside version control is not outside disk: talking about a value copies it"
    echo "  here, and removing it from the tree does not remove it from here."
    echo "  Redact what is real, then record the rest as reviewed:"
    echo "      channel-status.sh --audit $RUNS --accept"
    fails=$((fails + 1))
  fi
  if [ "$ACCEPT" = 1 ]; then
    printf '%s' "$new" | cut -d' ' -f1 | grep . >> "$SEEN" 2>/dev/null || true
    echo "  recorded $nnew hashes in $SEEN. The values themselves are not written anywhere."
    fails=0
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

  # A-20. A scanner is trusted only after it has been seen to fire, and the fixture has
  # to carry a value the scanner should ACTUALLY flag. It used to use `example.org`, which
  # RFC 2606 reserves -- so the moment the suffix exemption was fixed, this assertion went
  # red for the right reason: the fixture was asserting on a value that is nobody's.
  printf 'contact: alguien@dominio-real.es\n' > "$probe/run.log"
  out20=$(bash "$0" --channel "$probe" --audit "$probe" 2>&1 || true)
  assert "--audit flags an address that is not RFC 2606 (A-20)" "$out20" "NEW.*dominio-real"
  assert "--audit exempts RFC 2606 by suffix, not exact domain (A-20)" \
         "$(printf 'x: dev@mail.example.org\n' > "$probe/run2.log"; \
            bash "$0" --channel "$probe" --audit "$probe" 2>&1 || true)" "NEW: *1"

  # --- 0.8.0: the acknowledgement, and broadcast told apart from addressed ---
  # The fixture already has 000001 addressed to code and 000007 broadcast to both, so
  # both assertions run against messages that were there before this round.
  assert "says how many of the queue are broadcast rather than addressed (M25)" \
         "$out" "addressed, .*broadcast to both"

  # An ack by code must take it out of code's queue AND leave it in cowork's. Testing
  # only the first half would pass on an implementation that dropped the message for
  # everyone, which is the version of this feature worth refusing.
  #
  # E has to be `to: both`, and the first version of this used thread A, which is
  # `to: code`. It was therefore never in cowork's queue, and the second assertion went
  # red -- correctly, against a fixture that could not express the defect. Same shape as
  # the A-20 note above: an assertion is only worth what its fixture can show.
  w 20260101-000011-cowork-e-note  cowork both -                                 open      "broadcast to both"
  printf -- '---\nfrom: code\nto: cowork\nre: -\nstate: open\nack: 20260101-000011-cowork-e-note.md\nhead: clock:x\n---\n\n## read it\n' \
    > "$probe/20260101-000012-code-ack.md"
  assert "a broadcast message is in the other agent's queue to begin with" \
         "$(bash "$0" --channel "$probe" --me cowork 2>&1 || true)" "000011-cowork-e-note"
  acked_out=$(bash "$0" --channel "$probe" --me code 2>&1) || true
  checks=$((checks + 1))
  if printf '%s' "$acked_out" | grep -q '000011-cowork-e-note'; then
    printf '  FAIL  an ack takes the message out of the acknowledging side queue\n'; fails=$((fails + 1))
  else
    printf '  ok    an ack takes the message out of the acknowledging side queue\n'
  fi
  assert "and leaves it in the other side's, because the queue is per agent" \
         "$(bash "$0" --channel "$probe" --me cowork 2>&1 || true)" "000011-cowork-e-note"
  rm -f "$probe/20260101-000011-cowork-e-note.md" "$probe/20260101-000012-code-ack.md"

  # The method's half of the smell test. Over a fixture dated 2026-01-01 today's count is
  # zero, and zero is the correct answer -- what is asserted is that it names the half it
  # did not examine, which is the property that keeps it honest.
  assert "--balance names the half it cannot see (M30)" \
         "$(bash "$0" --channel "$probe" --me code --balance 2>&1 || true)" "NOT EXAMINED"

  # --- 0.9.0: action is labelled, never filtered; and the drift check ------
  # F is `action: none` and it must still appear. A version of this feature that dropped
  # it would pass every other assertion here, which is exactly why this one exists.
  printf -- '---\nfrom: cowork\nto: both\nre: -\nstate: open\nfyi: true\naction: none\nhead: clock:x\n---\n\n## nobody has to move\n' \
    > "$probe/20260101-000013-cowork-f-noaction.md"
  fout=$(bash "$0" --channel "$probe" --me code 2>/dev/null) || true
  assert "action: none is still shown -- labelled, never filtered (M25)" \
         "$fout" "000013-cowork-f-noaction"
  assert "and the header counts how many declared it" "$fout" "declare action: none"
  rm -f "$probe/20260101-000013-cowork-f-noaction.md"

  assert "--version reports the constant this file carries (M32)" \
         "$(bash "$0" --version 2>&1)" "channel-status.sh $GTD_VERSION"

  # The drift check has to be seen NOT firing where there is nothing to compare against,
  # because failing open is the property that keeps it installed. Asserting only that it
  # fires would pass on a version that shouts on every Cowork session, where the skill
  # lives under a regenerated temporary path.
  quiet=$(bash "$0" --channel "$probe" --me code 2>&1 >/dev/null) || true
  checks=$((checks + 1))
  if printf '%s' "$quiet" | grep -q DRIFT; then
    printf '  FAIL  the drift check stays silent when there is no asset to compare (M32)\n'
    fails=$((fails + 1))
  else
    printf '  ok    the drift check stays silent when there is no asset to compare (M32)\n'
  fi

  # And seen firing, against a planted skill tree carrying a different file. A checker
  # never observed to fire is not evidence, including this one.
  # Planted under a fake HOME rather than by cd-ing into the probe: `$0` may be relative,
  # and changing directory under it makes `bash "$0"` fail to find the script at all --
  # which reads exactly like the check not firing. Caught by this assertion on its first
  # run, which is the assertion doing its job on itself.
  fake="$probe/.claude/skills/gtd-with-agents/assets"; mkdir -p "$fake"
  sed 's/^GTD_VERSION=.*/GTD_VERSION="9.9.9"/' "$0" > "$fake/$(basename "$0")"
  loud=$( HOME="$probe" bash "$0" --channel "$probe" --me code 2>&1 >/dev/null ) || true
  assert "and it fires when the shipped asset differs (M32)" "$loud" "DRIFT: this is"
  assert "naming the version the skill ships" "$loud" "9\.9\.9"
  rm -rf "$probe/.claude"

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

# Bounded delegation, derived from two conditions in AND: an acceptance recorded in the
# channel, and a branch that exists and is unmerged in git. The second lives in version
# control; the channel usually does not, so neither alone is the answer.
#
# An orphaned window needs no timeout -- a new sprint brings its own rule -- so this
# prints how long it has been open with nothing happening and leaves the judgement out.
# What is stopped, DERIVED. `blocks:` is prospective and per-question -- an agent writes it
# while asking something, meaning "if you do not answer, X stops". What the person asks is
# retrospective and aggregate: "how much is stopped and why". Different measurements, and
# only the first existed. Accumulation is not born of a question, so nobody writes a
# `blocks:` for it.
#
# Measured the day this was found: the field said five declared, all answered, zero live
# blocks -- correct by the field, and false. On disk at that moment: 22 uncommitted files,
# 8 unmerged branches carrying 105 commits, 7 of 9 `--decide` unanswered.
#
# And the counts that WERE reported came from reading and remembering: 11 files, then 21,
# and there were 22; "a branch with nine commits" when it was eight branches with 105. The
# exact numbers are two commands nobody ran. `blocks:` is not retired -- it covers the
# prospective case and covers it well.
#
# The owner column is what makes this readable. Without it the report says "105 commits in
# 8 branches" and the person has to ask which are theirs. Most are not.
# What is stopped, DERIVED FROM THE CHANNEL. `blocks:` is prospective and per-question --
# written while asking, meaning "if you do not answer, X stops". What the person asks is
# retrospective and aggregate, and accumulation is not born of a question, so nobody writes
# a `blocks:` for it. Measured: the field said zero live blocks while 7 of 9 `--decide`
# messages had no reply anywhere down their chain.
#
# `blocks:` is not retired -- it covers the prospective case and covers it well.
#
# THE GIT HALF IS DELIBERATELY ABSENT. Uncommitted files, unmerged branches and open PRs
# are the larger part of what is stopped on a real project, and they belong to the project
# rather than here: `git-annex.md` opens by saying the method works without version
# control, and a core script that reads git would make that false. A first version of this
# did read git, and without a repository it printed two lines and stopped.
if [ "$MODE" = blocked ]; then
  [ -d "$CHANNEL" ] || { echo "BLIND: $CHANNEL is not a directory. This is not a pass." >&2; exit 2; }
  cd "$CHANNEL"
  n=$(ls -1 2*.md 2>/dev/null | grep -c . || true)
  [ "$n" -gt 0 ] || { echo "BLIND: no messages under $CHANNEL. This is not a pass." >&2; exit 2; }
  nd=0
  for f in $(grep -l '^decide:' 2*.md 2>/dev/null || true); do
    grep -lq "^re: $f\$" 2*.md 2>/dev/null && continue
    nd=$((nd + 1))
    age=$(age_h "$f")
    printf '  decide  %4sh  %s\n' "$age" "$f"
  done
  # The declared field, checked against reality rather than trusted. It fails both ways:
  # it misses what nobody declared, and it holds what has already been resolved.
  st=0
  for f in $(grep -l '^blocks:' 2*.md 2>/dev/null || true); do
    if grep -lq "^re: $f\$" 2*.md 2>/dev/null; then
      st=$((st + 1))
      printf '  stale   blocks: %s  (answered, and the field still says it blocks)\n' "$f"
    fi
  done
  parked=$(grep -lc '^parked:' 2*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "EXAMINED: $n messages. $nd decides unanswered, $st declared blocks already resolved,"
  echo "  $parked parked."
  echo "NOT EXAMINED: uncommitted files, unmerged branches, open PRs. Those are the larger"
  echo "  part of what is stopped and they live in version control, which this method does"
  echo "  not require. Derive them in the project."
  exit 0
fi

# The smell test, which was stated and never derived. `SKILL.md` says that if the
# method's artefacts outnumber the project's at the close of a session, the method ate the
# session -- both halves are countable and neither was counted, so the test fired only when
# an agent happened to re-read the file that states it. Measured on the day that happened:
# 27 channel messages, 2 project files touched, and the day's first-in-order work never
# started.
#
# ONLY THE METHOD'S HALF IS DERIVED HERE, and that is the whole design. The project's
# artefacts live in version control, which this method does not require -- `git-annex.md`
# opens by saying so, and a core script reading git would make it false. The half nobody
# had is this one: how many messages did I write today. The other is one command in the
# project, and it is named rather than guessed at.
#
# It is a warning and not a verdict. A full day of review legitimately produces many
# messages and no files -- SKILL.md says so two paragraphs above the test itself -- and no
# count can tell that apart from a session that ate itself. What it does is put the
# question in front of you instead of waiting for you to remember the rule.
if [ "$MODE" = balance ]; then
  [ -d "$CHANNEL" ] || { echo "BLIND: $CHANNEL is not a directory. This is not a pass." >&2; exit 2; }
  today=$(date -u +%Y%m%d)
  # Authorship, not `from:`. A message recorded with `--record` carries `from: owner` and
  # was still typed by this agent, so it is one of its artefacts. The author is only in
  # the filename, which is the same match the queue's own split uses.
  mine=$(ls -1 "$CHANNEL/$today"-*"-$ME-"*.md 2>/dev/null | grep -c . || true)
  all=$(ls -1 "$CHANNEL/$today"-*.md 2>/dev/null | grep -c . || true)
  echo "EXAMINED: $CHANNEL for $today. $mine message(s) written by you, $all on the channel."
  echo "NOT EXAMINED: what the project gained today. That is the other half of the test and"
  echo "  it lives in version control, which this method does not require. Count it there."
  echo "THE TEST: if the method's artefacts outnumber the project's, the method ate the"
  echo "  session. It is a warning, not a verdict -- a day of review is many messages and"
  echo "  no files, and no count tells that apart from a session that ate itself."
  exit 0
fi

if [ "$MODE" = deleg ]; then
  [ -d "$CHANNEL" ] || { echo "BLIND: $CHANNEL is not a directory. This is not a pass." >&2; exit 2; }
  acc=$(cd "$CHANNEL" && grep -lE '^delegation: +accepted$' 2*.md 2>/dev/null | tail -1 || true)
  br=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  merged=""
  if [ -n "$br" ] && [ "$br" != HEAD ]; then
    git merge-base --is-ancestor HEAD origin/main 2>/dev/null && merged=yes || merged=no
  fi
  echo "EXAMINED: $CHANNEL for an acceptance, and git for an unmerged branch."
  if [ -z "$acc" ]; then
    echo "  DELEGATION: closed. No message carries delegation: accepted."
    echo "  Approving a plan enables nothing. The person accepts the mode separately, or"
    echo "  the previous one stands -- it fails closed."
    exit 0
  fi
  echo "  accepted by:  $acc"
  echo "  branch:       ${br:-none}   merged into origin/main: ${merged:-unknown}"
  if [ "$merged" = yes ] || [ -z "$br" ] || [ "$br" = main ]; then
    echo "  DELEGATION: closed. The window is the life of a branch."
  else
    d=$(age_h "$acc")
    echo "  DELEGATION: open, ${d}h since it was accepted."
    echo "  Still the person's, always: the merge, approving a plan, accepting a closure,"
    echo "  changing scope, and the permission configuration."
  fi
  exit 0
fi

if [ "$MODE" = fyi ]; then
  [ -d "$CHANNEL" ] || { echo "BLIND: $CHANNEL is not a directory. This is not a pass." >&2; exit 2; }
  cd "$CHANNEL"
  n=$(ls -1 2*.md 2>/dev/null | grep -c . || true)
  [ "$n" -gt 0 ] || { echo "BLIND: no messages under $CHANNEL. This is not a pass." >&2; exit 2; }
  found=0
  for f in $(grep -lE '^fyi: +true$' 2*.md 2>/dev/null || true); do
    h=$(grep -m1 '^#' "$f" 2>/dev/null | sed 's/^#* *//')
    printf '  %s  %s\n' "$f" "$h"
    found=$((found + 1))
  done
  echo "EXAMINED: $n messages. $found marked fyi -- kept out of the queue, never discarded."
  exit 0
fi

version_drift
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

# `fyi: true` says out loud that nothing here needs the person, so it does not sit in
# their queue. It is not discarded: `--fyi` lists exactly these, which is the condition
# for dropping anything out of a queue -- a log with no way to read it is not a control.
# Measured before the guard existed: 13 items waiting on the person, none of them
# carrying an executable block, and the headings were minutes rather than requests.
#
# `fyi: true` is NOT the class to exclude for an agent, and the difference cost a real
# proposal. Measured over one channel: of 74 messages carrying the person's decisions,
# **19 were marked `fyi: true`** -- so excluding `fyi` from the agents' queues removes
# nineteen decisions by the person, one of them a morning instruction requiring an agent
# to act. The flag says *I am not asking the person anything*. What a queue needs is
# *nobody has to act*. One flag, two statements, and no line of shell separates them.
#
# So nothing is excluded for being an FYI here. What takes an item out of an agent's
# queue is that agent having said it read it -- see `ack:` below.
acked=""
for a in $(grep -lE "^from: +$ME\$" 2*.md 2>/dev/null || true); do
  acked="$acked$(sed -n 's/^ack: *//p' "$a" | head -1 | tr ' ' '\n')"$'\n'
done

waiting=""
bcast=0
noact=0
for f in $(grep -lE "^to: +($ME|both)\$" 2*.md 2>/dev/null || true); do
  if grep -qE '^state: +settled$' "$f"; then continue; fi
  if printf '%s' "$closed" | grep -qx "$f"; then continue; fi
  if [ "$ME" = owner ] && grep -qE '^fyi: +true$' "$f"; then continue; fi
  # The ack is a claim and not an observation: an agent can acknowledge thirty files
  # without opening one. It is not verifiable when written and it is citable when it
  # fails, which is the same bargain `head:` makes. Authorship is read from `from:`
  # rather than from the filename, because a slug may contain the other agent's name.
  if printf '%s' "$acked" | grep -qx "$f"; then continue; fi
  grep -qE "^to: +both\$" "$f" && bcast=$((bcast + 1))
  grep -qE "^action: +none\$" "$f" && noact=$((noact + 1))
  waiting="$waiting$f"$'\n'
done

[ -z "$waiting" ] && exit 0
n=$(printf '%s' "$waiting" | grep -c . || true)

# M26: split by who typed it. Measured -- 74% of the reviewing agent's derivation was its
# own messages, against 9% on the implementing side. Not excluded: `to: both` means both,
# and an agent must be able to find its own unanswered proposals. Split, so the reader can
# stop after the first heading. The author is only in the filename; the front matter does
# not record it, which is why this matches on `-$ME-` rather than on a field.
body=$( {
  # `to: both` means BROADCAST and this line used to call all of it "addressed to you",
  # because `^to: +($ME|both)$` is one pattern and reads as one thing. A record left for
  # whoever comes next and a message to somebody are different objects, and merging them
  # is what made an agent propose dropping the whole class. Counted, not dropped: the
  # column below says which each one is, and nothing leaves the queue for being broadcast.
  # `action: none` is counted here and subtracted from nothing. The count is the point:
  # it says how much of the queue has declared that nobody has to move, which is the
  # question `fyi:` was being asked and could not answer.
  echo "CHANNEL: $n open to you -- $((n - bcast)) addressed, $bcast broadcast to both."
  [ "$noact" -gt 0 ] && echo "  $noact of them declare action: none. Nothing is dropped for saying so."
  printf '%s' "$waiting" | grep -v -- "-$ME-" > "${TMPDIR:-/tmp}/cs-other-$$" || true
  printf '%s' "$waiting" | grep -- "-$ME-" > "${TMPDIR:-/tmp}/cs-mine-$$" || true
  for part in other mine; do
    fl="${TMPDIR:-/tmp}/cs-$part-$$"
    [ -s "$fl" ] || continue
    [ "$part" = other ] && echo "  -- written by the other side --" \
                        || echo "  -- yours, that nobody answered --"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    st=$(sed -n 's/^state: *//p' "$f" | head -1)
    # Age, because a --decide from forty hours ago and one from ten minutes ago stop
    # being the same object the moment they are seen next to each other. No new field:
    # the timestamp is already in the filename.
    age=$(age_h "$f")
    reach=to-you; grep -qE "^to: +both\$" "$f" && reach=broadcast
    # `action:` is LABELLED and never filtered. Dropping a message for declaring itself
    # actionless would rebuild the silent hole the field exists to expose, and `--ack`
    # stays the only thing that empties a queue. `-` means nobody stated it, which is a
    # third fact and not a synonym for none.
    act=$(sed -n 's/^action: *//p' "$f" | head -1)
    printf '  %-10s %3sh  %-9s %-6s %s/%s\n' "$st" "$age" "$reach" "${act:--}" "$CHANNEL" "$f"
  done < "$fl"
  done
  rm -f "${TMPDIR:-/tmp}/cs-other-$$" "${TMPDIR:-/tmp}/cs-mine-$$"
  echo "An open one needs an answer. A consensus one is agreed and not yet done: do it, or"
  echo "close it with a settled whose re: names this file. Only settled closes anything."
  echo "A broadcast one may need nothing: --ack '<file> <file>' takes it out of YOUR queue"
  echo "and leaves it in the other agent's. Acknowledging is not closing."
} )

if [ "$JSON" -eq 1 ]; then
  printf '%s' "$body" | python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.stdin.read()}}))'
else
  printf '%s\n' "$body"
fi
