---
name: gtd-with-agents
description: Set up and run the three-party working method for a project driven by Claude Code and Claude Cowork together — a file-based channel the two agents use to talk to each other, an explicit delegation contract that records what the person decides and what they hand over, and the verification culture that makes agreement between two agents worth anything. Use this whenever someone is starting a project with both Claude Code and Cowork, asks how the two should coordinate, says they are tired of copying questions from one session and pasting answers into the other, asks "who decides what here", "how do I stay informed without approving everything", "how much can I delegate", or wants to install a working agreement, an exchange channel, or an approval policy between agents. Also use when a session arrives cold at a project that already has this method installed and needs to pick it up.
metadata:
  version: 0.4.3
---

# Get Things Done with Claude

A working method for projects where **Claude Code implements**, **Claude Cowork reviews and
plans**, and **a person decides what the two agents cannot settle between them**.

It exists because of one failure: when two agents cannot talk to each other, the person becomes
the cable. They copy a question out of one session and paste an answer into the other, and in
that transcription precision is lost and work is gained. This method replaces the cable with a
directory of files that both agents read and write.

Three goals. **They are not independent, and the order is a dependency, not a ranking:**

1. **They can find out where things stand in two minutes, whenever they choose** — by asking, not
   by being told, and the answer does not lie.
2. **They can leave and come back at any point, at a bounded cost, with no agent waiting on them.**
   If something stopped while they were away, it was classified wrong.
3. **What is theirs to decide, they decide.** Always.

Each is falsifiable with a stopwatch or a diary, which *"minimise the person's interaction"* was
not. Counting approvals optimised the wrong quantity: twenty questions batched into a moment they
choose cost far less than five spread over an hour, because the second kind destroys the
possibility of doing anything else. What they experience is not a count, it is being tethered.

**And 1 is the condition for 2.** Someone with no way of knowing what is happening does not get
freed by removing their approvals — they get left watching the chat out of ignorance instead of
obligation. Cutting doors without building the accounting is asking them to trust blind.

Goal 3 is not a nice-to-have either. Delegation without a floor is not efficiency, it is opacity.

---

## What this skill does when it triggers

Two situations. Read which one you are in before doing anything.

**A · The project has no configuration yet.** Run the setup below: choose the language, run the
delegation questionnaire, create the channel, write the configuration, hand over the two
bootstrap prompts.

**B · The configuration already exists, and you are arriving cold.** Do not run the questionnaire
again. **Read `reference/resuming.md` and follow it** — it is a procedure, not advice, and it ends
with a stated criterion for when you are up to date.

In one line: read the configuration, ask `channel-status.sh` what is outstanding, read those
messages and their direct parents, and **publish your reading to the channel before acting on
it**. Nothing else.

**Do not read the channel from oldest to newest.** That instruction used to live here and it was
wrong: measured on one working day of two-agent use, the channel held 66 messages and 27,919
words, of which the outstanding set was 8. Ingesting it spends the context the startup existed to
protect, on a corpus that is mostly closed.

To tell A from B, look for a configuration file — by default `gtd-config.md` at the project
root. If you do not find it, ask before assuming: a project may keep it elsewhere.

---

## Setup

### Step 1 · The language the person is addressed in

Ask first, because everything you write for them afterwards depends on it.

> **In which language should the two agents address you?**

Whatever they answer applies to conversation, reports and questions — everything a person reads.

**It does not apply to the channel.** Every file under the exchange directory is written in
**English**, always, whatever the person chose. Those files are not for them: they are how two
agents synchronise, they get grepped, and one convention beats two. Say this out loud when you
ask, so it is a stated decision and not a surprise later.

### Step 2 · The delegation questionnaire

This is the heart of the setup. Ask with `AskUserQuestion`, grouped so it is a handful of
questions and not twenty. Read `reference/approvals.md` for the full question set, the wording of
each level, and the floor.

Every activity is offered at three levels:

| | |
|---|---|
| **DECIDE** | The person decides, every time, before anything happens |
| **CONSENSUS** | The two agents agree, act, and tell them afterwards |
| **DELEGATED** | The agents act and do not interrupt. It stays in the record |
| **NOT APPLICABLE — `<reason>`** | The project does not do that at all. **Offer it and mean it** — three of the eight activities have no honest answer on a thesis or a campaign. Write it as `NOT APPLICABLE — <reason>`, never bare |

**Present every option with its gain and its cost in the same sentence.** Not "recommended" —
what they get and what they give up. A person choosing CONSENSUS for version control should read
that they stop approving twenty commits a day *and* that they will learn the shape of the history
after it is written. If they cannot see the cost, they have not chosen.

### Step 3 · The floor that is not on offer

Some classes cannot be delegated even if the person asks. Show them, say why each one is there,
and do not offer a level for them.

| Class | Why it cannot be delegated |
|---|---|
| **Personal or real data, privacy, history rewriting** | The damage is not undone by reverting. Once something is published or written into a history, consent cannot be retrofitted |
| **Destructive actions with no inverse** | Delegation assumes a mistake is recoverable. Where it is not, the assumption fails |
| **Spending money** | The agents do not hold the mandate. An error here leaves the person's account, not a file |
| **Anything that reaches a third party** | The person's name is on it. A message sent in someone's name cannot be recalled by deciding it was a mistake |

If someone insists on delegating one of these, do not do it. Explain that the method stops
guaranteeing what it says it guarantees, and offer the nearest thing that is safe: agents prepare
and the person confirms in one step.

#### And be honest about what the floor is

**This document is not a mechanism.** It is four rows read by the agent it restricts, and this same
skill teaches the reader to distrust exactly that shape — *confirm the mechanism, not the
document*. Pretending otherwise would make the floor the phantom control of its own method.

So during setup, **put a real mechanism behind it wherever one exists, and record per class whether
you did**:

**`reference/floor-mechanism.md` is the procedure** — where the rules live, what to write, the five
requests that test them, and what an ineffective rule looks like next to a working one. Read it
here; do not improvise a syntax.

- Where the tool has a permission configuration, write rules that refuse and then **watch them
  refuse**. A rule that has not been seen to block is a rule nobody has tested — and a rule only
  covers the **spelling** it was written for, so one of the five test requests is deliberately the
  same operation spelled differently. Expect that one to fail the first time.
- **Whatever the outcome, it leaves a log, and the configuration records the path to it.** Never
  `verified` without one: a floor certification is an event, and an event with no artefact is an
  assertion.
- Where no mechanism exists, say so: `none — agreement only`. Typically two of the four classes.
- **`attempted, not verified` is the honest default**, and on a first pass it is the **expected**
  outcome — the other-spelling request is written to fail. A first exercise that ends there has
  succeeded, and `verified` is a later, bounded claim about the spellings this project actually
  produces.
- **Two things the procedure will not survive without, and both were learned by running it:**
  every request goes **twice**, bare and wrapped in whatever shape this project's commands
  normally take — they answer differently, and the wrapped one is the real one. And **the person
  records whether it prompted**, because an agent cannot tell *"ran without asking"* from
  *"prompted, and they approved"*.
- **Tell them what it costs before they start: ten requests, not five** — five rows in two shapes
  each — and roughly half an hour. The first real execution took 72 minutes and 16 requests, and
  it only ran the bare half.

A floor that declares which of its four rows has teeth is honest. One that implies all four do is
the thing this method exists to catch.

### Step 4 · Where the channel lives

Ask, or detect and confirm:

- **With a version-controlled project** — inside an already-ignored run directory, so raw output
  never gets committed. See `reference/git-annex.md`
- **Without one** — a plain folder such as `exchange/`

Create the directory and copy **three** files into it:

| From | To | Why |
|---|---|---|
| `assets/exchange-README.md` | `<channel>/README.md` | The channel explains itself to whoever opens it |
| `assets/message-template.md` | `<channel>/message-template.md` | How to call the writer, and what it enforces |
| `assets/gtd-msg.sh` | somewhere on the implementing side, **executable** | **It is the writer.** Keep the executable bit |

None of the three is optional and the reason is specific. Claude Code never sees this skill's
files — they live in Cowork's cache. Telling it to "use the writer" while the writer is somewhere
it cannot reach is prose citing an identifier, and nothing reads prose: it will build the header
from its own context instead, which is the one defect the protocol is most emphatic about, and it
fails silently until a message sorts in front of its own reply.

Then allow the writer once, by entry point:

```
allow: Bash(<path>/gtd-msg.sh*)
```

Without that line the person approves a prompt **on every single message**, because the shape the
writer used to have — filename by substitution, body by heredoc — is one no permission pattern can
cover. That was measured, and it is the highest recurring cost the method has.

**Keep the rule narrow, and note what it costs to widen.** A leading wildcard is the only shape
that reaches inside a compound command, which on a `deny` is conservative — it catches the
dangerous command wherever it hides. On an `allow` it is the exact opposite: `Bash(*gtd-msg.sh*)`
would approve, without asking, any command that merely *mentions* the file. Same wildcard,
opposite consequence, because the two lists answer opposite questions.

### Step 4a · Check that the writer writes, not that it is there

```sh
<path>/gtd-msg.sh --selftest
```

Six checks against a scratch directory, exercising the shipped writer rather than a copy of its
logic, and it prints what it examined before its verdict. **Run it on the machine that will use
it.** The useful question is never which systems the method supports — that is a list written from
whatever was in front of whoever wrote it — but whether it works here, and only running it answers
that.

If it reports `the script is executable` as failed, the file is present and will not run: the
documented invocation is `./gtd-msg.sh`, and a permission rule naming that path matches that text
and no other. `chmod +x` fixes it where the filesystem carries an exec bit at all. Where it does
not — an NTFS mount seen from WSL, some sync clients — `chmod` reports success and changes
nothing, and the project has to move onto a native filesystem.

### Step 4b · The per-turn channel notice, which is two pieces

**`assets/channel-status.sh` plus the registration that makes the tool run it.** Install both or
install neither: an executable asset with no registration is a file that never executes, which is
the same shape as a permission rule the tool accepts and never evaluates.

1. Copy the script to the implementing side, executable.
2. Write the registration **and the permission rules in the same edit.** In Claude Code that is a
   `UserPromptSubmit` hook in `.claude/settings.json`; the timeout is explicit because the
   30-second default **discards the hook's output in silence** when it expires:

```json
{
  "permissions": {
    "allow": ["Bash(<path>/channel-status.sh*)", "Bash(<path>/gtd-msg.sh*)"]
  },
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [
          { "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/channel-status.sh",
            "timeout": 10 } ] }
    ]
  }
}
```

**The two `allow` lines are not optional and they are the skill paying for its own install.** This
step installs two executables; until this round it granted permission to neither, and the measured
result was that **the better-instrumented side had the worse start, because of the instrument**:
the side with the hook sat in a modal on its very first turn while the side without one published
in sixty seconds. Everything else about the floor is a claim about a project nobody has seen —
this is just not leaving your own machinery unusable.

3. **Check the derivation before checking the wiring**, because they fail differently and only
   one of them is visible:

   ```sh
   <path>/channel-status.sh --selftest
   ```

   Six assertions over a synthetic channel built to contain the case this derivation exists for:
   a thread both agents agreed on that nobody carried out. It runs in a scratch directory and
   touches nothing of yours.
4. **Check that the hook fires, not that the file exists.** Ask the person to type any prompt and
   report whether the notice appears. Two pieces means two ways to have done half the job, and
   both of them leave the script on disk looking installed.
