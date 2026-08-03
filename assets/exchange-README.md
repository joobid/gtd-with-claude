# This directory is the channel

Two agents write here so that a person does not have to carry questions and answers between two
sessions by hand.

One **immutable** file per message. Nothing here is ever edited or reopened.

```
YYYYMMDD-HHMMSS-<author>-<slug>.md          author: whoever typed it — code | cowork
```

Every key below is **indented by two spaces on purpose**, and it is not formatting. Written flush
left, this file matches `grep '^state: open' *.md` and counts itself as a message — which is
exactly what happened: 33 where there were 32, three times, in three separate sessions. A document
that describes a format has to be unable to impersonate it.

```
  ---
  from: code | cowork | owner
  to: code | cowork | owner | both
  re: <filename this answers>   (or -)
  state: open | consensus | settled | escalated
  closes: <text quoted from what it closes>   (settled only, required)
  lands-in: <permanent file>                  (consensus only, required)
  head: sha:<commit>  |  clock:<utc timestamp>
  ---
```

`message-template.md`, next to this file, has the command that creates a message. **Use it** —
the timestamp and `head:` are read, never typed.

## Five things to know before writing

**Read before you write.** `ls -1 2*.md | tail -20`. Your question may already be answered.

**The timestamp comes from the clock and `head:` from the project — never from memory.** A message
stamped ahead of the real time sorts in front of the answer that replies to it, and then the
directory is no longer ordered, which is the only property this design leans on. **UTC**, because
the two sessions do not share a machine.

**`head:` says which kind it is.** `sha:` is a property of the project, so a stale answer can be
detected. `clock:` is only when it was written — there is nothing to compare, so do not try.

**`consensus` needs `re:` pointing at the other agent.** One agent writing "we agreed" into its own
front matter is a unilateral claim about two parties. With the constraint the rule is checkable;
without it, it is a hope.

**English, always** — with one exception: in a `from: owner` message the `ASKED:`/`ANSWERED:` block
is written in the language the conversation happened in. That block is the only part of this system
the person needs to audit, and it is about them.

## What the person is asked goes here too

Not only agent-to-agent traffic. **Anything either agent asks the person, and what they answered,
is written here by whichever agent heard it — and read by the other before it proposes anything.**
Filed `from: owner`, `to: both`, `state: settled`, because the information originates with them and
it binds both agents including the one that wrote it down.

Both directions. A permission prompt answered in one session and a scope decision taken in the
other are the same kind of event, and the second is the one that gets forgotten — even though it is
usually the bigger decision.

**Show it back to the person in the turn you write it.** It is a paraphrase about them that both
agents will treat as not reopenable; the one place this method would otherwise act on a summary.

A permission prompt blocks, so it can only be recorded afterwards. Write it immediately rather than
at the end of the session, or it becomes the summary of a decision instead of the decision.

The test for what to record: **would the other agent behave differently if it knew this?**

## Finding what is live

**Ask the script, do not write the query.** Files are immutable, so an answered message says
`state: open` for ever and a bare grep returns every question ever asked. The derivation lives in
one place, with a `--selftest` behind it, because four hand-copied versions of it drifted apart
while every one of them looked right.

```sh
channel-status.sh --channel . --me code|cowork|owner
channel-status.sh --channel . --count
gtd-msg.sh --channel . --decisions
```

**Never count with a glob.** `grep -l '^state: open' *.md` returns one too many: this README
documents the vocabulary, so it counts itself. That produced three wrong counts in eighteen hours
across three sessions. `--count` excludes non-messages, and every derivation uses the same helper.

```sh
ls -1 2*.md | tail -20                   # the last twenty messages, in order
```

**Not `escalated` alone.** Two agents that exchange facts instead of escalating produce almost no
escalations — a full day of real use produced zero, while three messages addressed to the person
sat unanswered, one of them a red command block. A query restricted to escalations returns nothing
all day, and nothing reads as *nothing needs you*.

An escalation is closed by a message `from: owner` whose `re:` points at it.

**When this gets long**, move closed threads into a dated subdirectory at a milestone boundary —
`archive/2026-08/`. The queries run on the top level, nothing is deleted, and the daily view stops
growing.

## What this directory is not

**It is not the record.** It holds the deliberation. Every consensus that changes a plan, a guide,
an interface or a scope has to land in a permanent project file in the same milestone, or it did
not happen.

Where this directory sits inside ignored working output, it does not survive a fresh copy of the
project. That is deliberate.

**It wakes nobody up.** Each agent reads it when its turn comes round. What disappears is the
copying, not the waiting.

**It does not reach a permission prompt.** Those are modal and live inside a tool's own interface.
Questions go through here; approvals stay with the person.
