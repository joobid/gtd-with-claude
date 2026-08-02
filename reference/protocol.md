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
| `consensus` | The two agents agree. **Only valid on a message whose `re:` points at a message from the other agent** |
| `settled` | The person decided. No two agents, no exchange required. Not reopened |
| `escalated` | The disagreement survived the facts. It is a judgement call and it goes to the person |

### Why `consensus` needs `re:`

A message is one immutable file written by **one** agent, and that agent types its own front
matter. Without a constraint, `state: consensus` is a unilateral assertion of a bilateral fact —
one agent declaring that both agreed, with nothing the other had to write.

That is not a discipline problem, it is a format problem: the format offered no way to do it
correctly. Requiring `re:` to point at the other agent's message makes the rule **checkable**
rather than aspirational — a consensus with `re: -` is one-sided and authorises nothing.

The concrete failure it closes: the person sets something to CONSENSUS, one agent writes "agreed,
proceeding", acts, and the other never read it. The record says consensus, and the record is what
gets audited.

### Why `settled` exists and is not `consensus`

A decision by the person is not two agents agreeing. Using `consensus` for it overloads the word
in the direction that matters least — towards *fewer* interruptions than the person asked for,
because an agent learning the format by imitation will mark as consensus what should have been
escalated, and the escalation query is the person's only alarm.

---

## Everything the person is asked goes in the channel too

This is the part that is easy to leave out, and leaving it out reopens the hole the channel was
built to close.

When an agent asks the person something — a permission prompt, a design question, a choice
between two ways — **the person answers inside one session, and the other session never learns it
happened.** That is an event that leaves no state. The second agent then reasons about a project
shaped by a decision it cannot see, and the likeliest symptom is that it proposes something
already ruled out.

So: **anything the person is asked, and what they answered, is written to the channel by whichever
agent heard it — and read by the other before it proposes anything.**

**Both directions, and both halves.** It is a rule about a pair:

| Who asks | Who writes it | Who has to read it |
|---|---|---|
| Code asks the person — a permission prompt, a choice mid-implementation | Code | Cowork, before reviewing or planning against a project that answer changed |
| Cowork asks the person — a questionnaire answer, a design decision, a scope call | Cowork | Code, before implementing something the person already ruled out |

Getting only the first half is a common and asymmetric mistake: it looks complete, because the
implementing agent asks more often. But **Cowork is where the bigger decisions get taken** —
scope, plan, what is in and out — and those are exactly the ones an implementing agent walks into
blind.

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

- **`from: owner`**, whoever typed the file. The information originates with the person, and
  `grep -E '^from: +owner$'` then returns every decision they have made in one list.
- **`to: both`.** An owner decision binds both agents, including the one that wrote it down —
  `to: cowork` would formally excuse the author from ever re-reading it.
- **The first line names the agent that recorded it, how, and that it was shown back.** Whether it
  came from a modal prompt or from ordinary conversation changes how much is verbatim.
- **`ASKED:` and `ANSWERED:` in the person's language.** They are the only part of this system the
  person needs to be able to audit, and they are a paraphrase written about them by someone else.
- **Say when the answer diverges from the configuration.** Somebody deciding something they had
  delegated is information that the configuration is wrong — and it is exactly what nobody
  notices, because each individual answer feels reasonable.

### Show it back, in the turn you write it

A `from: owner` message is a **paraphrase**, written by an agent, unsupervised, immutable, and
given the highest standing in the system — both agents treat it as not reopenable.

Everywhere else this method forbids acting on a paraphrase: *a verdict on somebody's reading is a
verdict on the wrong object* (`roles.md`). The person's own decisions were the one place where the
paraphrase was the only representation that existed.

So the agent **shows the person the `ASKED:`/`ANSWERED:` block in the turn it writes it**, in one
line, in their language. A "no" produces a new message correcting the old one — the correction is
a new file, like every correction here.

### When a decision replaces an earlier one

Files are immutable, so a change of mind is a **new** `from: owner` message. Two rules, because
without them one agent honours last week's decision and another honours whatever `ls` returns
last, and both readings are defensible:

- **The most recent `from: owner` message on a subject governs.**
- **It must carry `re:` pointing at the one it revokes.** Without that link the revocation is
  invisible to anyone reading by grep rather than by date, which is how these get read.

### What this does and does not fix

It does **not** let Cowork answer a permission prompt. Those are modal and no file reaches them;
that limit is unchanged.

It does mean Cowork **knows the prompt happened, what was asked, and what was decided** — which is
the part that was actually costing something.

---

### A command block is written down before it runs, and the block proves it

A question and a modal prompt are covered above. The third thing an agent hands a person is a
**block of commands**, and it is the only one of the three that acts on the world. It was the one
without a rule.

**The block and the reason for it are written to the channel before it is offered**, `to: owner`.
The modal that follows is then a confirmation of something already written and reviewable rather
than the first anyone hears of it — and the reviewing agent can object while the person is still
reading.

**And the block proves that message exists.** First lines, above the work:

