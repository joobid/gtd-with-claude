# What the person decides, and what they hand over

Two things live here: the **delegation questionnaire**, run once when the method is installed,
and the **traffic-light triage**, used every day for individual commands.

---

## Part 1 · The questionnaire

### The three levels

| | What it means |
|---|---|
| **DECIDE** | The person decides, every time, **before** anything happens |
| **CONSENSUS** | The two agents agree, act, and tell them afterwards |
| **DELEGATED** | The agents act and do not interrupt. It stays in the record |
| **NOT APPLICABLE** | This project does not do that at all — and the agent says **why**, in writing |

CONSENSUS is not a weak DECIDE. It means the two agents have to *exchange and agree* — a single
agent acting alone is not consensus, and if they cannot agree it becomes `escalated`.

### The rule that makes the questionnaire honest

**Every option is presented with what it gains and what it costs, in the same sentence.**

Not "recommended". A person who cannot see the cost has not chosen — they have accepted a
default with a label on it. The tone to aim for:

> **CONSENSUS — gain:** you stop approving twenty commits a day.
> **cost:** you find out the shape of the history after it is written.

> **DELEGATED — gain:** dependency installs stop interrupting you.
> **cost:** your environment can change under you, and you will read about it rather than decide
> it.

> **DECIDE — gain:** nothing goes out with your name on it that you have not read.
> **cost:** you are in the loop for every one of them, including the trivial ones.

### The activities

**Offer NOT APPLICABLE, and mean it.** Not having a repository and not being software are
different things, and three of the eight activities below — recording and publishing, installing
dependencies, changing the environment — have no honest answer on a thesis, a research project or
a campaign. Recording a delegation level for something that will never happen is worse than a
blank, because the configuration is what gets re-read when the method drifts. The agent offers the
value and writes the reason.

Eight activities, grouped into **five questions** so the questionnaire is answerable in one
sitting. Counted as the configuration file records them — one row per thing the person answers,
not one per verb in the description. Use `AskUserQuestion`, one question per group, and let the person override any single
activity afterwards — the groups are for speed, not a constraint.

**Group 1 · Version control** — committing, publishing, branches, merges.
The high-frequency one. Whatever is chosen here determines how often the person is interrupted
more than any other answer.

**Group 2 · The shape of the work** — approving a milestone's plan before it starts, accepting
its closure against the exit criteria, and changes of scope once it is running.
These three go together because they are the same question at three moments. Someone who wants to
approve plans usually wants to hear about scope changes; someone who delegates the plan rarely
wants to arbitrate mid-flight.

**Group 3 · The environment** — installing dependencies, changing configuration, and touching the
permission files of the tools themselves.
The last one deserves its own note when you ask: an agent that can widen its own permissions is
an agent whose limits are advisory. Most people who delegate the first two still want to decide
this one.

**Group 4 · Design choices where the agents agree** — picking between alternatives when both
agents land in the same place.
This is the purest delegation question in the set: the person is deciding whether agreement
between two agents is enough for them, which is exactly what `reference/verification.md` is
about. If the verification culture is not in place, agreement is cheap and this should be DECIDE.

**Group 5 · Reporting rhythm** — how much they want to read, and how often.
Not a delegation level: a frequency and a depth. Offer something like *a line per milestone*, *a
summary at the end of each session*, or *only when something needs me*. Whatever they pick has to
produce a real command — see "The counterweight" below.

Four activities are **not** in the groups because they are not on offer. They are the floor.

### A sixth question worth asking: which agent does what

Not a delegation level, but it belongs in the same conversation, because it decides how much the
CONSENSUS setting is actually worth.

> **Use the stronger model where no check can verify the output. Use the cheaper one where a
> check can.**

The criterion is not difficulty, it is verifiability. Generating something covered by a test
suite, a schema or a snapshot is work whose result an instrument confirms — a cheaper agent that
gets it wrong gets caught. Writing an argued document, designing an interface, deciding a policy,
or touching real data produces output that no check evaluates, and there the reviewing pass is the
only defence there is.

Two consequences for the person:

- The parts of a project where they can safely delegate the most are exactly the parts with the
  best mechanical coverage. **Delegation and verification are the same lever.**
- When both agents are strong, the review works in both directions and each catches what the
  other is not positioned to see — one sees the work as it is written, the other sees the project
  and the plan. Downgrading one end does not halve the catches; it removes the ones only that end
  could see.

---

## Part 2 · The floor

