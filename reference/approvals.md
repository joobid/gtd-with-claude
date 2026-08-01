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
| **NOT APPLICABLE — `<reason>`** | This project does not do that at all. **The reason is part of the value, not a note beside it**: written as one string, an empty reason is a malformed answer rather than a missing annotation, and `NOT APPLICABLE` on its own is indistinguishable from a row nobody reached |

CONSENSUS is not a weak DECIDE. It means the two agents have to *exchange and agree* — a single
agent acting alone is not consensus, and if they cannot agree it becomes `escalated`.

### The rule that makes the questionnaire honest

**Every option is presented with what it gains and what it costs, in the same sentence.**

Not "recommended". A person who cannot see the cost has not chosen — they have accepted a
default with a label on it.

**The wordings are below, all twenty-four of them, and they are written out rather than left to
the agent on purpose.** A rule that says *"present the cost"* with three examples is a rule the
agent extends by improvising, and improvised costs come out generic — *"less control"* — which is
a label, not a cost. Use these, or better ones for the specific project; do not invent them at
the moment of asking.

---

### Group 1 · Recording and publishing work — checkpoints, branches, merges

> **DECIDE — gain:** nothing enters the history without you having read it, and the shape of the
> record stays yours. **cost:** you are in the loop for every checkpoint, including the twenty
> trivial ones an ordinary working day produces.

> **CONSENSUS — gain:** you stop approving twenty checkpoints a day, and each one still had to
> satisfy a second agent. **cost:** you learn the shape of the record after it is written, and a
> bad structure is cheapest to fix before it exists.

**"Twenty a day" is illustrative and nobody measured it**, here or anywhere else in this file.
It is the right order of magnitude for an active codebase and it is wrong for a thesis. Say the
number for *their* project if you know it, and say you are guessing if you do not — a figure
quoted back later as the method's biggest saving, when its only source is this sentence, is the
measurement defect `verification.md` opens with, committed in the document that teaches it.

> **DELEGATED — gain:** the single highest-frequency interruption disappears completely.
> **cost:** this is the one activity here that can reach other people — publishing to a shared
> remote is on the floor regardless of what you choose, so delegating this delegates everything
> up to that line and not past it.

### Group 2 · The shape of the work

**Approving a milestone's plan before it starts**

> **DECIDE — gain:** you see the work before it is done, which is the only moment when changing
> direction is free. **cost:** a milestone cannot start while you are unavailable, and planning
> arrives in bursts rather than evenly.

> **CONSENSUS — gain:** a plan that survived a reviewing agent starts without waiting for you.
> **cost:** you find out the milestone's shape from its first report, and by then a week of work
> already assumes it.

> **DELEGATED — gain:** nothing waits for you at the beginning of anything. **cost:** the plan is
> where scope is actually decided, so this delegates more than its name suggests.

**Accepting a milestone's closure against its exit criteria**

> **DECIDE — gain:** nothing is called done without you having seen the evidence, which is where
> "done" usually stops meaning anything. **cost:** you become the bottleneck at the end of every
> milestone, which is the moment momentum matters most.

> **CONSENSUS — gain:** closure requires both agents to agree the criteria were met, so only
> genuine disagreement reaches you instead of every closure. **cost:** the criteria have to be
> written well enough for two agents to judge them, and a vague criterion will be marked met.

> **DELEGATED — gain:** milestones close without you. **cost:** exit criteria are the only place
> this method checks its own work, so this removes the check rather than moving it.

**Changing scope once a milestone is running**

> **DECIDE — gain:** scope cannot grow while you are not looking, which is the most common way a
> plan quietly stops matching reality. **cost:** mid-flight discoveries wait for you, and a
> blocked agent does nothing else in the meantime.

> **CONSENSUS — gain:** a change both agents think is necessary happens immediately, with the
> reason on the record. **cost:** you learn what the milestone became rather than deciding it,
> and small agreed changes compound into a different milestone.

> **DELEGATED — gain:** nothing ever stalls mid-milestone. **cost:** this is the setting that
> quietly devalues the other two — a plan you approved can become a different plan without any
> decision being taken.

### Group 3 · The environment

**Installing dependencies**

> **DECIDE — gain:** nothing enters the project that you have not chosen to depend on.
> **cost:** you approve installs that are obvious, and the interruption lands at the least
> interesting possible moment.

> **CONSENSUS — gain:** a dependency both agents think is necessary gets added, with the reason
> recorded. **cost:** your dependency list grows by agreement rather than by decision, and
> removing one later costs more than not adding it.

> **DELEGATED — gain:** dependency installs stop interrupting you entirely. **cost:** your
> environment changes under you, and you read about it rather than decide it.

**Changing environment configuration**

> **DECIDE — gain:** the environment stays what you believe it is, which is what makes *"it works
> on my machine"* a diagnosable sentence. **cost:** you get consulted about settings you have no
> opinion about.

