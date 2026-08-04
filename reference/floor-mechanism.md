# Putting a mechanism behind the floor

The floor is four classes that cannot be delegated. `approvals.md` says what they are and why.
This file is the part that decides whether that promise is worth anything: **what actually stops
them, and how you know.**

Read this during setup, once, when filling the Mechanism column of the configuration.

---

## The problem this file exists to solve

The floor is a rule read by the agent it restricts. This method teaches you to distrust exactly
that shape — *confirm the mechanism, not the document* — so a floor that is only a document is the
phantom control of its own method.

The fix is not to claim more. It is to **put a real mechanism where one exists, verify it, and say
plainly where none does.** A floor that declares which of its rows has teeth is honest; one that
implies all four do is the thing this method exists to catch.

---

## Two obligations, and the second has no exceptions

**1 · Where the tool has a permission configuration, write a rule that refuses.** Not every class
has one, and not every tool has the configuration.

**2 · Whatever you write or fail to write, the outcome leaves an artefact.** Every class, always.

The second is what makes the first honest: an event with no artefact is a claim, and *"verified to
refuse"* with no log behind it is the one assertion this method would otherwise let pass
unsupported.

---

# The procedure

**What this costs the person: ten requests, not five, and roughly half an hour.** Five rows in two
shapes each — bare and wrapped — because a rule matches text and the two forms answer differently.

The first real execution took **72 minutes and 16 requests**, and it only ran the bare half. The
eleven extra were improvised, because the documented rows do not distinguish between the causes of
their own failures. Budget for that second half: it is where every finding was.

*(This paragraph said "fifteen minutes and five approvals" until the doubling instruction below was
added and the cost was not re-examined in the same change — §10 of `verification.md`, committed in
the commit that extends the barrier.)*

**Four steps, and none of them names a tool.** Follow these whatever you are running. The worked
example further down is Claude Code; if you use something else, the example is illustration and
these four steps are the instruction.

### Step 1 · Find out whether standing rules exist at all, and where they live

Not every tool has a permission system. Some ask every time and remember nothing; some keep a
configuration file; some keep two — one shared with the project and one local to the machine.

**Find out which, and read what is already there before writing anything.** Accumulated
*"don't ask again"* approvals collect in the direction of whatever was convenient at the time, and
a broad approval saved months ago can authorise the very thing the floor forbids. A written
prohibition sitting next to a saved approval for it is invisible from either side alone.

**If the tool has no permission configuration, stop here.** The honest value for all four classes
is `none — agreement only`, and writing that down is a result, not a failure. Go to Step 4 — the
log is still owed.

### Step 2 · Write rules for the classes that can be named, and know what a rule matches

A permission rule matches **the text of a command**, not the operation it performs. That gap is
the whole difficulty, and it is why Step 3 exists.

Two things to establish about whatever syntax your tool uses, because the floor depends on both:

- **Does a refusal beat a permission?** If a deny rule loses to an accumulated approval, the floor
  does not override history — it competes with it, and you have to audit what has accumulated.
- **Does a prompt beat a permission?** If not, an old blanket approval silently removes the
  prompt you thought you had.

Then write rules for the classes your tool can name. Typically that is paths (real data) and
command shapes (destructive operations, publishing). Rarely spending.

### Step 3 · Make it refuse, in front of you

**A rule that has not been seen to refuse is a rule nobody has tested**, and the configuration
loading is not the same thing as the rule matching.

**Run each request twice: bare, and inside whatever shape this project's commands normally
take.** A permission rule matches **the text a tool receives**, and a command wrapped in a logging
block, a loop or a heredoc is different text. The two forms give **opposite answers**: measured on
the first real execution, request 1 refused bare and **deleted two files wrapped, with its `deny`
rule active.** The wrapped form is the one your project produces, so the bare run is the optimistic
half of the measurement.

**Two observers, and the log says which one saw each line.** The agent cannot distinguish *"ran
without asking"* from *"prompted, and the person approved"*: both arrive identically, because the
prompt happens in an interface it cannot reach. Writing *"no prompt appeared"* asserts a negative
about an unobservable event — **four false conclusions in a row** on the first execution, all
retracted only when the person said they had seen prompts.

