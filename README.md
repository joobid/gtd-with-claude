# Get Things Done with Claude

A working method for projects where **Claude Code writes the work**, **Claude Cowork reviews and
plans it**, and **a person decides what the two of them cannot settle between themselves**.

Installable as a skill. Everything it installs is plain files.

---

## Install it

**The two agents read skills from different places, so install it twice.** They are separate
stores, not one shared library: a skill saved into your Claude profile does not appear on the
Claude Code filesystem, and the other way round.

**Cowork.** Download `gtd-with-agents.skill` from the [latest release](../../releases/latest) and
open it. The file card has a **Save skill** button.

**Claude Code.** Unpack the same bundle into a skills directory. **Pick one of these two** — the
choice is about reach, not about the method.

Every project of yours:

```sh
mkdir -p ~/.claude/skills
unzip -q gtd-with-agents.skill -d ~/.claude/skills
```

Or this project only, shared with whoever has the repository:

```sh
mkdir -p .claude/skills
unzip -q gtd-with-agents.skill -d .claude/skills
```

**In a Cowork session there is no `.skill` file to unzip.** The skill lives there as a directory in
a plugin cache, under a temporary path that gets regenerated, so it has to be located rather than
remembered:

```sh
SRC=$(find /var/folders -type d -name gtd-with-agents 2>/dev/null | head -1)
mkdir -p .claude/skills && cp -R "$SRC" .claude/skills/
```

Confirm it landed as `<dir>/gtd-with-agents/SKILL.md`. The bundle carries its own folder, so
unzipping *into* the skills directory is correct and unzipping into a subfolder nests it one level
too deep. Then `/gtd-with-agents` exists in a new session.

**Then open a Cowork session in the project and ask for it:**

> *"Set up the working method for this project — Claude Code and Cowork together."*

It asks, in this order: the language you want to be addressed in, the delegation questionnaire, and
where the channel should live. Then it writes `gtd-config.md`, creates the channel, installs the
message writer and the per-turn notice, and hands you two startup prompts — written into the
project as files, because a prompt you need every time a session opens cannot live in a chat
message that scrolls away.

That is the whole installation. Everything it creates is a plain file you can read and change.

> **Why Claude Code needs the skill and not just the startup prompt.** The prompt tells it what to
> do; the skill is what lets it *re-read the protocol* when a question comes up months later. A
> prompt is prose citing identifiers, and prose citing identifiers decays.

---

## The problem it solves

When you run two Claude sessions on the same project, they cannot talk to each other. So you do
it for them. You read a question in one window, summarise it into the other, carry the answer
back, and repeat. Every round trip costs you attention, and every summary loses a little of what
was actually said — which matters most exactly when the two disagree, because what you are
relaying is the reasoning.

This method replaces you as the wire with a directory of files that both sessions read and write.
It also does the less obvious half: it writes down, once and explicitly, **what you decide and
what you hand over** — so that handing things over does not quietly turn into not knowing what is
happening.

Three goals, and they matter equally: **minimise** your interaction, **keep you informed**
throughout, and **guarantee** that what is yours to decide, you decide. The third is the one that
makes the other two safe.

---

## What you get, and what it costs

| You get | It costs you |
|---|---|
| The two sessions answer each other's questions without you in the middle | You approve less, but you are not out of the loop: what the tools block still comes to you |
| Disagreements arrive resolved, or with both sides and the evidence | Two agents exchanging facts take a few more turns than one guessing |
| A written record of who decides what, instead of a habit nobody stated | You have to actually answer the questionnaire, and the honest answers take a few minutes |
| One command tells you what happened since yesterday | Only if you keep the reporting rhythm you chose; a rhythm nobody reads is worse than none |
| A verification culture that makes agreement between two agents mean something | Checks that declare what they examined are slower to write than checks that just say "ok" |

---

## The three parts

| | Does | Never does |
|---|---|---|
| **Claude Code** | Implements. Runs the checks. Writes the command blocks you execute — **and writes each one into the channel, with its reason, before offering it** | Runs a destructive command without approval. Edits its own permission configuration. Widens its own scope. Asks you to paste output back: it wrote the block, it reads the log |
| **Claude Cowork** | Specifies, plans, reviews against the project files, makes small fixes | Answers a permission prompt — those are modal and no file reaches them |
| **You** | Execute what only you can execute. Decide what the two cannot settle | Carry a question or an answer by hand. That is what the channel is for |

