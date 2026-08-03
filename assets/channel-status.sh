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
# READ ONLY. It never writes, and it is the same derivation the documented queries use:
# addressed to me, still open or escalated, minus anything a later `re:` closes.

set -euo pipefail

CHANNEL="${GTD_CHANNEL:-.runs/exchange}"
ME="code"
JSON=0

while [ $# -gt 0 ]; do
  case "$1" in
    --channel) CHANNEL="$2"; shift 2 ;;
    --me)      ME="$2";      shift 2 ;;
    --json)    JSON=1;       shift ;;
    -h|--help) sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "channel-status: unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$ME" in code|cowork) ;; *) echo "channel-status: --me must be code or cowork" >&2; exit 2 ;; esac

[ -d "$CHANNEL" ] || exit 0
cd "$CHANNEL"
# `2*.md` and not `*.md`: the channel carries its own README and message template, and a
# bare glob counts both as messages. Same reason the documented queries use it.
ls -1 2*.md >/dev/null 2>&1 || exit 0

answered=$(grep -hE '^re: +' 2*.md 2>/dev/null | awk '{print $2}' | grep -v '^-$' | sort -u || true)
waiting=""
for f in $(grep -lE "^to: +($ME|both)\$" 2*.md 2>/dev/null || true); do
  grep -qE '^state: +(open|escalated)$' "$f" || continue
  printf '%s\n' "$answered" | grep -qx "$f" || waiting="$waiting$f"$'\n'
done

[ -z "$waiting" ] && exit 0
n=$(printf '%s' "$waiting" | grep -c . || true)

body=$( {
  echo "CHANNEL: $n message(s) addressed to you that nothing has answered."
  printf '%s' "$waiting" | sed "s|^|  $CHANNEL/|"
  echo "Read them before proposing anything. Answer with re: pointing at the filename."
} )

if [ "$JSON" -eq 1 ]; then
  printf '%s' "$body" | python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.stdin.read()}}))'
else
  printf '%s\n' "$body"
fi