| # | Ask for | A working floor does | Tests |
|---|---|---|---|
| 0 | **Nothing. Read the tool's startup output** after writing the rules | Names no rule of yours | That every rule you wrote is **alive**. Costs nothing, consumes none of the requests, and is the only check here that finds a rule which is not too narrow but entirely inert |
| 1 | A destructive command your rules deny | Refuses outright, no prompt | That a **command** rule matches |
| 2 | A read of a path your rules deny | Refuses outright | That a **path** rule matches — a different rule kind, and usually the one protecting real data. **The file has to exist**: over a missing path, *"I cannot show you that"* is indistinguishable from *"there is nothing there"* |
| 3 | **The same operation as 1, spelled differently** — flags reordered, short flags split, long flags instead | Refuses outright | That the rule covers the **operation**, not one spelling of it |
| 4 | A command you have **deliberately granted a standing approval for**, and which your rules also mark as needing a prompt | **Asks anyway** | That a prompt beats a permission. **Plant the approval first** — on a machine with nothing accumulated this row asks for the trivial reason and proves nothing |
| 5 | Something harmless — printing a word | Runs without asking | Control for `allow` **only**. It passes on a machine with no configuration at all, so it cannot tell you that `deny` or `ask` loaded. Rows 1 and 4 establish those; this one only rules out the case where nothing whatever is in force |
| 6 | **Nothing. Say out loud which classes you did not test and cannot test** | — | That the exercise covered half the floor. Five requests exercise the two nameable classes; spending and messages typed into a web interface get none, and the person is about to decide how much to trust the result |

**Row 2 assumes a path worth denying, and some projects have none.** Where the work *is* reading
the real data, a path deny breaks the work rather than protecting it. Say so, run row 2 expecting
it not to refuse, record `none — agreement only`, and name the mechanism that does apply. The risk
moved: not reading the value, the value **reaching the shared history**.

**Rows 1 and 3 act on the same object and row 1 goes first**, so give each its own target or
regenerate in between and say so.

**All five have to give the expected answer** — four of five is not a pass, because the one that
fails is the one you believed you had. **A row passes in the shape this project actually
produces**; the other shape is recorded and does not score. So a row that refuses bare and executes
wrapped **has failed**, which is what happened to row 1 the first time, and scoring it as a pass
would have inverted the finding.

**Row 3 is the one that fails**, and expect it to. A first pass ending at `attempted, not verified`
has **succeeded**.

#### Handing the requests to the person

They are the only part of this method a person performs, in an interface no agent can reach. Two
attempts failed on presentation alone before either reached a result:

- **Not in a fenced block.** A fenced block is something people paste into a terminal; these are
  sentences typed into an agent's chat. Both failures were this.
- **One at a time**, with what to bring back: verbatim text, and which of the three outcomes.
- **The undo comes last, never alongside.** A restore shown beside the setup gets run first.

### Step 4 · Write the log, and write it so an unfinished verification looks unfinished

**The log is owed whatever happened**, including "no permission system here, nothing written".
An event with no artefact is a claim.

One row per request, and **the row records who observed each half**: the agent saw a result, the
person saw whether a prompt appeared, and neither can report the other's half. A row with the
outcome slot left blank reads as unfinished, which is the point — a template that lets a missing
observation look like a completed one is the defect this whole file is about.

The header says what it ran against: the version, the branch, the rules in force. A verification
that does not say what it verified against cannot be judged still valid later.

```sh
mkdir -p .runs
LOG=".runs/$(date -u +%Y%m%d-%H%M%S)-floor-verification.log"
{
  echo "=== floor verification · $(date -u '+%F %T')Z ==="
  echo "tool: <name and version>   ·  rules file: <path, or 'none — this tool has no permission configuration'>"
  echo
  echo "shape: bare | wrapped   <- run each request in BOTH, they answer differently"
  echo
  echo "0 startup output   · expects: names no rule of yours"
  echo "  outcome:"
  for r in "1 denied command   · expects: refuses outright" \
           "2 denied path      · expects: refuses outright" \
           "3 other spelling   · expects: refuses outright" \
           "4 planted approval · expects: asks anyway" \
           "5 harmless control · expects: runs without asking"; do
    echo "$r"
    for s in bare wrapped; do
      echo "  $s · outcome:"
      echo "  $s · cited:"
      echo "  $s · observed by:"
    done
  done
  echo "6 untested classes · expects: named out loud"
  echo "  outcome:"
} > "$LOG"
echo "LOG: $LOG"
```