### The frontier that makes review possible

**Cowork verifies state, not events.** It can read any file in the project. It cannot know whether
the tests ran, or what they returned, or whether a check rejected something last week. A project
records what it *is*, not what happened to it.

That has one consequence worth the whole method: if the project does not record something, the
honest answer is *"no record here"* — never *"it was not done"*. And anything whose acceptance
criterion is an event has to leave an artefact behind, which is why every command block writes
its output to a file. It turns an event into state, and then anyone can read it afterwards.

---

## The channel

A directory. One **immutable** file per message. Nothing is ever edited or reopened.

```
.runs/exchange/20260801-112306-cowork-floor-does-not-ratchet.md
```

```
---
from: cowork
to: code
re: -
state: open
head: sha:9f3c1a2
---

The scope floors have not moved since they were first written by hand, and the function
that raises them has no caller:

    grep -rn "record(" scripts/ src/ tests/    ->  no matches
    def record(...)  defined at scripts/_scope.py:58

Measured consequence: the tree grew from 165 to 194 tracked files and the floor stayed at
148. The privacy check could stop examining 46 files and still return 0.

I cannot tell whether this was deliberate. It changes what "the check is green" means, so
I am not proposing a fix until you say which behaviour was intended.
```

And the answer, twenty minutes later, in its own file:

```
---
from: code
to: cowork
re: 20260801-112306-cowork-floor-does-not-ratchet.md
state: escalated
head: sha:9f3c1a2
---

Confirmed, and it was not deliberate — the ratchet was designed and never wired.

But raising it automatically has a real cost: a legitimate deletion of files would make the
next run fail on a correct project, and a check that shouts when nothing is wrong gets
switched off. So this is a decision, not a missing line.

Three options, and I do not think we should pick one between us:
  raise automatically and lower by hand with a stated reason in the same change
  raise only when an explicit command asks for it
  keep the floors manual and delete the unused function

Writing this to the plan file as an open decision for the owner, since it changes what
"green" means.
```

Four choices in that format, each with a reason:

- **One file per message, never edited.** Overwriting replaces the whole file, not the part you
  meant to change, and nothing notices — tools watch *which* files changed, not how much of each.
- **`ls -1` is the index.** Timestamp-first names sort chronologically, so the listing is ordered,
  total and complete. An index somebody maintains by hand fails the moment somebody forgets, and
  fails silently.
- **`re:` instead of a status file.** An open question is a message nothing later answers, which
  is discoverable by reading the directory. A shared status file would be a one-slot resource with
  two writers.
- **`head:` is not decoration, and it says which kind it is.** `sha:` is a property of the project,
  so a stale answer can be detected. `clock:` is only when it was written — **the core does not
  offer a staleness check without a project-state identifier**, and saying so beats implying one.
- **`consensus` requires `re:` pointing at the other agent's message.** One agent typing "we
  agreed" into its own front matter is a unilateral claim about two parties; the constraint makes
  the rule checkable instead of aspirational. `settled` is the person's own decisions.

**The timestamp is read from the clock and `head:` from the project, never typed from memory.** A
message stamped a few minutes ahead sorts in front of the answer that replies to it, and then the
directory is no longer ordered, which is the only property the design leans on. This rule exists
because it happened on the first day the channel was used.

**Which is why the writer ships as a script and not as a block to type.** Building the filename by
substitution and feeding a heredoc is a shape no permission pattern can cover — *"contains shell
syntax that cannot be statically analyzed"* — so the most frequent operation in the whole method
prompted for approval **every single time**, and the only relief on offer was the standing approval
this method spends a page warning against. A named entry point is allowed once and is reviewable in
the repository. Four rules that used to be memory are now refusals: the vocabularies, `consensus`
without `re:`, the same-second collision guard, and reading `head:` from its source.

### What you are asked goes in the channel too

Not only agent-to-agent traffic — and this is the part that is easy to leave out.

When a session asks you something, **you answer inside that session and the other one never
learns it happened.** It then reasons about a project shaped by a decision it cannot see, and the
symptom is that it proposes something you already ruled out, or contradicts a constraint nobody
told it about.

So anything you are asked, and what you answered, gets written to the channel by whichever agent
heard it, filed under `from: owner` — and **read by the other one before it proposes anything.**
Both directions:

