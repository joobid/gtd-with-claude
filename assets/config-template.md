# Working agreement

<!--
  Written by the gtd-with-agents setup. This is a PROJECT FILE, not a chat decision:
  a decision that lives only in a conversation is not a decision, because conversations end.

  Revisit it when the answers stop matching how the work actually goes. A configuration
  nobody has revisited is a configuration nobody is following.
-->

**Set up:** `<date>` · **Last reviewed:** `<date>`

## Language

| | |
|---|---|
| The person is addressed in | `<language>` |
| The channel is written in | **English**, except the `ASKED:`/`ANSWERED:` block of a `from: owner` message, which is in the language the conversation happened in — that block is the only part of this system the person needs to audit, and it is about them |

## The channel

| | |
|---|---|
| Lives at | `<path>` |
| Excluded from version control | `<yes / no / not applicable>` |
| `head:` prefix in use | `<sha: — staleness check available / clock: — no staleness check>` |

## Where the method itself is installed

The two agents read skills from **different stores**, and neither can see the other's. Whether
the skill is loaded over there is an event in another process — so it is recorded here, where
both can read it.

| Agent | Skill available to it | Self-reported |
|---|---|---|
| Reviewing (`<tool>`) | `<yes / no>` | `<date>` |
| Implementing (`<tool>`) | `<yes, at ~/.claude/skills / yes, at .claude/skills / no>` | `<date>` |
| How it got there | `<unzipped from a release / cp -R from the plugin cache / other>` |

**Each side measures itself and publishes the result. Neither fills in the other's row.**

```sh
channel-status.sh --whoami
```

That is a level-1 mechanism and it replaces a rule that failed the first time it was tested: asked
about the *other* side's version, an agent measured **its own store**, reported the number as the
other's, and had no way to notice — because the measurement succeeded. The command answers only
about the side it runs on and says so in its first line.

The column is *self-reported*, not *observed*: a `yes` written in January still reads `yes` in
March after somebody uninstalled it. Same distinction as `head: clock:` against `head: sha:`.

> **Disagreeing with your own row goes in the channel** — `state: open`, `to: owner` — and the
> agent does not edit this file. Two agents correcting their own rows would give it two writers,
> the shape `protocol.md` rejects for a shared status file. The table is what was set up; a later
> message is the fresher fact.

Where an agent's answer is `no`, it works from the two files copied into the channel. Supported,
not broken — but the other agent has to know, because it changes what it can be asked to consult.

| | |
|---|---|
| Installed, and what came back | `<path to log  /  not attempted>` |

**An install is a verdict from outside the project and leaves nothing behind unless somebody
catches it.** Never claim it installed without a path: attempt it, paste back what the installer
said verbatim, and put the file next to this one.

## What the person decides

Eight rows, one per thing the questionnaire asks about.

| Activity | Level | Notes |
|---|---|---|
| Recording and publishing work — checkpoints, branches, merges | `<DECIDE / CONSENSUS / DELEGATED / NOT APPLICABLE — reason>` | |
| Approving a milestone's plan before it starts | `<...>` | |
| Accepting a milestone's closure against its exit criteria | `<...>` | |
| Changing scope once a milestone is running | `<...>` | |
| Installing dependencies | `<...>` | |
| Changing environment configuration | `<...>` | |
| Editing the permission configuration of the tools themselves | `<...>` | An agent that can widen its own limits has advisory limits |
| Choosing between design alternatives when both agents agree | `<...>` | Worth what the verification culture is worth |

**DECIDE** — the person decides every time, before anything happens.
**CONSENSUS** — the two agents agree, act, and report afterwards. One agent alone is not consensus,
and in the channel that means `state: consensus` requires `re:` pointing at the other agent.
**DELEGATED** — the agents act without interrupting. It stays in the record.
**NOT APPLICABLE — `<reason>`** — this project does not do that at all, and **the reason is part
of the value**, written on the same line. Not a note beside it: a bare `NOT APPLICABLE` is
indistinguishable from a row nobody reached, and this file is what gets re-read when the method
drifts. Where one group's answer does not fit all of its rows, the rows differ — that is expected,
and the Notes column says which grouped answer they came from.

## Which paths are always theirs

**Two delegations that both have to hold, and they answer different questions.** The sprint
window says *when* something may be committed; this table says *which files*. Neither replaces
the other.

It exists because failing closed had a cost nobody priced: the sprint delegation covered "that
sprint", the reviewing agent's documentary output belonged to no sprint, and **22 files sat
uncommitted from 07:26** because no agent could touch them.

