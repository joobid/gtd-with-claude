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

**The column is called *self-reported* and not *observed*, and the word is the point.** Each agent
can observe its own side and nothing else; the other row records what somebody said. A `yes`
written in January still reads `yes` in March after somebody uninstalled it. It is the same
distinction `head: clock:` makes against `head: sha:` — a value with a date and no way to check it
from here.

> **Every session compares its own side against its row before doing anything else.** Agreeing
> costs nothing and produces nothing. **Disagreeing goes in the channel as a message with
> `state: open` and `to: owner`, and the agent does not edit this file.**

Those two front-matter values are not decoration. Without them the correction is visible only in
`ls -1 | tail -20` — that is, for the next twenty messages — and then it is invisible to every
query this method documents. With them it shows up in the open-questions query until somebody
resolves it, which is the whole point of writing it down.

That last clause is deliberate and it was got wrong once. Letting each agent correct its own row
would give this file **two writers**, which is exactly the shape `protocol.md` rejects for a shared
status file — *"a one-slot resource with two writers… a collision waiting for a bad moment"*. The
rows are per-agent, so a collision would be rare rather than impossible, and *rare* is not the
standard this method holds anything else to.

So the state is **derived**, like everything else here: this table is what was set up, and a later
`from: <agent>` message correcting a row is the fresher fact. The person folds it back into this
file when they next touch it. One writer, no locking, and the same rule that makes `re:` work.

Where an agent's answer is `no`, it cannot open `reference/protocol.md` and works from the two
files copied into the channel. That is a supported configuration, not a broken one — but the other
agent has to know, because it changes what that agent can be asked to consult.

| | |
|---|---|
| Installed, and what came back | `<path to log  /  not attempted>` |

**An install is a verdict handed down from outside the project, and it leaves nothing behind
unless somebody catches it.** Everything else this method records is an event *inside* the work —
a command, a check, a decision — and there is a rule for each. An install, an upload, a publish,
a gate refusing: those happen elsewhere and come back as a yes or a no, and the answer is
reconstructed from memory a week later if nobody wrote it down.

So the same rule as the floor: **never claim it installs without a path.** Attempt it, paste back
what the installer said, verbatim, and put the file next to this one.

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

## The floor — not configurable, and honest about what enforces it

Refused regardless of anything above. The reason is written because a limit whose reason is not
stated gets argued with later.

| Class | Why | Mechanism |
|---|---|---|
| Real or personal data, privacy, rewriting history | Reverting does not undo it, and the failure is silent — a barrier that has stopped seeing something reports what a clean barrier reports | `attempted, not verified — <path>` |
| Destructive actions with no inverse | Delegation assumes a mistake is recoverable. Archive instead of deleting and it leaves this class | `attempted, not verified — <path>` |
| Spending money | The agents do not hold the mandate. The error leaves an account, not a file | `none — agreement only` |
| Anything reaching a third party | The person's name is on it, and it cannot be recalled by deciding it was a mistake | `none — agreement only` |

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
# What waits on the person: anything addressed to them that nothing has answered.
answered=$(grep -hE '^re: +' 2*.md | awk '{print $2}' | grep -v '^-$' | sort -u)
for f in $(grep -lE '^to: +(owner|both)$' 2*.md); do
  grep -qE '^state: +(open|escalated)$' "$f" || continue
  echo "$answered" | grep -qx "$(basename "$f")" || echo "$f"
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

**The probe row is not paperwork.** Over an empty channel the script prints nothing and looks
correct, so an installation confirmed against an empty channel has confirmed nothing.

## What this does not do

No file wakes anyone up, and the reviewing agent cannot answer a permission prompt — those are
modal and live inside the other tool's interface. It does know one happened, because the channel
records it. What disappears is the copying and the risk of transcription, not the turn-taking.

With the per-turn notice above, one side is told automatically **when the person types**. A message
written mid-milestone surfaces at that agent's next turn rather than immediately, and the other
agent has no equivalent unless its tool offers one. Both limits go in the table, not in a footnote.
