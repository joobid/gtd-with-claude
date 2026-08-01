# Working agreement

<!--
  Written by the gtd-with-claude setup. This is a PROJECT FILE, not a chat decision:
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
| Real or personal data, privacy, rewriting history | Reverting does not undo it, and the failure is silent — a barrier that has stopped seeing something reports what a clean barrier reports | `<verified — path/to/log  /  attempted, not verified — path/to/log  /  none — agreement only>` |
| Destructive actions with no inverse | Delegation assumes a mistake is recoverable. Archive instead of deleting and it leaves this class | `<...>` |
| Spending money | The agents do not hold the mandate. The error leaves an account, not a file | `<...>` |
| Anything reaching a third party | The person's name is on it, and it cannot be recalled by deciding it was a mistake | `<...>` |

> **Never `verified` without a path to a log.** A floor certification is an event, and an event
> with no artefact is an assertion — the one thing this method does not let anything else get away
> with. `reference/floor-mechanism.md` has the procedure: where the rules live, what to write, the
> four requests that test them, and what an ineffective rule looks like.

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
project, because an invented one is a command nobody has run:

```sh
git log --oneline --since=yesterday
ls -1t .runs/exchange/*.md | head -20
ls -1t .runs/*.log | head -5
```

Without a repository:

```sh
find . -newermt yesterday -type f -not -path './exchange/*' | head -30
ls -1t exchange/*.md | head -20
```

**And in either case, what still needs the person.** Not a bare `grep`: because files are
immutable, a resolved escalation still says `state: escalated` for ever, so the bare form returns
every escalation ever raised. The state is derived, so the query has to derive it.

```sh
cd <channel> || exit 1
closed=$(grep -lE '^from: +owner$' *.md | xargs -r grep -hE '^re: +' | awk '{print $2}' | sort -u)
for f in $(grep -lE '^state: +escalated$' *.md); do
  echo "$closed" | grep -qx "$(basename "$f")" || echo "$f"
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

## What this does not do

No file wakes anyone up, and the reviewing agent cannot answer a permission prompt — those are
modal and live inside the other tool's interface. It does know one happened, because the channel
records it. What disappears is the copying and the risk of transcription, not the turn-taking.