**A blank table means "everything is delegable", which is nobody's intended default**, so the
setup asks for these rather than leaving them empty. `channel-status.sh --blocked` reads it to
attribute owners, and says BLIND rather than guessing when it is empty.

| Path | | |
|---|---|---|
| `<e.g. prd/**>` | always theirs | explicit confirmation, including the closing `git mv` |
| `<e.g. CLAUDE.md>` | always theirs | |
| `<e.g. gtd-config.md>` | always theirs | |
| `<e.g. .claude/**>` | always theirs | an agent that can edit its own permissions has advisory limits |
| `<e.g. docs/**>` | delegable by consensus | |
| `<e.g. sprints/**>` | delegable by consensus | |
| `<e.g. README.md>` | delegable by consensus | |

**No exception for the closing `git mv`**, on a real decision: the simple rule beat the
lower-friction one.

**And analysis documents whose conclusions end up in a requirements file are NOT gated.** The
gate is the requirements file; gating the analysis reviews the same decision twice.

## Decisions taken about the method itself

Recorded here so a later round does not re-propose something already ruled out, and cannot
re-propose it without seeing the measurement that killed it.

| Date | Decision | The figure behind it |
|---|---|---|
| 2026-08-04 | **No word cap on a message reaching the person.** The four required sections stay | A 400-word cap shipped for one round. Against the real channel, **8 of 9 `--decide` bodies were over it**: 1015, 777, 704, 642, 593, 558, 502, 480, 400. The number had been chosen by judgement, not by measuring — and a cap cannot tell compressing from hiding, where hiding is cheaper and is the defect the sections exist to close |
| `<date>` | `<decision>` | `<figure or path>` |

## The floor — not configurable, and honest about what enforces it

Refused regardless of anything above. The reason is written because a limit whose reason is not
stated gets argued with later.

**Which side each row is enforced on, before the mechanism column.** The permission configuration
belongs to one tool, so a floor written there covers the agent running in that tool and **nothing
else**. Measured: 23 `deny` and 27 `ask` rules that the configuration described as *not
configurable* did not exist for the reviewing agent — proved by running the exact forbidden shape
from that side, with four rules naming it, and nothing appearing. **And the side without a floor
is the one that sees the most third-party data, because reviewing means reading.**

This is not fixable, only declarable. `code only` is the honest default for scope, the way
`attempted, not verified` is for mechanism.

| Class | Enforced on | Why | Mechanism |
|---|---|---|---|
| Real or personal data, privacy, rewriting history | `code only` | Reverting does not undo it, and the failure is silent — a barrier that has stopped seeing something reports what a clean barrier reports | `attempted, not verified — <path>` |
| Destructive actions with no inverse | `code only` | Delegation assumes a mistake is recoverable. Archive instead of deleting and it leaves this class | `attempted, not verified — <path>` |
| Spending money | `neither` | The agents do not hold the mandate. The error leaves an account, not a file | `none — agreement only` |
| Anything reaching a third party | `neither` | The person's name is on it, and it cannot be recalled by deciding it was a mistake | `none — agreement only` |

> **The cells above are pre-filled at the honest default, and that is deliberate.** A blank or a
> `<...>` reads exactly like a row nobody reached, so a floor that was never verified would be
> indistinguishable from a floor nobody got to — which is the defect the verification log is
> shaped to avoid, left in the table it certifies. Raise a row to `verified — <path>` when you
> have watched it refuse; lower it to `none — agreement only` where no mechanism exists.
>
> **`attempted, not verified` is the honest default**, and it is where every row starts. A class
> earns `verified` only once the *other-spelling* request has been seen to refuse too — a deny rule
> matches the text of a command, not the operation, so two rows passing usually means the two
> spellings somebody thought of are the two they tested.

> **Never `verified` without a path to a log.** A floor certification is an event, and an event
> with no artefact is an assertion — the one thing this method does not let anything else get away
> with. `reference/floor-mechanism.md` has the procedure: where the rules live, what to write, the
> five requests that test them, and what an ineffective rule looks like.

> **The Mechanism column is the point of this table.** These four rows are a rule read by the agent
> they restrict, and this method teaches you to distrust exactly that shape — *confirm the
> mechanism, not the document*. Where a deny rule exists, it was **seen to refuse**, not assumed to
> work. Where it says `none — agreement only`, that row is a commitment and not a lock, and saying
> so is what keeps the rest honest.

Nearest safe alternative in all four: **the agents prepare it completely and the person confirms
in one step.**

## Which agent does what

| | |
|---|---|
| Output a check can verify | `<agent / model>` |
| Output no check can verify — argued documents, design, policy, real data | `<agent / model>` |