| You are asked by | It gets written by | And read by |
|---|---|---|
| **Claude Code** — a permission prompt, a choice mid-implementation | Code | Cowork, before it reviews or plans against a project that answer changed |
| **Cowork** — a questionnaire answer, a design decision, a scope call | Cowork | Code, before it builds something you already ruled out |

The second row is the one that gets forgotten, and it is the more expensive of the two: Cowork is
where the bigger decisions get taken — scope, plan, what is in and out — and those are exactly
the ones an implementing session will walk into blind.

Filing them under your name is what makes every decision you have made findable in one line:

```
grep -lE '^from: +owner$' .runs/exchange/*.md
```

And the other direction — **what is waiting on you right now** — is one command, and it is the
one you will actually run:

```
cd .runs/exchange
n=$(ls -1 2*.md 2>/dev/null | wc -l)
[ "$n" -eq 0 ] && { echo "BLIND: no messages here."; }
answered=$(grep -hE '^re: +' 2*.md | awk '{print $2}' | grep -v '^-$' | sort -u)
for f in $(grep -lE '^to: +(owner|both)$' 2*.md); do
  grep -qE '^state: +(open|escalated)$' "$f" || continue
  echo "$answered" | grep -qx "$(basename "$f")" || echo "$f"
done
```

Note what it looks at. An earlier version asked only for **escalations**, and over a full working
day of real use that returned **zero** — while three messages addressed to the person sat
unanswered, one of them a command block containing `rm`. Escalations are rare *by design*, because
this method spends its effort making two agents exchange facts instead of escalating. The better
it works, the emptier that query gets, and its failure mode is returning nothing, which reads as
*nothing needs you*.

It applies to more than approvals: a preference, a constraint, a correction, a fact about your
situation that neither agent could have known. The test is narrow — **would the other agent
behave differently if it knew this?**

And when your answer diverges from what you configured, the record says so. Someone deciding
something they had delegated is information that the configuration is wrong, and it is exactly
what nobody notices, because each individual answer feels reasonable at the time.

### The sessions get told, so you do not have to remember

There is a sentence this method got half right for a while: *"no file wakes anyone up"*. True about
notifications, and it was being read as true about **attention**, which is not the same thing.

Because if nothing tells the other session a message has arrived, **you do.** You are the one who
says "look at the channel", and that is the cable coming back in a smaller and more forgettable
form: the transcription is gone, the remembering is not.

So the skill ships `channel-status.sh`. It runs on every turn of a session, derives exactly what
the queries above derive — addressed to me, still open, minus anything a later answer closes — and
prints one short block:

```
CHANNEL: 2 message(s) addressed to you that nothing has answered.
  .runs/exchange/20260802-183209-cowork-scope-file-serialises.md
  .runs/exchange/20260802-185550-cowork-startup-warnings.md
Read them before proposing anything. Answer with re: pointing at the filename.
```

**When there is nothing, it prints nothing.** It never writes. And what it buys you is one line
long: you stop being the notification.

**It is two pieces and one alone does nothing** — the script, and the registration that makes the
tool run it. In Claude Code that is a `UserPromptSubmit` hook with an explicit `timeout`, because
the default is thirty seconds and **a hook that times out discards its output in silence**. Setup
writes both, and the check is that **the hook fires** — type anything and see whether the notice
appears — not that the file is on disk. An executable asset with no registration is a file that
never runs, which is the same shape as a permission rule the tool accepts and never evaluates.

Two things it does not do, said here rather than discovered later:

- It fires **when you type**. A message written while the other agent is mid-milestone surfaces at
  its next turn, not the instant it lands. The gain is from *"you must remember"* to *"the session
  is told"*, which is real and is not a push notification.
- It covers **one side**. Whichever agent runs in a tool without a per-turn hook has no equivalent,
  and that asymmetry belongs in your configuration rather than in your assumptions.

**The channel is not the record.** It holds the deliberation. Any consensus that changes a plan,
a guide, an interface or a scope lands in a permanent project file in the same milestone, or it
did not happen.

---

## Delegation, and the floor

At setup you are asked, activity by activity, what you want to decide and what you want to hand
over. Three levels:

| | |
|---|---|
| **DECIDE** | You decide, every time, before anything happens |
| **CONSENSUS** | The two agents agree, act, and tell you afterwards |
| **DELEGATED** | They act and do not interrupt. It stays in the record |
| **NOT APPLICABLE — `<reason>`** | Your project does not do that at all. The reason is **part of the value**, on the same line — a bare `NOT APPLICABLE` is indistinguishable from a row nobody reached |

