# The channel

A directory, not a protocol. One **immutable** file per message.

```
<channel>/YYYYMMDD-HHMMSS-<author>-<slug>.md        author: code | cowork
```

Front matter, five keys, all of them greppable:

```
---
from: code | cowork | owner
to: code | cowork | owner | both
re: <filename this message answers>   (or -)
state: open | consensus | settled | escalated
head: sha:<commit> | clock:<utc timestamp>
---
```

Everything else is the body: prose, commands, output, whatever the message needs.

**The `<author>` in the filename is whoever typed the file** — the session that wrote it. It can
differ from `from:`, which is the person for a recorded decision. That way `ls -1` stays readable
by session while `grep -E '^from: +owner$'` stays readable by decision.

### `from:` is a closed list of three roles, and nobody else writes here

**`code`, `cowork`, `owner`. There is no fourth value and none is being added.** A session that is
not one of the project's two agents, and is not the person, **does not write to this channel** —
however good its reason. What it has to say goes to the person, in conversation, and they decide
whether it becomes a message. If it does, they are the sender, because the decision to say it was
theirs.

This is written down because the silence was resolved the wrong way. A session working on a
different repository had a finding for one of the agents here, found no value that described it,
and **wrote as `cowork`** — borrowing the identity of a party it was not. Nothing refused it: the
writer enforces the enum, and `cowork` is in the enum.

The cost is not etiquette. Every query in this method derives on `from:` and `to:`, so a borrowed
sender is a message the derivations attribute to an agent that never said it — and the two
sessions reading that channel now hold a fact from a party neither can question, wearing the name
of one they can. `grep -lE '^from: +cowork$'` cannot tell the difference, and neither can the
agent whose name was used.

**The rule that follows, and it is one line:** if you cannot honestly write one of the three
values, you are not a participant in this channel. Say it to the person instead.

---

## Why each choice, because none of them is arbitrary

### One file per message, never edited

Overwriting a file is the wide scope of writing files. `>` and in-place editing replace the whole
archive, not the part you meant to change — and nothing notices, because the tools that watch a
project watch *which* files changed, not *how much* of each.

A message that can be rewritten is a record that can lose most of itself without anyone seeing.
So nothing here is ever reopened: a correction is a new file that answers the old one.

### `ls -1` is the ordering, not the index

Timestamp-first names sort chronologically, so the listing is ordered and complete. There is
nothing to keep in sync, and a hand-maintained index would fail the moment somebody forgot — and
fail silently, because **a hand-maintained list measures whoever wrote it, not the directory.**

What `ls` gives you is *order*. What is still **open** is a different question, and it needs a
real query — see "Finding what is live" below. Sorting is not answering.

### `re:` instead of a status file

An open question is a message with `state: open` that no later message answers. The state of the
conversation is therefore **derived**, not stored.

A shared status file would be a one-slot resource with two writers. Two agents editing one file is
a collision waiting for a bad moment, and the moment it collides is the moment you needed it.

### `head:` says what the message was written against — and says which kind

Cowork verifies state, and state moves. An answer written against a project that has since
changed says nothing about the project as it is now, **and it looks exactly like an answer that
does**.

So `head:` is **prefixed with what kind of identifier it is**, because the two are not
interchangeable:

| | | |
|---|---|---|
| `sha:9f3c1a2` | A property of the project | A staleness check is possible: if it no longer matches, the answer is stale |
| `clock:20260801T115200Z` | A property of the moment, not the project | **No staleness check.** It records when, not against what |

This distinction is not decoration either. A bare timestamp compared for equality never matches,
because two clocks read at different moments always differ — so a rule that says "re-ask if
`head:` no longer matches" would make every message stale and produce an unbounded loop of
re-asking. With the prefix, the rule applies where it can and is silent where it cannot.

**Without a project-state identifier, the core does not offer a staleness check.** That is a real
limitation, stated rather than papered over: see `git-annex.md`, which is where the check comes
from. If a project has some other stable identifier for its state — a build number, a release
tag, a content hash over what it cares about — use it and prefix it accordingly.

### The timestamp is read from the clock, and both are UTC

Both fields are generated, and **a generated field is read from its source, never typed from
memory**. This is the one rule that keeps the two properties everything else rests on.

A message stamped five minutes ahead of the real time sorts *in front of* the answer that replies
to it. The directory stops being ordered, and `ls -1` stops being ordered with it — which is the
single assumption the whole design leans on. It does no damage on a quiet morning and silently
inverts the record on a busy one.

