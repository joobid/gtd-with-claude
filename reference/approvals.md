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

### The three groups, and what each one is really asking

The eight activities group into three questions the person can actually answer. Ask them
grouped; the table above has the rows.

**Group 1 · Recording and publishing work.** Checkpoints, branches, merges. The gain is not
approving twenty commits a day; the cost is learning the shape of the history after it is
written rather than before. **Publishing is not recording** — a commit is reversible and reaches
nobody, and that difference is what makes one delegable and the other not.

**Group 2 · The shape of the work.** Approving a plan, accepting a closure, changing scope
mid-flight. These are the person's by contract rather than by risk: nothing here is dangerous,
and all of it is theirs. A scope change accepted quietly is how a milestone becomes a different
milestone with the same name.

**Group 3 · The environment.** Dependencies, configuration, and the permission rules themselves.
The last one is separate from the other two and stays with the person whatever they answer:
**an agent that can widen its own limits has advisory limits.**

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

### And if they retire one in passing, which does not look like this at all

The section above answers an *ask*. It does not answer the sentence that removes a floor row
without looking like a configuration change — and that is the one that actually happens.

Measured: a floor entry reading *«merging to `main` admits no exception by sprint, by prior
approval, by urgency, or by consensus between agents»*, and later, in ordinary instruction, *«decide
the numbering and whether it merges by consensus»*. The rule's own final clause names the form of
the sentence retiring it. It is their rule and they can move it. **A rule retired in passing is
retired with nobody noticing**, which is why the floor is written down separately from everything
else.

**Name the collision, read the instruction as narrowly as the evidence allows, and record it as a
message.** That held — because the case was empty: the branch carried nothing that was not already
in `main`, so no merge was performed and no precedent was set either way. With real content,
obeying the instruction and obeying the rule are the same choice, and reading narrowly only
postpones it. The narrow reading is an honest deferral, not a resolution, and the message is what
makes the deferral visible when it comes round again.

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

### When a green command prompts, the tool was wrong — not the permissions

**Measured.** An agent asked to read three channel messages with a `for` loop over `cat`, and the
prompt cited `Contains simple_expansion`. That is a **syntax heuristic, not a rule**: the person is
not deciding *"yes, read those messages"*, they are deciding *"yes, this command has a variable in
it"*, and every distinction built into the patterns stops one step short of the button.

Reading is the greenest row on this table, and it stopped. The instinct on receiving it is to save
a standing approval, which would install a policy over `for` — a shape that can carry anything.
That is the worst exit available, and the table had nothing to say that pointed anywhere else.

**Reach for the tool that does not execute:**

| For | Use |
|---|---|
| Reading a file | `Read` |
| Searching across files | `Grep` / `Glob` |
| Querying JSON | `jq` |
| Running an actual program | Bash |

**A green row that prompts is a signal about the tool, not about the floor.** It is also the cost
the person pays most often in a day, so it is worth one line here rather than a shrug.

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