5. **Probe it against a channel with something in it.** Over an empty one it prints nothing and
   looks correct, which is the blind check this method exists to catch.

**Say what will show up, or the first report will be a bug report.** The notice lists `consensus`
alongside `open`, because agreed is not done and only a `settled` naming a message closes it. On a
busy channel that means items both agents signed off on and neither finished. Some of them will be
finished work whose closing note was written without a `re:` — one line of noise, cleared by
writing the `settled` that names the file.

Then record it in the configuration, including what it does **not** do: it fires when the person
types, so a message written mid-milestone surfaces at the next turn rather than immediately, and
it covers **one side only** unless the reviewing agent's tool offers an equivalent. `protocol.md`
has the reasoning; the configuration has the row.

### Step 5 · Write the configuration

Fill `assets/config-template.md` with what was chosen and save it to the project. **The
configuration is a project file, not a chat decision** — a decision that lives only in a
conversation is not a decision, because conversations end.

Then **write the questionnaire answers into the channel as the first `from: owner` message.** The
founding decisions — the language, the delegation levels, which agent does what — are the most
important ones the person will ever make here, and without this step `grep -E '^from: +owner$'` returns
nothing on day one while both agents are told to treat it as the list of what is settled.

It also gives the channel a baseline: that message's `head:` is the state the project started from.

### Step 6 · Hand over the two bootstrap prompts

**Write both filled-in prompts into the project**, next to the configuration file — not only into
the chat. The same rule as Step 5 applies and applies harder: these are needed **every time a
session opens**, not once. A prompt that exists only in a chat message is gone by month three, and
then a session starts without it, does not read the channel, does not record what the person says,
and the method has silently stopped existing with nothing detecting it.

Where the tool has a persistent instructions file, offer to add a three-line pointer to it as well.
A paste-prompt is prose citing identifiers, and prose citing identifiers decays.

#### And check the implementing agent can reach this skill at all

**The two agents read skills from different stores.** Being installed here says nothing about
being installed there, and the difference is invisible from this side — which is exactly the
state/events frontier applied to the method's own installation.

So during setup, **ask the person to confirm it is installed on the implementing side too**, and
tell them where it goes. For Claude Code that is a skills directory on the filesystem:

**You cannot run this install yourself, and finding that out costs two failed attempts.** The
reviewing agent's sandbox refuses any write whose destination is `.claude/skills/<name>/` — writing
to a sibling directory works, reading the source works, copying to `/tmp` works, and only that
destination fails. The guard is reasonable: an agent installing its own skill is adjacent to an
agent editing its own permissions. **So prepare the block and hand it over**, exactly as you do
with the permission configuration. Write the log before attempting, so a refused attempt looks
refused rather than absent.

**And in a Cowork session there is no `.skill` file to unzip.** The skill exists as a **directory**
in the plugin cache, under a temporary path that gets regenerated, so the path has to be located
rather than remembered:

```sh
SRC=$(find "${TMPDIR:-/tmp}" /var/folders -type d -name gtd-with-agents 2>/dev/null | head -1)
test -n "$SRC" || { echo "FAILED: no skill directory found under TMPDIR or /var/folders"; exit 1; }
mkdir -p .claude/skills && cp -R "$SRC" .claude/skills/
```

The cache lives under the system temporary directory, which is `/var/folders` on macOS and
`$TMPDIR` elsewhere, so both get searched. **The guard is the point**: with no match, `SRC` is
empty and `cp -R "" .claude/skills/` copies nothing while reporting an error about an argument
rather than about the skill. Naming the failure costs one line.

Where a release bundle *is* available, unzip works instead. **Give them one of these, not several.**

All their projects:

```sh
mkdir -p ~/.claude/skills
unzip -q gtd-with-agents.skill -d ~/.claude/skills
```

Or this project only, shared with whoever has the repository:

```sh
mkdir -p .claude/skills
unzip -q gtd-with-agents.skill -d .claude/skills
```