```sh
PROP="<channel>/<the message that proposes this>"
test -s "$PROP" || { echo "FAILED: no message proposes this, or it is empty"; exit 1; }
test "$(wc -l < "$PROP")" -ge 8 || { echo "FAILED: $PROP has no body to review"; exit 1; }
echo "proposed in $PROP"
```

This is not ceremony. On the first day this method ran end to end, an agent handed the person a
red block — `rm` inside the version-control directory — **citing a channel message it had never
written**, and the person ran it. Naming an artefact is not evidence that it exists, and when the
artefact is a file, checking costs one line.

**What it establishes, and what it does not.** It establishes that a file exists with a body long
enough to be a message rather than a stub — front matter alone is seven lines, so eight is the
cheapest thing that is not empty. It does **not** establish that the body is any good, or that it
describes this block. A determined agent can satisfy it with eight lines of nothing. It closes
the failure that happened rather than every failure imaginable, and saying which is which is the
point of writing it down.

**And it costs something**, which is worth saying in the same breath: every block the person sees
now opens with three lines of protocol before the work. That is the trade — a little noise in
front of every block, against a red one running on a premise nobody could check.

It changes the failure mode twice over: the agent has to produce the file before it can cite it,
and the person sees `FAILED` **before** anything executes rather than trusting a filename they
were told about.

A skipped rule is visible — the directory is empty where the message should be. **A false claim
of compliance is not**, and that is why this is a line of shell rather than a paragraph asking
nicely. A protocol enforced only by agreement fails the way this one failed: **by reporting
success.** That is `verification.md` §5 — *confirm the mechanism, not the document* — applied to
this method's own governance, which is the one place it had never been pointed.

The sweep, for anyone auditing afterwards:

```sh
for l in <runs>/*.log; do grep -q '^proposed in ' "$l" || echo "NO PROVENANCE: $l"; done
```

Logs written before this rule existed carry no such line and are **declared out of its scope**,
not silently skipped.

---

## What the channel is not

**It is not a record.** It holds the deliberation, not the decision.

Every consensus that changes a plan, a guide, an interface or a scope has to land in a **permanent
project file in the same milestone**, or it did not happen. Where the channel lives in an ignored
directory, this is not a preference — the channel does not survive a fresh copy of the project.

This is the state/events split applied to the two agents: the exchange is the event, the project
file is the state.

**It does not wake anyone up.** No file triggers anything. Each agent reads the channel when its
turn comes round. What the channel removes is copying and the risk of transcription — not the
waiting.

---

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

**These are not one-liners, and the reason matters.** Because files are immutable, an answered
message still says `state: open` for ever. A bare `grep -E '^state: +open$'` returns *every question
ever asked*, which at month three is sixty paths the person cannot triage. The state of the
conversation is derived, so the query has to do the derivation.

**Each of these declares what it examined, and refuses to answer over nothing.** A query that
returns zero from the wrong directory looks exactly like a healthy channel with nothing open —
which is the blind state §1 of `verification.md` defines, and it is not an approval. Run them
from inside the channel, and let them say so:

```sh
n=$(ls -1 *.md 2>/dev/null | wc -l)
[ "$n" -eq 0 ] && { echo "BLIND: no messages here. Wrong directory, or no channel yet." >&2; exit 2; }
echo "EXAMINED: $n messages"
```

```sh
# Open questions: state: open, minus anything a later message answers.
answered=$(grep -hE '^re: +' *.md | awk '{print $2}' | grep -v '^-$' | sort -u)
for f in $(grep -lE '^state: +open$' *.md); do
  echo "$answered" | grep -qx "$(basename "$f")" || echo "$f"
done
```

```sh
# What waits on the person: anything addressed to them that nothing has answered.
# Both kinds, because they arrive at very different rates.
answered=$(grep -hE '^re: +' *.md | awk '{print $2}' | grep -v '^-$' | sort -u)
for f in $(grep -lE '^to: +(owner|both)$' *.md); do
  grep -qE '^state: +(open|escalated)$' "$f" || continue
  echo "$answered" | grep -qx "$(basename "$f")" || echo "$f"
done
```

**`escalated` on its own is not that query, and the difference is measured.** Over a full working
day of real use — twenty-four messages, three blocked moments, four batches waiting for approval —
the channel held **zero** escalations and three unanswered messages addressed to the person. A
query restricted to escalations returned nothing, all day, while a red command block sat waiting.

That is not a bug in it; it does exactly what it says. It is the **wrong object**. `escalated` is
rare *by design*, because this method spends its effort making two agents exchange facts instead
of escalating — so the better it works, the emptier that query gets, and its failure mode is
returning zero, which reads as *nothing needs you*.

```sh
grep -lE '^from: +owner$' *.md     # every decision the person has made

ls -1 | tail -20                   # the last twenty messages, in order
```

**How an escalation is closed:** a message `from: owner` whose `re:` points at it. That makes
"what needs me" computable, and it is consistent with everything else — a decision closes a
question the same way an answer closes one.

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

**Before writing, read.** `ls -1 | tail -20` is enough to know whether your question is already
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