**UTC on both, and this is specific to this method's shape:** the two sessions run in different
environments with no guarantee of a shared timezone — one in a container, one on the person's
machine. Local time puts one session's messages hours away from the other's and the ordering
inverts between the only two participants there are.

So the file is created by a command that reads both, not by a hand that remembers them.
`message-template.md` carries that command, and it is copied into the channel so that **every
agent has it** — a rule that points at a tool the reader cannot reach is prose, and nothing reads
prose.

**A value asserted instead of measured, in the one place nobody inspects because "it is only the
filename", is the same defect as any other asserted number** — and harder to catch, because
filenames do not look like claims.

This rule exists because it happened on the first day the channel was used. The method producing a
correction to its own protocol on day one is the strongest thing that can be said for it.

### Always English, with one exception that is not a loophole

Whatever language the person chose for themselves, these files are written in English. They are
how two agents synchronise, they get searched with plain text tools, and one convention beats two.

**The exception: in a `from: owner` message, the `ASKED:` and `ANSWERED:` block is written in the
language the conversation actually happened in.** Everything else in the message — the front
matter, the surrounding explanation — stays English.

The reason is narrow and worth stating, because the original rule was justified with *"they are
not for the person"*. That was true when the channel carried only agent-to-agent traffic. It
stopped being true the moment the person's own decisions started being recorded here, and the
rule was not revisited. A person whose only record of their own decisions is in a language they do
not read cannot audit it — and the method promises to keep them informed.

---

## The four states

| | |
|---|---|
| `open` | A question. Nothing is agreed |
| `consensus` | The two agents agree. **Only valid on a message whose `re:` points at a message from the other agent.** Agreement, not execution — see below |
| `settled` | The person decided, or the agreed thing is done. **The only state that closes anything** |
| `escalated` | The disagreement survived the facts. It is a judgement call and it goes to the person |

### `consensus` is agreed. It is not done, and closing is somebody's job

**Nothing closes a message except a `settled` further down its own reply chain.** A thread that
ends in agreement, with the work never carried out and no closing note written, stays pending —
and that is correct, not a leak.

The writer refuses the three shapes below, so none of them is anything to remember. What it cannot
tell you is why each one is there:

| Refused | Because |
|---|---|
| `consensus` without `--re` at the other agent | One agent alone asserting a two-party fact |
| `consensus` without `--lands-in` | An approved sprint plan lived a day in a channel outside version control |
| `settled` without `--closes` | A `settled` that also asks or instructs buries it where no derivation looks |

**`--closes` demands a selection, never a classification, and that generalises.** A guard that asks
you to *pick* fails loudly when you have not looked. One that tries to *detect* fails silently
whenever the text does not resemble its pattern: a proposed detector for "this settled also asks
something" — refuse if a line ends in `?` — fired on **0 of 29** real messages, including both true
positives, because the buried question was prose.

It also closes M19. Twenty-three decisions by the person were written `settled` with `re: -`, and
the derivation excludes `settled`, so all twenty-three were invisible — one answer arrived nine
minutes before an agent asked the same thing again. **A decision that opens work is not closed.**

**The residual noise is accepted on purpose.** In a check whose failure mode is silence, coverage
beats precision: a false positive costs one line and is cleared by writing the missing `settled`.
The false negative it replaces hid a broken privacy control.

**And the tempting simplification is wrong, which was measured.** Closing a whole *thread* once
anything in it settles is cleaner and produced zero false positives on the same channel — and lost
one of the two messages the fix exists to surface, because a `settled` there had closed a different
item earlier. A thread is a rolling conversation, not one topic.

### Why `settled` exists and is not `consensus`

A decision by the person is not two agents agreeing. Using `consensus` for it overloads the word
in the direction that matters least — towards *fewer* interruptions than the person asked for,
because an agent learning the format by imitation will mark as consensus what should have been
escalated, and the escalation query is the person's only alarm.

---

## Everything the person is asked goes in the channel too

When an agent asks the person something — a permission prompt, a design question, a choice between
two ways — **they answer inside one session and the other session never learns it happened.** An
event that leaves no state. The second agent then reasons about a project shaped by a decision it
cannot see, and proposes something already ruled out.

So: **anything the person is asked, and what they answered, is written to the channel by whichever
agent heard it.** Both directions. Getting only the implementing side looks complete because that
side asks more often, but **the bigger decisions — scope, plan, what is in and out — get taken on
the reviewing side**, and those are the ones an implementing agent walks into blind.