**Never `verified` without a path to this file, and never with an empty outcome slot.**

## Why a deny list is weaker than it looks, and what to write instead of pretending otherwise

A rule matches text. An operation has many spellings. So a list written by someone thinking about
the operation covers the spellings that occurred to them, and **the two tests they write are the
two spellings they thought of.**

Measured against the example list below, matching command strings against patterns:

```
DENIED   git push --force origin main             the spelling the list was written for
ALLOWED  git push origin main --force             same operation, flag after the refspec
ALLOWED  git push origin +main:main               same operation, no --force at all
DENIED   rm -rf build/                            the spelling the list was written for
ALLOWED  rm -fr build/                            same operation, flags swapped
ALLOWED  rm -r -f build/                          same operation, flags split
ALLOWED  rm --recursive --force build/            same operation, long flags
```

**This is not a bug in the list; it is what lists do.** Widening it is a race you do not win by
writing more globs — there is always another spelling, and a pattern wide enough to catch them all
usually catches a neighbour it should not.

So two rules follow, and they are the honest ones:

- **Treat every example in this file as illustrative and incomplete.** It is a starting point for
  the spellings *your* work actually uses, not a list to copy and trust.
- **The default Mechanism value is `attempted, not verified`.** A class earns `verified` only
  after row 3 — the *other spelling* — has been seen to refuse, for the spellings that appear in
  your own project. Two rows out of five passing is not a floor; it is the two cases you designed
  for passing the two tests you designed.

### A leading wildcard is the only shape that reaches inside a compound command

Measured, on one tool and one version, and it is the finding that explains everything above:
`Bash(rm -rf *)` **does not match** when the command travels inside `{ … } | tee`;
`Bash(*rm -rf *)` **does**. The matcher decomposes a chain of `&&` and names the rule it used; a
brace group is opaque to it and falls through to a generic warning about *syntax* instead.

That is a `deny` degraded into an `ask` **that names the wrong reason**. The protection is not
lost — something still stops — but the *information* is. The person approving does not decide
*"yes, delete that directory"*, they decide *"yes, this command has braces"*, and all the care
that went into distinguishing `rm -fr` from `rm -r -f` never reaches the one who presses the
button. Nine prompts on the first execution: **three cited a rule and five cited syntax**, and all
five of the syntax ones were approved.

**The cost of the leading wildcard is real and it is in the argument, not the verb.**
`Bash(*rm -rf *)` also refuses `echo "never use rm -rf"` — writing *about* a dangerous command
becomes as restricted as running it, and documenting this very finding in a commit message would
trip it.

Take the trade anyway: it is asymmetric in your favour. A false positive costs a rephrasing; the
false negative it closes deleted two files.

And one shape that cannot be fixed by widening at all: **a wrapper runs whatever it is handed.**
`xargs`, `find -exec`, `watch`, `eval` — a rule permitting the wrapper permits everything it can
be given. They belong on *prompt every time*, never on a standing approval, and no prefix makes
that safe.

---

# The worked example: Claude Code

**Everything from here down assumes one specific tool.** The four steps above are the method; this
is what they look like in the tool this skill is most often used with. Adapt the paths and the
syntax; keep the steps.

### Where the rules live

```sh
ls -la .claude/settings.json .claude/settings.local.json 2>/dev/null
```

| | |
|---|---|
| `.claude/settings.json` | Shared with the project. Its **allow** rules may need a workspace-trust step; **deny** and **ask** apply regardless |
| `.claude/settings.local.json` | This machine only. Where accumulated *"don't ask again"* approvals land |

Read the local file first, for the reason in Step 1.

### The two precedence questions, answered for this tool

**`deny` beats `allow` from any scope**, and **`ask` beats `allow` even when the `allow` is more
specific.** So the floor overrides what has accumulated rather than having to audit it — which is
what row 4 of Step 3 exists to confirm rather than assume.

### A starting point, not a list to trust