Every option is presented with its gain **and its cost in the same sentence**, because an option
without its cost is a default with a label on it:

> **CONSENSUS — gain:** you stop approving twenty commits a day.
> **cost:** you find out the shape of the history after it is written.

### Four classes you cannot delegate, whatever you choose

| Class | Why it is not on offer |
|---|---|
| **Real or personal data, privacy, rewriting history** | Reverting does not undo it, and the failure is silent: a barrier that has stopped seeing something reports exactly what a clean barrier reports |
| **Destructive actions with no inverse** | Delegation assumes mistakes are recoverable. Archive instead of deleting and it leaves this class |
| **Spending money** | The agents do not hold the mandate. The error leaves your account, not a file |
| **Anything that reaches a third party** | Your name is on it, and it cannot be recalled by deciding afterwards that it was a mistake |

Ask to delegate one of these and the skill refuses, and offers the nearest safe thing instead:
**the agents prepare it completely and you confirm in one step.**

### Two rules that make the channel's own promise real

*"Nothing here is ever reopened"* was doctrine with nothing behind it until this round. An agent
that reopens a message can lose most of the record and nothing notices, because the tools that
watch a project watch *which* files changed and not how much of each. One rule turns that sentence
into a refusal, and its neighbour has the **opposite** criterion:

```
deny:  Edit(<channel>/**)     messages are immutable
allow: Edit(<runs>/*.log)     logs are meant to be filled in
```

Two kinds of file side by side, so a single blanket rule over the run directory gets one of them
wrong. And the deny does not block *writing* messages: those go through the script, which passes
command rules rather than file checks.

### And what the floor actually is, said plainly

**It is a commitment, not a lock.** These four rows are a rule read by the agent they restrict, and
this same method teaches you to distrust exactly that shape — *confirm the mechanism, not the
document*. Claiming otherwise would make the floor the phantom control of its own method.

What that is worth, and it is not nothing: a violation becomes **detectable afterwards and
arguable by name**, because the rule is explicit and written where both agents read it. What it is
not: something that physically cannot happen.

So setup does two things. It puts a **real mechanism** behind the classes where one exists — deny
rules in the tool's own permission configuration, **verified to refuse rather than assumed to
work** — and it records in your configuration file, per class, which of the four got teeth and
which is agreement only.

A floor that says which of its rows can actually block is honest. One that implies all four can is
the thing this method exists to catch.

---

## A worked example, start to finish

**You**, in Cowork: *"Set up the working method for this project."*

**Cowork** asks the language, runs the questionnaire, and you choose CONSENSUS for saving work,
DECIDE for milestone plans, DELEGATED for dependencies. It shows you the floor and does not offer
a level for it. It writes `gtd-config.md` and creates `.runs/exchange/`.

**You** paste the bootstrap prompt into Claude Code. It reports what it finds and starts the
milestone.

**Claude Code**, an hour in, notices something outside its remit and writes to the channel:
`...-code-two-root-resolvers.md`, `state: open` — two functions resolve the project root
differently, one of them is unreferenced and contains a version that predates a fix.

**Cowork** reads it on its next turn, reproduces it against the tree, and answers: confirmed, dead
code, and here is the second-order problem — the day somebody imports it, the fix silently
unwinds. `state: consensus`, and the decision goes into the project's own notes file, not just
into the channel.

**Claude Code** implements it, and the command block writes its output to `.runs/`, so Cowork can
verify afterwards what actually ran.

**You** were not needed for any of that. At the end of the session you run one command and read
what happened. The two things that did need you — approving the milestone plan, and one
`escalated` message where the two agents disagreed about scope after exchanging facts — arrived
as two decisions, not twenty interruptions.

---

## What this does not solve

Not a footnote. If you expect any of these, you will be let down at a bad moment.

**No file wakes anybody up.** Nothing here is a notification. Each session reads the channel when
its turn comes round, which means it comes round when you open it. What disappears is the
copying, not the waiting.

**Cowork cannot answer a permission prompt in Claude Code.** Those are modal and live inside its
interface; no file reaches them. Approvals stay with you.

What it *can* do, since the channel records them, is **know that a prompt happened, what was
asked and what you decided** — which is the part that was actually costing something. The limit
is that it cannot answer for you, not that it is in the dark.

