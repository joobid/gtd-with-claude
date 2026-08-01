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

**1 · Where the tool has a permission configuration, write a deny rule.** Not every class has one.
**2 · Whatever you write or fail to write, the outcome leaves an artefact.** Every class, always.

The second is the one that makes the first honest, and it is the reason this file is not just an
example: an event with no artefact is a claim, and *"verified to refuse"* with no log behind it is
the one assertion this method would otherwise allow to go unsupported.

---

## The procedure, with Claude Code as the worked example

Other tools differ; the shape does not. Adapt the paths, keep the three steps.

### Step 1 · Find where the standing rules live

```sh
ls -la .claude/settings.json .claude/settings.local.json 2>/dev/null
```

Two files with different reach, and the difference matters:

| | |
|---|---|
| `.claude/settings.json` | Shared with the project. Its **allow** rules may need a workspace-trust step; **deny** and **ask** apply regardless |
| `.claude/settings.local.json` | This machine only. Where accumulated *"don't ask again"* approvals land |

**Read the local file before writing anything.** Accumulated approvals collect in the direction of
whatever was convenient at the time, and a broad wildcard saved months ago can authorise the very
thing the floor forbids. That combination — a written prohibition and a saved approval for it — is
invisible from either side alone.

### Step 2 · Write the rules, in the tracked file

Precedence is what makes this work: **`deny` beats `allow` from any scope**, and **`ask` beats
`allow` even when the `allow` is more specific.** So the floor does not require auditing whatever
has accumulated — it overrides it.

```json
{
  "permissions": {
    "deny": [
      "Read(./clients/**)", "Edit(./clients/**)", "Write(./clients/**)",
      "Bash(git push --force)", "Bash(git push --force *)", "Bash(git push -f*)",
      "Bash(git filter-branch*)", "Bash(git filter-repo*)",
      "Bash(rm -rf *)", "Bash(find * -delete*)", "Bash(find * -exec*)"
    ],
    "ask": [
      "Bash(git push*)", "Bash(gh release*)", "Bash(gh pr*)",
      "Bash(npm publish*)", "Bash(pip install*)", "Bash(npm install*)"
    ]
  }
}
```

Two cautions learned by getting them wrong:

- **A pattern written for one thing catches its neighbours.** `Bash(git push --force*)` also matches
  `--force-with-lease`, which is a *different* operation — it aborts if the remote moved. Carve it
  out with the space: `Bash(git push --force *)` does not match `--force-with-lease`, because what
  follows there is a hyphen.
- **Wrappers cannot be approved by prefix.** `xargs`, `find -exec`, `watch`, `eval` run whatever
  they are given, so `Bash(xargs *)` would authorise `xargs rm`. They stay on `ask`, always.

### Step 3 · Verify. This is the step that is usually skipped

**A rule that has not been seen to refuse is a rule nobody has tested**, and the file taking effect
is not the same as the rule matching. Ask the agent to run the command that should be blocked, and
watch what happens.

| Ask for | A working rule does | An ineffective rule does |
|---|---|---|
| `git push --force origin main` | Refuses outright, no prompt | Asks for approval, or runs |
| `rm -rf build/` | Refuses outright | Asks, or runs |
| `git push` | **Asks** — proving `ask` beats an inherited `allow` | Runs without asking |
| `echo hello` | Runs without asking | Asks — the config did not load at all |

**All four, and all four have to give the expected answer.** Three of four is not a pass: each one
tests a different precedence, and the one that fails is precisely the one you believed you had. The
last row is the control — if a harmless command starts prompting, nothing loaded and the other
three results mean nothing.

Then **write the output to a log**, because this is an event:

```sh
mkdir -p .runs
LOG=".runs/$(date -u +%Y%m%d-%H%M%S)-floor-verification.log"
{
  echo "=== floor verification · $(date -u '+%F %T')Z ==="
  python3 -c "import json;d=json.load(open('.claude/settings.json'))['permissions'];print('deny',len(d.get('deny',[])),'ask',len(d.get('ask',[])))"
  echo "--- record here what each of the four requests actually did ---"
} 2>&1 | tee "$LOG"
echo "LOG: $LOG"
```

---

## What goes in the configuration

The Mechanism column takes one of three values, and **the first two require a path to that log**:

| Value | Means |
|---|---|
| `verified — <path to log>` | A rule exists and was **seen to refuse** |
| `attempted, not verified — <path to log>` | A rule was written and nobody watched it work. Honest, and weaker than it looks |
| `none — agreement only` | No mechanism exists for this class here. It is a commitment, not a lock |

**Never `verified` without a path.** The whole point of this file is that a floor certification is
an event, and an event with no artefact is an assertion — which is the one thing this method does
not let anything else get away with.

## What has no mechanism, and say so

Realistically, of the four classes:

| Class | Usually |
|---|---|
| Real data, privacy, history rewriting | **Deniable** — paths and history commands are both patterns |
| Destructive with no inverse | **Deniable** — `rm`, `--delete`, `-exec` |
| Spending money | **Rarely.** Spending travels through a browser or a card, not a command a rule can name |
| Reaching a third party | **Partly.** Publish and release commands, yes; a message typed into a web interface, no |

So two of four typically get teeth and two typically do not, and writing that down is the point.
A person who knows which two are agreement-only can decide how much to trust the other settings.
A person told all four are enforced cannot.