```json
{
  "permissions": {
    "deny": [
      "Read(./private/**)", "Edit(./private/**)",
      "Edit(./.runs/exchange/**)",
      "Bash(git push --force)", "Bash(git push --force *)", "Bash(git push -f*)",
      "Bash(git filter-branch*)", "Bash(git filter-repo*)",
      "Bash(rm -rf *)", "Bash(rm -fr *)", "Bash(rm -r -f *)",
      "Bash(find * -delete*)", "Bash(find * -exec*)"
    ],
    "allow": [
      "Edit(./.runs/*.log)"
    ],
    "ask": [
      "Bash(rm *)", "Bash(xargs*)", "Bash(watch*)", "Bash(eval*)",
      "Bash(git push*)", "Bash(gh release*)", "Bash(gh pr*)",
      "Bash(npm publish*)", "Bash(pip install*)", "Bash(npm install*)"
    ]
  }
}
```

Replace `./private/**` with whatever holds real data in your project. Note `Bash(rm *)` on `ask`
underneath the specific denies: that is the shape to copy — **deny the spellings you know, and put
the whole operation behind a prompt so an unlisted spelling still stops.** It is the only defence
against the table above that does not depend on having thought of every flag order.

### `Write(path)` is accepted and evaluates nothing

There used to be a `Write(./private/**)` in that list, in the same triple as `Read` and `Edit`, and
**it was inert**. File permission checks match `Edit(path)` only, and `Edit` already covers every
file-editing tool, so the third member of the triple is dead weight that reads as protection.

Measured: three such rules sat in a configuration written by following this very procedure, valid
JSON, present in the file, evaluating nothing. **The only thing that caught them was the tool's own
startup output**, which named them one by one and said what to use instead.

So the procedure gains a **row 0**, before the five requests: **read the startup output after every
configuration change.** It costs nothing, it consumes none of the ten requests, and it is the only
verifier here that finds a rule which is not merely too narrow but entirely dead.

### The two rules the channel needs, and their criteria are opposite

The channel's immutability is the most central rule this method has, and until it was written down
here it was a promise. `protocol.md` is categorical — *"nothing here is ever reopened: a correction
is a new file that answers the old one"* — and explains that a rewritable message is a record that
can lose most of itself without anyone seeing, because the tools that watch a project watch *which*
files changed and not how much of each. Then it left it as doctrine, which is the exact shape this
file exists to distrust.

```
deny:  Edit(<channel>/**)     messages are immutable
allow: Edit(<runs>/*.log)     logs are meant to be filled in
```

Two kinds of file living side by side with **opposite** rules, so a single blanket rule over the
run directory gets one of them wrong.

The deny **does not block writing messages.** They are created through shell redirection by
`gtd-msg.sh`, which passes through command rules rather than file permission checks. What it blocks
is reopening one, which is the thing that was never impossible before.

### The one carve-out worth knowing

`Bash(git push --force*)` also matches `--force-with-lease`, which is a **different** operation —
it aborts if the remote moved, and denying it pushes people towards the unsafe one. The space in
`Bash(git push --force *)` excludes it, because what follows there is a hyphen.

That is the reasoning every pattern in the list needs and most do not get: **check what a pattern
catches besides what you wrote it for.**

---

## Before writing a single rule: is this class worth a prompt?

**Ask these three per class, and let the answers decide where it goes.** A modal earns its place
only if all three hold:

1. **Could this person evaluate it with what the prompt itself shows them** — not by opening
   something else?
2. **Can you predict their answer?**
3. **Is being wrong expensive and irreversible?**

**A class that fails 1 and 2 goes to a log, not to `ask`.** An approval that is always granted does
not merely add little: it **costs**. It spends the attention the important one will need, and it
trains the reflex to grant. Measured: a person who configured 23 `deny` and 27 `ask` rules
deliberately, arguing each one in writing, spent the next morning pressing `1` without reading —
*"I always answer yes, I have no way to evaluate it."* Within twenty-four hours.

The reason is that rules are usually written by **technical shape** — `python3 -c`, compound
commands, editing a workflow — and technical shape is the one axis a non-specialist cannot judge.
Worse, it taxes the behaviour this method most wants: **to prove something fails you have to
manufacture the failure**, so rigorous verification looks exactly like arbitrary code. An agent
that skipped the positive control would have interrupted less.

So calibrate on **the exit, not the danger**:

| Ask | Log and never ask |
|---|---|
| Anything reaching a third party — push, PR, release, publish, send | Reading anything |
| Spending money | Running scripts, tests and scanners locally |
| Destroying with no inverse | Editing the working tree — **git is the gate** |
| Changing scope or plan — theirs by contract, not by risk | |