**Verify the copy by hash, not by count.** Thirteen files present says nothing about thirteen files
intact.

The bundle carries its own folder, so it unzips **into** the skills directory and lands at
`<dir>/gtd-with-agents/SKILL.md`. Then `/gtd-with-agents` works in a new session there.

Say plainly why it is worth the second install: the bootstrap prompt tells that agent what to do
**once**, and the skill is what lets it re-read the protocol in month three when a question comes
up. Without it, `reference/protocol.md` is a path that agent cannot open, and the only copy of the
format it can reach is the one in the channel.

**If they decline or cannot**, that is a workable configuration and not a broken one — the two
copied channel files exist for exactly this case.

**Either way, fill the "Where the method itself is installed" table in the configuration**, one
row per agent, dated. Then say out loud what that table is and is not:

> Neither agent can see the other's session, so **it is a self-report with a date, not a
> verification** — the same distinction `head: sha:` makes against `head: clock:`. Every session
> compares its own row before doing anything else; agreeing is silent, and **disagreeing produces a
> channel message with `state: open` and `to: owner`, not an edit to the configuration.** Two agents correcting their own rows would
> give that file two writers, which is the shape `protocol.md` rejects for a shared status file —
> so the state is derived here too: the table is what was set up, a later message is the fresher
> fact, and the person folds it back in.

Both bootstrap prompts carry that comparison already. The reviewing side also reads the *other*
row, because an agent that cannot open `reference/protocol.md` has to be cited channel files
rather than reference paths — and a divergence from the protocol by an agent that cannot read the
protocol is a missing document, not carelessness.

**And capture the install itself.** An install is a verdict handed down from outside the project:
it happens elsewhere, comes back as a yes or a no, and leaves nothing behind unless somebody
catches it. **Write the log before attempting, with the outcome blank**, so an attempt nobody
finished looks unfinished rather than absent — the same shape the floor verification log has, and
for the same reason:

```sh
mkdir -p .runs
LOG=".runs/$(date -u +%Y%m%d-%H%M%S)-install.log"
{
  echo "=== install · $(date -u '+%F %T')Z ==="
  echo "artefact: <what was installed, and which version>"
  echo "target:   <where>"
  echo "outcome:"
} > "$LOG"
echo "LOG: $LOG"
```

Then the person pastes what the installer said, **verbatim**, onto the `outcome:` line, and the
path goes in the configuration. `never claim it installs without a path`, the same rule the floor
already lives under.

This rule was written after two bundles were refused, and **the repository that wrote it broke it
within the hour** — the next install left no log, and the installer's exact words survive only in
a code comment. That is the third reason in `verification.md` §12 happening to the file that
publishes it, which is why the block above exists rather than a paragraph asking nicely.

Tell them plainly what the method does *not* do, in your own words:

> No file wakes anyone up. Cowork cannot answer a permission prompt in Claude Code — those are
> modal and live inside its interface. What disappears is the copying and the transcription risk,
> not the turn-taking.

A method that promises more than that is lying, and the person will find out at the worst moment.

---

## Running the method

Once installed, four things govern the work. Each has a reference file; read the one you need
rather than all of them.

| | |
|---|---|
| `reference/resuming.md` | **Arriving cold at a project that already runs this.** The derivation as front door, what to read, what not to read, and when you are up to date |
| `reference/roles.md` | The three parts, and the **state/events frontier** that makes review possible |
| `reference/protocol.md` | The channel: file names, front matter, immutability, and why each choice |
| `reference/approvals.md` | The questionnaire, the traffic-light triage, the floor |
| `reference/verification.md` | Why agreement between two agents is worth anything: declared scope, verifiers proven by breaking them, measurement rules |
| `reference/floor-mechanism.md` | How to put a real mechanism behind the floor, and how to prove it refuses. **Four tool-agnostic steps, then a worked example in one tool** — the second half is an annex, like the file below |
| `reference/git-annex.md` | Only what depends on having a repository |