These classes cannot be delegated, whatever the person prefers. Show them during setup, with the
reason — a limit whose reason is not stated is a limit that gets argued with later.

### Personal or real data, privacy, and rewriting history

**The damage is not undone by reverting.** A value that reaches a shared history is in every copy
anyone has taken, and removing it afterwards changes the record rather than the fact. Consent
cannot be retrofitted.

There is a second reason, less obvious and more important: the failure here is silent. A barrier
that stops seeing something reports exactly what a barrier with nothing to find reports. Two
agents agreeing that a file looks clean is not evidence, because both are reading the same file
with the same blind spot.

### Destructive actions with no inverse

Delegation rests on an assumption: that a mistake is recoverable. Where there is no inverse
operation, the assumption is false, and the level chosen for everything else does not transfer.

The workable version is not "ask permission to delete" — it is **archive instead of delete**. If
an action has an inverse, it stops being in this class.

### Spending money

The agents do not hold the mandate. The distinction is not the size of the amount but whose
account it leaves: an error in the rest of this list produces a file that can be fixed, and an
error here produces a charge that has to be disputed.

### Anything that reaches a third party

Publishing, sending, posting, messaging. **The person's name is on it**, and a message cannot be
recalled by deciding afterwards that it was a mistake. Reputation is the one thing in this list
that neither agent can see the state of.

### If someone asks to delegate one of these

Do not do it, and do not soften it into a version that technically complies. Explain that the
method stops guaranteeing what it says it guarantees — and offer the nearest safe thing, which is
usually: **the agents prepare it completely and the person confirms in one step**. That preserves
most of the saving without moving the decision.

---

## Part 3 · The daily triage

The questionnaire settles classes of work. Individual commands still arrive, and the question to
ask is not *"is this correct?"* — that is not answerable at a glance and should not have to be.

> **If this is wrong, do I get it back?**

| | What it is | What to do |
|---|---|---|
| 🟢 | Reading, searching, status and history queries, running tests, editing files already saved in the project's history | **Yes, without thinking** |
| 🟡 | Adding named files, saving a checkpoint, creating a branch, creating new files | **Yes, if the block carries its own check** |
| 🔴 | Anything that discards unsaved work, force-publishing, deleting, touching real data, rewriting history, adding everything at once, **spending money, or sending anything to a third party** | **No. Bring it to the other agent first** |

**"Carries its own check" means the block confirms and shows its own effect after acting** — not
that the command exited zero. A checkpoint that prints what it saved, an add that prints what is
staged, a write that reads the file back. Exit zero says the tool ran; it says nothing about what
it did, and the amber row is where the volume is, so the difference decides how much of the day the
person spends reading output that could have checked itself.

The last two are there because they are two of the four floor classes, and the floor is shown once
at setup while this table is the instrument used every day. A floor that half the daily triage does
not mention is a floor that gets forgotten by Tuesday.

**If you do not understand what a command does, it is red.** Not from general caution: a command
can look like it measures and measure nothing.

### "Yes, and don't ask again" is usually the wrong answer

It converts one approval into a standing policy, and standing policies accumulate where nobody is
reading them. The pattern to expect: dozens of saved approvals of which most are exact strings
that will never match again, and a handful of wildcards that quietly authorise the very thing the
project most explicitly forbids.

Reserve it for read-only commands. For anything that writes, approve each time.

### Saying no usefully

A bare refusal leaves the agent guessing, and it retries a variant. **Say no and why, in one
line:**

> *No. There is unsaved work; save the batch first, then repeat this.*
> *No. That block does not carry its own check.*
> *No. That touches real data, which is not in this milestone.*

---

## Part 4 · The counterweight

Delegation without information is not efficiency, it is opacity. So whatever the person delegates
has to be readable afterwards without asking either agent.

The test is concrete: **they can answer "what has happened since yesterday?" with one command.**

Write that command into the configuration file, specific to their project — the channel plus
whatever the project uses as its own record. `config-template.md` ships worked examples; do not
invent one per installation, because then some of them do not work and nobody finds out.

**And the acceptance test is not "run it once".** At setup the channel is empty and the project
has done nothing, so it returns zero lines and gets marked working — which is verbatim the blind
check this method exists to catch: *a search over an empty input prints success and returns zero*.

> **Write a probe message into the channel and confirm the command returns it.** That is the
> version that cannot pass over an empty input, and then the rule satisfies itself instead of
> failing its own definition.