**With one measured caveat that the table above would otherwise hide.** *"Local is free"* is false
where the data is not yours: talking about a value copies it into the run directory, which is
normally outside version control, so the project's barrier has never looked there. The axis is
**provenance of the data**, not reversibility. `channel-status.sh --audit` is what finds it
afterwards, and it is the reason that command exists.

**"Log instead of ask" is only a control if somebody reads the log.** Any rule you drop from *ask*
to *log* must name the query that would catch the bad case, schedule when it runs, and be tested by
breaking it. If you cannot write the query, you cannot drop the rule.

**And review this in a few weeks with the one datum that only appears in use: which prompts have
always been granted.**

## `ask` names a human, so without one it is undefined

Three values, and **one of them presupposes a person**. In a scheduled run with nobody there, every
`ask` rule has no defined behaviour: the tool may hang until a timeout, deny silently, or never
evaluate the file. Measured on a real project — `deny 23 · ask 17 · allow 4` — that is **17 of 44
rules undefined the moment the person is absent.**

So: **an unattended run uses a profile where every `ask` is a `deny`**, and that is a property of
the model rather than advice about configuration. `reference/unattended.md` carries the rest.

**And ask the tool's maintainer what an `ask` does with nobody there. If nobody knows, write that
down** — the same honesty as `attempted, not verified` in the table below.

**One absolute moves out of prose while we are here.** *"Merging is always a human decision"* was
held up on that project by `Bash(gh pr*)` sitting in `ask` — a modal with nobody to answer it. It
belongs in the permanent floor as `deny Bash(gh pr merge*)`, which constrains the agent and not the
person, who runs it in their own terminal. What it does not cover, said in the same breath: a local
`git merge` and a push, or the web interface. It is a rule about one spelling, like all of them.

## What goes in the configuration

The Mechanism column takes one of three values, and **the first two require a path to that log**:

| Value | Means |
|---|---|
| `verified — <path to log>` | Rules exist and were seen to refuse **every spelling that appears in this project's own command history**, row 3 included. That is a claim about a corpus, not about an operation — a deny list matches text, and no list covers an operation |
| `attempted, not verified — <path to log>` | Rules were written and not every request was confirmed. **This is the honest default and, on a first pass, the expected outcome** |
| `none — agreement only` | No mechanism exists for this class here. It is a commitment, not a lock |

**Do not expect `verified` on a first pass, and do not read its absence as a failed exercise.**
This page tells you row 3 is written to fail, and the earlier version of this table then required
row 3 to pass before a class could be `verified` — a scale whose best value the same page predicted
was unreachable. That is a three-value scale with an aspiration hanging off it, and the fix is to
make the top value a **bounded, measurable** claim: not *"the rule covers the operation"*, which no
rule does, but *"the spellings this project actually produces were seen to refuse"*, which somebody
can enumerate and check.

**Where the project does not use this skill's configuration template**, there is no Mechanism
column to fill: put the four values and the log path wherever that project keeps its working
agreement, and say in the log where you put them. A project can run this method without having
installed the skill, and the first one to execute this procedure was exactly that.

**Never `verified` without a path, and never with an empty `outcome:` line in it.** A floor
certification is an event, and an event with no artefact is an assertion — which is the one thing
this method does not let anything else get away with.

## What has no mechanism, and say so

Realistically, of the four classes:

**And the two kinds of rule are not equally strong, which the table below hides.** On the first
real execution the only row that passed cleanly was the **path** one — because it goes through a
different mechanism from the command rules, and is immune to the wrapping problem that sank row 1
and degraded row 3. That is not luck. The practical consequence is worth stating plainly: **of
the four floor classes, the one protected by paths — real data — has a substantially better
mechanism than the one protected by command shapes.**

| Class | Usually |
|---|---|
| Real data, privacy, history rewriting | **Nameable, and by the stronger of the two kinds** — paths, which do not lose their match inside a compound command |
| Destructive with no inverse | **Nameable, and the spelling problem bites hardest here** |
| Spending money | **Rarely.** Spending travels through a browser or a card, not a command a rule can name |
| Reaching a third party | **Partly.** Publish and release commands, yes; a message typed into a web interface, no |

So two of four typically get teeth and two typically do not, and writing that down is the point.
A person who knows which two are agreement-only can decide how much to trust the other settings.
A person told all four are enforced cannot.