The criterion is verifiability, not difficulty. Delegation and verification are the same lever.

## Staying informed

| | |
|---|---|
| Reporting rhythm | `<a line per milestone / a summary per session / only when something needs me>` |
| Where it is written | `<path>` |

**"What has happened since yesterday?"** — pick one and adapt it, rather than inventing one per
project, because an invented one is a command nobody has run.

Note the `2*.md`: the channel carries its own `README.md` and `message-template.md`, so a bare
`*.md` lists two documents as though they were messages, in every installation. And `set -o
pipefail`, because `ls | head` reports the exit code of `head`, which is always zero — a block
that cannot fail is a block that tells you nothing when it does.

```sh
set -o pipefail
git log --oneline --since=yesterday
ls -1t .runs/exchange/2*.md | head -20
ls -1t .runs/*.log 2>/dev/null | head -5 || echo "(no run logs yet)"
```

Without a repository:

```sh
set -o pipefail
find . -newermt yesterday -type f -not -path './exchange/*' | head -30
ls -1t exchange/2*.md | head -20
```

**And in either case, what still waits on you.** Not a bare `grep`: because files are immutable,
an answered message keeps its state for ever, so the bare form returns everything ever raised. The
state is derived, so the query has to derive it — and it looks at what is **addressed to you**,
not only at escalations, because escalations are rare by design and a query that returns zero all
day reads as *nothing needs you*.

```sh
cd <channel> || exit 1
n=$(ls -1 2*.md 2>/dev/null | wc -l)
[ "$n" -eq 0 ] && { echo "BLIND: no messages here. Wrong directory, or no channel yet." >&2; exit 2; }
echo "EXAMINED: $n messages"
# What waits on the person: addressed to them, with no `settled` down its own reply chain.
# NOT `open|escalated`: `consensus` is agreed, not done, and filtering it out is how work
# both parties signed off on stops being visible to anyone.
closed=""
for s in $(grep -lE '^state: +settled$' 2*.md); do
  cur="$s"
  while :; do
    p=$(sed -n 's/^re: *//p' "$cur" | head -1)
    if [ -z "$p" ] || [ "$p" = "-" ] || [ ! -f "$p" ]; then break; fi
    case " $closed " in *" $p "*) break ;; esac
    closed="$closed $p"
    cur="$p"
  done
done
for f in $(grep -lE '^to: +(owner|both)$' 2*.md); do
  if grep -qE '^state: +settled$' "$f"; then continue; fi
  case " $closed " in *" $f "*) continue ;; esac
  echo "$f"
done
```

> **Verify it with a probe, not by running it once.** At setup the channel is empty and the project
> has done nothing, so running it returns zero lines and looks like it works — which is the blind
> check this whole method exists to catch. **Write a probe message into the channel and confirm the
> command returns it.** That is the version that cannot pass over an empty input.

## Where decisions land

The channel holds the deliberation. **The project holds the decision.** Any consensus that changes
a plan, a guide, an interface or a scope goes into a permanent file in the same milestone, or it
did not happen.

| Kind of decision | Lands in |
|---|---|
| `<e.g. architecture>` | `<path>` |
| `<e.g. plan or roadmap>` | `<path>` |
| `<e.g. working rules>` | `<path>` |

## Per-turn channel notice

| | |
|---|---|
| Installed for | `<which agent, or none>` |
| How it is wired | `<e.g. UserPromptSubmit hook in .claude/settings.json>` |
| Probed against a non-empty channel | `<path to the run that named real messages / not yet>` |

`assets/channel-status.sh` prints what the channel is holding for one agent, on every turn, and
nothing when there is nothing. It is what stops *"no file wakes anyone up"* from meaning *"the
person has to remember"*.

**It shows `consensus` as well as `open`, and that is the correction of a real defect.** Agreed is
not done: only a `settled` further down a message's own reply chain closes it. Expect the list to
include things both agents already signed off on and neither has carried out — that is what it is
for.

**The probe row is not paperwork.** Over an empty channel the script prints nothing and looks
correct, so an installation confirmed against an empty channel has confirmed nothing. `--selftest`
covers the derivation against a synthetic channel; the probe row covers *this* project's wiring.

## What this does not do

No file wakes anyone up, and the reviewing agent cannot answer a permission prompt — those are
modal and live inside the other tool's interface. It does know one happened, because the channel
records it. What disappears is the copying and the risk of transcription, not the turn-taking.

With the per-turn notice above, one side is told automatically **when the person types**. A message
written mid-milestone surfaces at that agent's next turn rather than immediately, and the other
agent has no equivalent unless its tool offers one. Both limits go in the table, not in a footnote.