**Reading them back is now a level-1 mechanism, because the rule alone was not enough.** The writer
prints the decision index whenever a message goes to the person, and `gtd-msg.sh --decisions` prints
it on demand. The rule *"check what they already decided"* was obeyed **23 seconds too late**: an
agent published a gap the person had answered nine minutes earlier.

```
---
from: owner
to: both
re: -
state: settled
head: sha:9f3c1a2
---

Recorded by code, from a permission prompt. Shown back and confirmed.

ASKED: si lanzo la migracion sobre la copia de trabajo antes del punto de control.
ANSWERED: no -- primero el punto de control y luego la migracion, para que el estado
anterior se pueda recuperar.

Diverges from the configuration, which puts this at CONSENSUS and the owner chose to
decide it. Worth knowing when it comes round again.
```

Five things about that shape:

- **`from: owner`**, whoever typed the file, so `--decisions` returns every one in a list.
- **`to: both`.** An owner decision binds both agents, including the one that wrote it down.
- **The first line names who recorded it, how, and that it was shown back.**
- **`ASKED:` and `ANSWERED:` in the person's language** — the only part of this system they need to
  be able to audit, and a paraphrase written about them by somebody else.
- **Say when the answer diverges from the configuration.** Somebody deciding something they had
  delegated is evidence the configuration is wrong, and nobody notices because each single answer
  feels reasonable.

**A decision that opens work is not `settled`.** `settled` means closed, and the derivation excludes
it — twenty-three decisions were written that way and all twenty-three were invisible to the other
agent. The writer now refuses `settled` without `--closes`, so a decision that instructs something
is `open`, addressed to whoever acts.

**Show it back in the turn you write it**, in one line, in their language. It is a paraphrase
written by an agent, unsupervised and immutable, that both agents will treat as not reopenable —
the one place this method would otherwise act on a summary. A "no" produces a correcting message.

**A change of mind is a new `from: owner` message carrying `re:` at the one it revokes.** The most
recent on a subject governs; without the link the revocation is invisible to anyone reading by grep
rather than by date, which is how these get read.

None of this lets the reviewing agent answer a permission prompt — those are modal and no file
reaches them. It means that agent **knows the prompt happened and what was decided**, which is the
part that was costing something.

---

### What gets written down before it reaches the person

The criterion is not what **acts**. It is **what carries an interpretation the person will adopt as
their own**:

| | Written first | Why |
|---|---|---|
| A question with drafted options | **Always** | Pure interpretation, and the option they pick becomes a decision both agents treat as not reopenable |
| A red or amber block | **Yes** | It acts, on a premise nobody was able to review |
| A green block — read, search, check | No | Neither acts nor interprets, and the rule would cost more than it protects |
| A permission modal | Cannot | It blocks. Recorded immediately afterwards |

The first row was the correction. The rule used to cover command blocks only, on the grounds that a
block is the one thing that acts on the world — and then an agent put five drafted options to the
person, all five resting on a premise the reviewing agent could have falsified in one message, and
it never saw the question. The fix arrived because **the person carried it across by hand**: the
transcription this method exists to remove, happening inside the method.

**And the block proves that message exists**, in its first lines:

```sh
PROP="<channel>/<the message that proposes this>"
test -s "$PROP" || { echo "FAILED: no message proposes this, or it is empty"; exit 1; }
test "$(wc -l < "$PROP")" -ge 8 || { echo "FAILED: $PROP has no body to review"; exit 1; }
echo "proposed in $PROP"
```

On the first day this method ran, an agent handed over a red block — `rm` inside the version-control
directory — **citing a channel message it had never written**, and the person ran it. Naming an
artefact is not evidence that it exists.

**What it establishes and what it does not.** That a file exists with a body longer than front
matter. Not that the body is any good, or that it describes this block: eight lines of nothing
satisfies it. It closes the failure that happened, not every failure imaginable — and it costs
three lines of protocol in front of every block the person sees.

## The channel does not wake anyone up, and the person is not the one who remembers

No file triggers anything: each agent reads when its turn comes round. What the channel removes is
copying and the risk of transcription — not the waiting.

