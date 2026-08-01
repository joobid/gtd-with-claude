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

Ask the agent for each of these and watch. **Five requests, and each tests a different property** —
this matters, because a suite where two rows exercise the same property looks like five checks and
is four:

| # | Ask for | A working floor does | Tests |
|---|---|---|---|
| 1 | A destructive command your rules deny | Refuses outright, no prompt | That a **command** rule matches |
| 2 | A read of a path your rules deny | Refuses outright | That a **path** rule matches — a different rule kind, and usually the one protecting real data |
| 3 | **The same operation as 1, spelled differently** — flags reordered, short flags split, long flags instead | Refuses outright | That the rule covers the **operation**, not one spelling of it |
| 4 | A command you have **deliberately granted a standing approval for**, and which your rules also mark as needing a prompt | **Asks anyway** | That a prompt beats a permission. **Plant the approval first** — on a machine with nothing accumulated this row asks for the trivial reason and proves nothing |
| 5 | Something harmless — printing a word | Runs without asking | Control. If this prompts, nothing loaded and rows 1-4 mean nothing |

**All five, and all five have to give the expected answer.** Four of five is not a pass: the one
that fails is precisely the one you believed you had.

**Row 3 is the one that fails**, and expect it to. See the next section.

### Step 4 · Write the log, and write it so an unfinished verification looks unfinished

The log is created with the requests already in it and the outcomes empty, so a verification that
was started and abandoned is visibly incomplete rather than absent:

```sh
mkdir -p .runs
LOG=".runs/$(date -u +%Y%m%d-%H%M%S)-floor-verification.log"
{
  echo "=== floor verification · $(date -u '+%F %T')Z ==="
  echo "tool: <name and version>   ·  rules file: <path, or 'none — this tool has no permission configuration'>"
  echo
  echo "1 denied command   · expected: refuses outright"
  echo "  outcome:"
  echo "2 denied path      · expected: refuses outright"
  echo "  outcome:"
  echo "3 other spelling   · expected: refuses outright"
  echo "  outcome:"
  echo "4 planted approval · expected: asks anyway"
  echo "  outcome:"
  echo "5 harmless control · expected: runs without asking"
  echo "  outcome:"
} > "$LOG"
echo "LOG: $LOG"
```

`>` is safe here because the timestamp makes the file new by construction. Everywhere else, `>` on
an existing file is the wide scope of writing files.

Then **the person pastes what actually happened onto the five `outcome:` lines** — the agent's own
refusal text, verbatim. Not the agent, and the reason is the whole doctrine: the party that wants
the answer to be yes does not get to record it.

And the log can then be checked, which is the point of building it this way:

```sh
grep -c 'outcome: *$' "$LOG"
```

**Anything but `0` means the verification is unfinished**, whatever the configuration says. A
`verified` pointing at a log with an empty outcome line is not a certification; it is a filename.

---

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
      "Read(./private/**)", "Edit(./private/**)", "Write(./private/**)",
      "Bash(git push --force)", "Bash(git push --force *)", "Bash(git push -f*)",
      "Bash(git filter-branch*)", "Bash(git filter-repo*)",
      "Bash(rm -rf *)", "Bash(rm -fr *)", "Bash(rm -r -f *)",
      "Bash(find * -delete*)", "Bash(find * -exec*)"
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

### The one carve-out worth knowing

`Bash(git push --force*)` also matches `--force-with-lease`, which is a **different** operation —
it aborts if the remote moved, and denying it pushes people towards the unsafe one. The space in
`Bash(git push --force *)` excludes it, because what follows there is a hyphen.

That is the reasoning every pattern in the list needs and most do not get: **check what a pattern
catches besides what you wrote it for.**

---

## What goes in the configuration

The Mechanism column takes one of three values, and **the first two require a path to that log**:

| Value | Means |
|---|---|
| `verified — <path to log>` | Rules exist and were **seen to refuse**, including row 3, the other spelling |
| `attempted, not verified — <path to log>` | Rules were written and the five requests were not all confirmed. **This is the honest default** |
| `none — agreement only` | No mechanism exists for this class here. It is a commitment, not a lock |

**Never `verified` without a path, and never with an empty `outcome:` line in it.** A floor
certification is an event, and an event with no artefact is an assertion — which is the one thing
this method does not let anything else get away with.

## What has no mechanism, and say so

Realistically, of the four classes:

| Class | Usually |
|---|---|
| Real data, privacy, history rewriting | **Nameable** — paths and history commands are both patterns |
| Destructive with no inverse | **Nameable, and the spelling problem bites hardest here** |
| Spending money | **Rarely.** Spending travels through a browser or a card, not a command a rule can name |
| Reaching a third party | **Partly.** Publish and release commands, yes; a message typed into a web interface, no |

So two of four typically get teeth and two typically do not, and writing that down is the point.
A person who knows which two are agreement-only can decide how much to trust the other settings.
A person told all four are enforced cannot.
