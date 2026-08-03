# Arriving cold at a project that already runs this

For a session that opens on a configured project and has to pick it up — no memory of the
setup, no memory of yesterday, and a channel that may hold hundreds of messages.

**This is not the setup.** Do not run the questionnaire, do not create the channel, do not
rewrite the configuration. It exists, and your job is to derive where things stand from what
is on disk.

**And it is not reading a handover document either.** If picking this up meant reading a
briefing somebody wrote for you, the method would be back to the human cable with an extra
step: a summary written by one session, decaying from the moment it was saved. You derive the
state. Nobody hands it to you.

---

## Why there is a procedure at all, instead of "read the channel"

Because reading the channel is not viable, and this is measured rather than assumed. One
working day of intensive two-agent use produced:

```
66 messages · 176,534 bytes · 27,919 words
32 open · 9 consensus · 25 settled · 0 escalated
```

Ingesting that spends a large part of the context the startup was supposed to leave free, and
it spends it on a corpus that is mostly closed. **A session with no stopping rule reads until
it runs out of room**, and then works from whatever it happened to load first.

So the derivation is the front door, and the messages you read are the ones it names.

---

## The procedure

### 1 · Establish which side you are

Read the configuration file — by default `gtd-config.md` at the project root. It says who
decides what, where the channel lives, and which agent you are. If you cannot find it, ask
before assuming; a project may keep it elsewhere.

This is the one file you read in full. It is short by design.

### 2 · Ask the channel what is outstanding

```sh
<path>/channel-status.sh --channel <channel> --me <code|cowork>
```

**Invoke it by hand. Do not rely on the hook.** The per-turn notice covers whichever side
registered it, and typically that is one side only — the tool on the other side may have no
equivalent. A resume path that assumes the hook works on both sides silently does nothing on
the side that lacks it, which is the failure shape this whole method is written against.

It prints what is addressed to you and not closed: `open` questions and `consensus` items that
were agreed and never carried out. **Empty output means nothing is outstanding**, and that is a
real answer, not a failure.

### 3 · Read exactly this much, and stop

| Read | Why |
|---|---|
| Every message the derivation named | This is the outstanding work. Non-negotiable |
| The direct parent of each, where it has one | A pending message is an answer; its parent is the question. One hop |
| Nothing else | |

**One hop, not the chain.** Measured on that same channel, from the implementing side:

```
the derivation names            8 of 66 messages    14.9% of the channel's words
plus one hop up                14 of 66            25.9%
plus every decision on file    35 of 66            50.8%
plus the full reply chains     48 of 66            72.1%
```

**The percentages are of words, and the counts are of messages** — both are stated because they
give different answers and the second reads like the first. Row one is 8 of 66 messages, which is
12% by count and 14.9% by volume; the number that matters for context is the volume.

The third row is the trap, and it is the instruction most people write: *"read what the person
has already decided."* On this channel that is 22 messages, and obeying it at startup costs
**three times the pending set** and more than half the channel. It is a read-everything
instruction wearing sensible clothes.

So the decisions are not *read* on arrival — but their **index** is, and you do not have to ask
for it. `gtd-msg.sh` prints it whenever you write to the person, and `--decisions` prints it on
demand: one line per decision, filename and heading, never bodies. That is the difference between
a level-1 mechanism and a rule. The rule was there, and it was obeyed **23 seconds too late** —
the gap was published, and the person's answer had been on the channel for nine minutes.

### 4 · When one hop is not enough, that is a finding

If a pending message plus its parent still does not tell you what is being asked, **do not
keep walking backwards.** Write it down as something you could not reconstruct and put it in
the message from step 5. A gap you declare costs one line. A gap you paper over by reading
another twenty messages costs the context you were protecting, and you still may not have it.

### 5 · Publish your reading before you act on it. This is the first act

Write **one** message to the channel, `to: owner`, `state: open`, containing:

- what the derivation named, by filename
- what you understand the outstanding work to be, in your own words
- **what you did not read, and what you could not reconstruct**
- what you intend to do next

Then wait for it to be seen before starting work that depends on it.

**This is what makes a wrong reconstruction cheap.** A gap announces itself; a confident wrong
reconstruction does not, and by the time it shows up it has become work. The person can correct
it in one line if it exists as a message, and cannot correct it at all if it lives inside your
session.

Use the writer, and note the `from:` value:

```sh
<path>/gtd-msg.sh --author <code|cowork> --from <code|cowork> --to owner \
                  --state open --slug picking-this-up  <<'EOF'
## body
EOF
```

`from:` is your own role, not `owner` — you are reporting, not recording a decision they made.

### 6 · Query decisions when you are about to propose, not when you arrive

Before proposing anything, check whether it was already decided:

```sh
grep -lE '^from: +owner$' <channel>/2*.md
```

Read the ones whose slugs touch what you are about to propose. **That is a targeted read driven
by a question you now have**, which is a different operation from ingesting all of them on the
chance one is relevant — the same list, at a fraction of the cost, because you know what you are
looking for.

Those are decisions, not opinions. One that rules out your proposal has settled it. If you think
it rested on a wrong premise, that is a message with the fact, not a re-proposal.

---

## When you are up to date

**You are up to date when you have read the derivation's output and each named message's parent,
and published step 5 — and not before, however much else you have read.**

The criterion is deliberately falsifiable, and it is falsifiable in one direction only: it is
easy to check that you skipped something, because the derivation's list is on disk and finite.
There is no corresponding check for having read too much, which is exactly why the stopping rule
has to be written down rather than left to judgement.

Two things it does **not** mean:

- **Not that you know the project's history.** You know what is outstanding. History is read on
  demand, when a specific question needs it.
- **Not that your reconstruction is right.** It means it is now *visible*, and somebody can tell
  you it is wrong. That is the whole point of doing step 5 before step 6.

---

## What this looks like when it goes wrong

| Symptom | What actually happened |
|---|---|
| The session summarises the whole project confidently and proposes a plan | It read the channel from oldest to newest and is working from what fitted |
| It reports "nothing pending" on a busy project | It derived with `open` alone, so everything agreed-and-unexecuted was invisible. See the state table in `protocol.md` |
| It asks the person to catch it up | It skipped step 2. The channel already holds the answer, and asking makes the person the cable |
| It starts work and the first thing it produces is wrong in a way nobody saw coming | It skipped step 5. The reconstruction was never exposed to anyone who could check it |