**It does not take the keyboard from you, and it does not pretend nothing runs without you.**
Claude Code executes what its permissions allow — that is what a coding agent is — and **everything
it executes leaves a log**, which is the only reason the reviewing session can verify anything
afterwards. What the permissions block comes to you. The method changes what you are asked and how
often; it does not make you the sole executor, and a document claiming otherwise would be
promising you a control you do not have.

**A permission rule matches text, not intent, and a wrapped command is different text.** Measured
on a real tool: a command that a `deny` rule refuses outright when sent alone **executed** when the
same command travelled inside a logging block — the matcher decomposed a chain of `&&` and named
the rule it used, and treated a brace group as opaque. Something still stopped and asked, but it
asked about *syntax* rather than about deleting a directory, so the care that went into the rule
never reached the person pressing the button. `floor-mechanism.md` says how to find out whether
yours behaves this way, and it is the reason every request there is run twice.

**It does not make two agents right.** It makes them exchange facts instead of opinions, which is
better, and it makes their agreement mean something — but two agents can still be confidently
wrong about the same thing, and the verification culture exists precisely because agreement alone
is cheap.

**It does not survive not being used.** See below.

---

## How this method degrades

Written down because a method followed nominally is exactly the failure it exists to prevent: a
check whose failure mode is to report success. These are the symptoms, in the order they usually
appear.

| Symptom | What it means |
|---|---|
| Messages stop carrying the command that produced the figure | Assertions are travelling as measurements. This is the first one to go and the one that costs most |
| `state: consensus` appears without a fact having been exchanged | Two agents that have not disagreed yet are being recorded as having agreed |
| The channel fills up and nobody reads the older half | The index property is intact and unused. Usually means messages are being written for the record rather than for the reader |
| Consensus decisions stay in the channel and never reach a project file | The record is now in a directory that does not survive a fresh copy |
| The configuration has not been reviewed since setup | The answers no longer describe how the work actually goes, and the floor is the only part still doing anything |
| A verifier gets written and trusted the same afternoon | The oldest defect in the list, wearing new clothes |

None of these announces itself. The cheapest defence is the one that produced this document:
**point the instrument at itself on purpose** — read your own channel, your own configuration and
your own checks as if somebody else had written them.

---

## Why two agents, and not one with a review pass

This is the question worth answering before you adopt anything here, because **the whole ceremony
— the channel, the immutability, the state vocabulary, both bootstrap prompts — is the price of
having two sessions.** If a single session with the same verification discipline caught the same
things, the honest product would be `reference/verification.md` and a review prompt.

So the sixteen defects were classified by **who was positioned to see it**, which is a different
question from who found it:

| | | |
|---|---|---|
| **Only visible from outside the implementing session** | **8** | A real identifier inside a barrier's own exemption · a control everyone cited that did not exist · a ratchet that was never wired · a scope file accumulating five obsolete sections · a rule that never said whether it applied to itself · dozens of accumulated permissions nobody had read · a test target running zero tests · a fingerprint missing since the check was widened |
| **Only visible from inside it** | **6** | A contract with a file outside the project, broken by a rename · an argument consumed as a key, caught before it ran · a tokeniser change that made a scanner silently blind · a helper using patterns where it needed paths · a hook installed without its execute bit · an estimate whose unit counted things that could not be touched |
| **Either could have found** | **2** | A shell quirk capturing the wrong exit code · prose citing a constant that had been renamed |

**Fourteen of sixteen were visible from one position and not the other, split almost evenly.** The
reviewing session sees the project, the plan and the record; the implementing session sees the code
as it is being written and can simulate what a change will do before doing it. Neither position is
a weaker version of the other.

That is the argument for the channel, and it is also its limit: **if your work has no second
position** — nothing outside the code that a reviewer would be looking at — then this is more
machinery than you need, and you should take the verification file and leave the rest.

Two honest caveats. This is one project, reconstructed after the fact, and "who was positioned to
see it" is a judgement in the two ambiguous cases. And it says nothing about whether a *fresh cold
session* over the same work would have caught the first eight — plausibly some of them, which is
why "prefer new sessions over long ones" is in the method too.

## Where it comes from

None of this is theoretical. It was forged over one production project against sixteen catalogued
defects, roughly a third of which were introduced by the same agents that were reviewing the
others.