> **CONSENSUS — gain:** the agents unblock themselves without a round trip through you.
> **cost:** configuration drift is cumulative and invisible, and the record becomes the only
> place it can be seen at all.

> **DELEGATED — gain:** no interruption for environment work, ever. **cost:** when something
> eventually breaks, the gap between the environment you designed and the one you have is
> something you now have to reconstruct.

**Editing the permission configuration of the tools themselves**

> **DECIDE — gain:** the limits stay yours, and an agent that cannot widen its own permissions
> has limits rather than preferences. **cost:** the rare occasion it is genuinely needed becomes
> a round trip.

> **CONSENSUS — gain:** the agents can adjust a limit when both agree it is blocking real work.
> **cost:** the two parties agreeing are the two parties the limits restrict — the one place in
> this whole questionnaire where agreement is not independent of the outcome.

> **DELEGATED — gain:** permissions never interrupt you again. **cost:** every other row on this
> page becomes advisory, because any level you set can be widened by the thing it restricts.

### Group 4 · Design choices where the agents agree

> **DECIDE — gain:** you keep the decisions that shape what the thing becomes, which are exactly
> the ones nobody can reconstruct from the result afterwards. **cost:** you arbitrate choices
> where both agents already agree, which is most of them.

> **CONSENSUS — gain:** two agents converging is enough to move, and only real disagreement
> reaches you. **cost:** worth precisely what the verification culture is worth — two agents
> agreeing about something no check can evaluate is two opinions, not evidence.

> **DELEGATED — gain:** design decisions never wait for anybody. **cost:** the same as consensus
> without even the requirement that both agents looked; this is the level most often chosen for
> the wrong reason, which is speed.

### Group 5 · Reporting rhythm

Not a delegation level — a frequency and a depth — so it has no three wordings. It has one cost,
and it is the same whichever they pick: **whatever they choose has to produce a command that
returns something.** See "The counterweight".

---

### The activities

**Offer NOT APPLICABLE, and mean it.** Not having a repository and not being software are
different things, and three of the eight activities below — recording and publishing, installing
dependencies, changing the environment — have no honest answer on a thesis, a research project or
a campaign. Recording a delegation level for something that will never happen is worse than a
blank, because the configuration is what gets re-read when the method drifts. The agent offers the
value and writes the reason.

**A group can be answered per group or per row, and the agent has to know which it is doing.**
Group 3 holds three activities, and on a thesis project the first two do not apply while the
third does — so a single grouped answer of NOT APPLICABLE would be wrong for one of the rows.
Ask the group, then **write the eight rows individually**, and where a grouped answer does not
fit all its rows, split it and say so in the same turn rather than picking one.

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

**Answer it against whatever your project uses as its record**, and the table is written that way
on purpose. A thesis, a research project and a campaign each have one — a saved draft, a dated
copy, a shared folder that keeps versions — and none of them is a codebase. The question is what
you can return to, never which tool holds it.

| | What it is | What to do |
|---|---|---|
| 🟢 | Reading, searching, listing, running a check, changing something already in the record | **Yes, without thinking** |
| 🟡 | Adding named things, saving a new point you could return to, creating new files | **Yes, if the block carries its own check** |
| 🔴 | Anything that discards work not yet in the record, overwrites the record itself, deletes without an inverse, touches real data, **spends money, or sends something to a third party** | **No. Bring it to the other agent first** |

**"Carries its own check" means the block confirms and shows its own effect after acting** — not
that the command exited zero. A save that prints what it saved, an addition that prints what it
added, a write that reads the file back. Exit zero says the tool ran; it says nothing about what
it did, and the amber row is where the volume is, so the difference decides how much of the day the
person spends reading output that could have checked itself.

The last two are there because they are two of the four floor classes, and the floor is shown once
at setup while this table is the instrument used every day. A floor that half the daily triage does
not mention is a floor that gets forgotten by Tuesday.

**If you do not understand what a command does, it is red.** Not from general caution: a command
can look like it measures and measure nothing.

**With a version-controlled project**, `git-annex.md` has the same three rows written out in that
vocabulary, with the specific spellings that belong in each. That file is the annex on purpose:
this table is the instrument used every day, and a daily instrument that only works on a codebase
would quietly narrow the method to codebases.

### "Yes, and don't ask again" is usually the wrong answer

It converts one approval into a standing policy, and standing policies accumulate where nobody is
reading them. The pattern to expect: dozens of saved approvals of which most are exact strings
that will never match again, and a handful of wildcards that quietly authorise the very thing the
project most explicitly forbids.

Reserve it for read-only commands. For anything that writes, approve each time.

### Saying no usefully

A bare refusal leaves the agent guessing, and it retries a variant. **Say no and why, in one
line:**

> *No. There is work not yet in the record; save it first, then repeat this.*
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