### The two rules to carry without opening anything

**Cowork verifies state, not events.** It can read files; it cannot know whether something ran or
what it returned. If the project does not record it, the answer is *"no record here"* — never
*"not done"*. This is why every command block writes its output to a file: it turns an event into
state, and then anyone can read it afterwards.

**A check whose failure mode is to report success is worse than no check.** Everything in
`reference/verification.md` is that sentence applied to a different surface.

### Everything the person is asked is recorded too

Not only agent-to-agent traffic. When a session asks the person something, they answer inside
that session and **the other one never learns it happened** — an event that leaves no state. The
second agent then reasons about a project shaped by a decision it cannot see.

So anything the person is asked, and what they answered, goes in the channel under `from: owner`,
written by whichever agent heard it **and read by the other before it proposes anything** — in
both directions. A permission prompt answered in the implementing session and a scope decision
taken in the reviewing one are the same kind of event, and **the second is the one that gets
forgotten**, even though it is usually the bigger decision.

A permission prompt blocks, so it is recorded immediately afterwards rather than before. The test
for what belongs there is narrow: **would the other agent behave differently if it knew this?**

This does not let the reviewing agent answer a prompt — that limit is unchanged. It means it
knows the prompt happened, which is the part that was costing something.

### Disagreement

Two agents who disagree **do not escalate**. They exchange until one of them is shown a fact,
with the command that produced it. What reaches the person is what survived the facts, marked
`state: escalated`.

A number that does not reproduce is not a disagreement yet. Check first whether the two sides are
measuring the same object.

---

## Keeping the person informed

Goal 1 is *pull*, not push: they ask, in under two minutes, without asking either agent. Write the
command into the configuration and check it returns something before claiming it works.

**A consensus that changes a plan, a guide or a scope lands in a permanent project file in the same
milestone, or it did not happen.** `--lands-in` makes the writer refuse without it; `--audit`
checks afterwards that the path exists and is tracked.

### When they ask what happens next

Three sections, and nothing that does not fit in one of them:

| | |
|---|---|
| **What I am doing now** | Without asking. Already started |
| **What you run** | Complete blocks, ready to paste |
| **What you decide** | Options, the cost of each, and a recommendation |

**Every observation carries a proposal, or it is not finished.** *"The uncommitted tree is fourteen
entries and grows every half hour"* is true, well measured, and useless: it names a rising cost
without saying how to stop paying it. The method demands rigour in observing and demanded nothing
of turning that into action, so a diligent agent produces an impeccable diagnosis and stops —
because stopping there was never flagged.

**After a DECIDE is answered, execution is delegated** unless the answer says otherwise. The
contract splits decision rights and says nothing about who resumes the work once the decision
exists; the silence resolves as waiting, which is the most expensive default there is. Measured: a
decision taken hours earlier, both agents believing it belonged to the other — *"nobody has told me
to do anything, why is it still not done?"*

**The person is never the dispatcher.** *"What would you like me to work on?"* is a failure, not a
courtesy. An agent with spare capacity proposes what it will do and does it, or says what blocks it.

### How much of the session belongs to the method

The method's own queue always has work — a stale consensus to close, a rule to write, a figure to
re-measure — and the project's does not, so an agent with spare capacity drains the wrong one.
Every rule leaves an artefact in seconds; reviewing two hundred lines produces nothing visible for
twenty minutes.

**The smell test: if at the close of a session the method's artefacts outnumber the project's, the
method ate the session.** Group its maintenance at milestone boundaries rather than *whenever you
notice*, and make the last act of the session belong to the project, as the first act belongs to
the method.

---

## When you are asked to do this without the skill's assets

If for any reason the reference or asset files are unavailable, the method still reduces to
something you can set up from this file alone: a directory, one immutable file per message with
the five front-matter keys, a configuration file recording who decides what, and the floor above.
Say which parts you are reconstructing rather than pretending the full method is installed.