**That is true about notifications and was being read as true about attention.** Between *no push*
and *the person has to mention it* there is a step, and skipping it puts the cable back: a message
written mid-milestone waits for somebody to bring it up. `channel-status.sh` is that step, wired to
whatever the tool fires every turn. **And its cost is not latency, which is how it reads.** *"It surfaces on the next turn"*
sounds like a delay. What it actually is: **work done against a premise that has already been
superseded**, and its size is bounded by the other agent's turn length rather than by how long
the message waits. Measured: a decision to reorder was written at 07:22, and at 08:57 the other
side had produced 364 lines against the sprint that had been reordered ninety minutes earlier.
Nobody proposes a push mechanism, and rightly — an agent interrupted mid-milestone is a worse
failure than one an hour behind. What changes behaviour is knowing which cost it is: whoever
reorders says it louder, and whoever is about to start something large re-derives first.

Installing it is Step 4b of `SKILL.md`, which is also where the
reason it is **two** pieces lives — an executable with no registration is a file that never runs.

## Every wait names the artefact that ends it

An agent that stops has to say what would unblock it, **in a form the other two parties can check
without asking it**. Not *"waiting for the owner"* — the file whose appearance ends the wait.

```sh
ls -1 <runs>/*-<slug>.log >/dev/null 2>&1 && echo "the block has run" || echo "not yet"
```

Note the shape of that line rather than the obvious one. `ls … | head -1` sends its error to a
stream nobody reads and returns the exit code of `head`, which is always zero — so the version
that looks natural reports success whether the file is there or not. It is the same defect the
whole method is written against, in the command proposed to fix a different one.

This is the state/events frontier turned into a command. *"No record here"* is a correct answer
and, on its own, a useless one: it is unfalsifiable and it never expires. A named artefact makes
the same statement checkable — two outcomes, and either party can reach them.

**The cost of not having this is measured.** On the day this method was first run end to end, one
agent sat blocked for two hours on a condition that existed only inside its own chat. The other
could see the project was clear and could not see why nothing was happening. Nothing was wrong;
nothing was visible either. The same day, an orphaned lock file blocked both agents for an hour —
the same shape, a real impediment invisible from the other side.

So a message with `state: open` names, in its last section, the artefact whose appearance closes
it. Where the wait is on a person rather than on a file, name what they were asked and where it
is recorded — which is a `to: owner` message, and that one is already greppable.

---

## Finding what is live

**The derivation is a script, and it is the only copy.** Because files are immutable, an answered
message still says `state: open` for ever, so a bare grep returns every question ever asked. The
state of the conversation is derived, and hand-copying that derivation into documentation is how
four copies of it drifted apart while each one looked right.

```sh
channel-status.sh --channel <channel> --me code|cowork|owner
channel-status.sh --channel <channel> --count
channel-status.sh --channel <channel> --audit <runs dir>
gtd-msg.sh --channel <channel> --decisions
```

Pending is: addressed to me, not `settled`, and with no `settled` down its own reply chain.
`--selftest` proves it on six cases, one of them the message that used to be lost.

**`escalated` on its own is the wrong object, and the difference is measured.** Over a full
working day the channel held **zero** escalations and three unanswered messages addressed to the
person, one of them a command block waiting to be run. `escalated` is rare *by design*, because
this method spends its effort making two agents exchange facts instead of escalating — so the
better it works, the emptier that query gets, and its failure mode is returning zero, which reads
as *nothing needs you*. `--me owner` is the query that answers it.

**Counting is `--count` and not a glob.** `grep -l '^state: open' *.md` returned 33 where there
were 32, three times in eighteen hours across three sessions: the channel keeps its own README,
that README documents the vocabulary with `state: open` in column 0, and it counts itself.

### When the channel gets long

Nothing here grows without a policy, so here is one: **at a milestone boundary, move everything
whose questions are closed into a dated subdirectory.**

```sh
mkdir -p archive/2026-08 && mv <closed messages> archive/2026-08/
```

The queries stay correct because they run on the top level; the history stays because nothing is
deleted; and the person's daily view stops growing. If a project would rather not archive, that is
fine — but then it has chosen to let the queries slow down, and choosing is the point.

---

## Working with it

**Before writing, read.** `ls -1 2*.md | tail -20` is enough to know whether your question is already
answered.

**Before answering, check `head:`.** If it is a `sha:` and the project has moved past it, say so
instead of answering — a stale answer is worse than none, because it looks current. If it is a
`clock:`, there is no check to make; judge from the content.

**Mark `consensus` only when `re:` points at the other agent.** Two agents who have not exchanged
a fact have not agreed; they have merely not disagreed yet. `verification.md` is the difference.

## Message template

`assets/message-template.md` is the file to copy, and it is copied **into the channel** so both
agents can reach it. The shortest useful message is the front matter and one paragraph — the
format is not asking for a report.