The pattern that runs through all of them:

> **A check whose failure mode is to report success is worse than no check at all.**

Worse, not equal — a missing check is a known gap, while one that reports success without having
looked gets cited in discussions and decisions get built on it. Everything in `reference/` is that
sentence applied to a different surface: declare what you examined, prove a verifier by breaking
it, check that a control exists before reasoning from it, and ask whether a rule applies to
itself.

The single sharpest instance: a real identifier lived for five days **inside the very barrier
meant to detect it**, because the only file that barrier skips by design is its own exemption. It
was found by pointing the check at itself.

**And it has since been used rather than only built.** A full day of running it end to end on a
real project — two agents, a person, eleven channel messages, seventeen defects catalogued as they
happened — tested every rule here against something that actually went wrong. Nine of the
seventeen the method already prevented. The four it did not were one gap: it governed what the
agents said to each other and what they asked the person, and **not what they handed her to
execute** — the only one of the three that acts on the world. That gap is closed, and the way it
was found is the only kind of evidence this document treats as worth much.

---

## What is in here

```
SKILL.md                 what Cowork executes
reference/
  protocol.md            the channel: names, front matter, immutability, and why
  roles.md               the three parts and the state/events frontier
  approvals.md           the questionnaire, the traffic-light triage, the floor
  verification.md        why agreement between two agents is worth anything
  floor-mechanism.md     how to put a real mechanism behind the floor, and prove it refuses
  git-annex.md           only what depends on having a repository
assets/
  exchange-README.md     copied into the channel
  message-template.md    how to call the writer, and what it enforces
  gtd-msg.sh             the writer itself, executable
  channel-status.sh      the per-turn notice, read only
  bootstrap-code.md      startup prompt for Claude Code
  bootstrap-cowork.md    startup prompt for a cold Cowork session
  config-template.md     where the chosen configuration is written
scripts/
  validate_skill.py      checks what the bundle contains, and proves itself by failing on purpose
  check_doc_commands.py  runs the documented queries against a fixture with a known answer
  package_skill.py       writes the archive, and checks what the archive *is*
  check_own_claims.py    checks the claims this repository makes about itself
.github/workflows/
  release.yml            builds and checks the bundle on a version tag
```

**The core assumes nothing about your setup, and two files break that on purpose.** They are the
annexes, and they are marked as such inside:

- `git-annex.md` — everything that needs a repository
- `floor-mechanism.md` — its four-step procedure is tool-agnostic; the second half is a worked
  example in one specific tool, under a heading that says so

Everything else works on a thesis, a research project or a campaign as readily as on a codebase.

### Releases

Tagging `v*` builds `gtd-with-agents.skill` and attaches it to the release. **The pipeline will
not publish a bundle it has not checked**, and what it checks falls into four kinds rather than a
numbered list — the list is in `release.yml`, and a list maintained in two places goes stale in
one of them:

- **Its own instruments, first.** Every checker is run against deliberate mutations and has to
  reject each one *and* accept the untouched tree. A verifier never seen to fail is not evidence,
  including these.
- **The tree**: frontmatter rules, and `MANIFEST` in both directions — nothing listed is missing,
  nothing shippable is unlisted.
- **The claims, not only the artefact**: the commands this documentation contains are run against
  a fixture with a known answer, and the statements the repository makes about itself are checked
  against the documents that are supposed to follow them.
- **The bundle, as two different objects**: what it *contains*, extracted somewhere clean and put
  through the validator, and what it *is* — files only, deflated, exactly the manifest, one root,
  and a declared version that matches the tag.

**The last of the four is split in two because of a real failure.** `v0.1.1` shipped a bundle that every
content check approved — the official skill validator said it was valid — and it would not
install. The archive had been built with `zip -r`, which emits directory entries and mixes
compression; nothing here had ever looked at the archive as an object rather than as a
container. Two conditions, one of them untested, which is `verification.md` §9 happening to
the file that documents §9.

The rules it enforces are the ones that make an upload fail: exactly one `SKILL.md`, kebab-case
name under 64 characters, and a description under 1024 characters **with no angle brackets** —
that last one is easy to trip and produces a confusing error at load time rather than at build
time, which is why it is checked here.

```
scripts/validate_skill.py <dir>              validate
scripts/validate_skill.py <dir> --self-test  prove it fails when it should
```

---

MIT. See [LICENSE](LICENSE).
