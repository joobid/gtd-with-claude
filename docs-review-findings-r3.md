# Adversarial review · round 3 · the prose checker, and what the fixes broke

> **Exempt from the repository's language rule** only in that it is a review artefact, not part of
> the skill, and it declares that here. It is absent from `MANIFEST`, and the pipeline's
> completeness step only checks `reference/` and `assets/`, so nothing will ever stage it.

Round 1 read. Round 2 executed. Round 3 executes **the instrument that was built because round 2
executed** — and the answer is short enough to put at the top:

**The three failures in run 30708254775 are all the checker's own arithmetic. The documentation is
right and the checker is wrong.** All three canonical queries return exactly the fixture's ground
truth when run on their own: 3 open, 1 live escalation, 2 owner decisions. The checker sums whole
blocks against a single expectation, counts error messages as results, never reads a return code,
and in one case reports a number for a command that never executed.

And the consequence is not academic. The failing step runs **before** staging, so a false failure in
a checker written yesterday is the only thing standing between this project and its first published
bundle. I reproduced every step after it from the `v0.1` tree: they pass.

Second headline, and it is the one worth more: **the checker cannot detect the class of defect it
was built to detect.** Its fixture is not written by the documented writer, whatever its docstring
says. I reintroduced R2-01 verbatim and it stayed silent.

---

## What was examined, and what was not

| | |
|---|---|
| **Examined** | All 27 files, including the three new since round 2: `scripts/check_doc_commands.py`, `reference/floor-mechanism.md`, and the git history at `v0.1` |
| **Executed** | `check_doc_commands.py` and `--self-test`; every documented query decomposed and run alone against the checker's own fixture; four deliberate mutations of the checker's inputs; `validate_skill.py` self-test with a rule deleted; the MANIFEST-completeness step both ways; the validator's MANIFEST discovery from three working directories; every release step **after** the one that failed, from the `v0.1` tree; the floor verification log block; a markdown render of `approvals.md` |
| **Executed against both polarities** | The isolated owner query (correct → passes, R2-01 reintroduced → **not caught**); the MANIFEST-completeness step (clean → passes, new file → FATAL); the traffic-light render; deny-pattern matching across ten command spellings |
| **MODELLED, not executed — declared** | The deny rules in `floor-mechanism.md`. I matched ten command spellings against the eleven `Bash(...)` patterns with `fnmatch`. **This is a model of the matcher, not the matcher.** The conclusion below holds under glob *or* prefix semantics, because none of the escaping forms shares a prefix with any pattern — but the exact engine was not run |
| **NOT executed** | The real workflow. `gh` is not installed here and the sandbox has no route to `origin`. Everything I say about steps 7-11 is a **local reproduction from the tagged tree**, which is evidence about the commands and not about the runner |
| **NOT executed** | Skill activation. Round 2 used a declared proxy; I can do no better, and there is now a second reason — the release failed, so **no bundle has ever been published**. See §6 |
| **Could not check** | `find . -newermt yesterday` on macOS. Third round, still Linux, still flagged rather than asserted |
| **No record here** | Whether `.claude/settings.json` precedence behaves as `floor-mechanism.md` describes. I have no Claude Code permission engine to run. The file's claims about `deny` beating `allow` are **unverified from here** — which matters, because that is the file's central claim |

**State this was written against:** `head: sha:eb33746`, tag `v0.1`, working tree clean apart from
`docs-review-prompt-round3.md`. First round with a real commit reference.

---

# 1 · QA results

## 1.1 · The prose checker

| Test | Expected | Obtained | |
|---|---|---|---|
| `check_doc_commands.py` reproduces the CI failure | 3 FAILs | 3 FAILs, same lines | **reproduced** |
| `protocol.md:273` open-questions query, run alone | 3 | 3 | **PASS — docs correct** |
| `protocol.md:281` live-escalations query, run alone | 1 | 1 | **PASS — docs correct** |
| `protocol.md:289` owner query, run alone | 2 | 2 | **PASS — docs correct** |
| `ls -1 \| tail -20`, the other line in that block | — | 12 | 2 + 12 = the "returned 14" |
| Correct query isolated in its block | no finding | no finding | **PASS** |
| **NEG** · R2-01 reintroduced (`grep -l '^from: owner'`) in that isolated block | caught | **returned 2, no finding** | **FAIL → R3-02** |
| **NEG** · correct query the checker cannot classify | judged or excluded | counted in scope (`seen` 5→6), never compared | **FAIL → R3-12** |
| `config-template.md:96` block return code | inspected | `rc=1`, never inspected | **FAIL → R3-03** |
| …and its `grep` actually runs | runs | **never runs** — `<channel>` is read by bash as a redirect | **FAIL → R3-03** |
| Self-test exit code | 0 when healthy | 1 — it cannot return 0 while `ok` is False | **FAIL → R3-04** |
| Self-test positive line | proves detection | `not ok2`, true from the pre-existing failures | **FAIL → R3-04** |
| Declared scope vs reality | all documented blocks | 13 ` ```sh ` blocks in the tree, 8 in `DOCS`, **5 counted** | **FAIL → R3-11** |

Decomposition of the third CI failure, run exactly as the checker runs it:

```
block at line 96: returncode=1  lines=18
   | ./20260801-100000-cowork-q1.md          <- find, 12 lines
   | ...                                        (includes ./README.md and ./message-template.md)
   | fatal: not a git repository (or any parent up to mount point /)
   | Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
   | ls: cannot access '.runs/exchange/*.md': No such file or directory
   | ls: cannot access '.runs/*.log': No such file or directory
   | ls: cannot access 'exchange/*.md': No such file or directory
   | bash: line 11: channel: No such file or directory
```

Twelve lines of `find`, six lines of error, and **zero lines from the query the failure is reported
against.**

## 1.2 · Round 2's fixes, re-executed

| Test | Expected | Obtained | |
|---|---|---|---|
| R2-01 · any single-space query left | none | none | **PASS** |
| R2-01 · every hardened query anchored | all | 14 of the `from:`/`re:` greps have no `$`; the `state:` ones do | **partial → R3-16** |
| R2-03 · open query no longer matches the channel README | 3 | 3 | **PASS — closed** |
| R2-02 · traffic-light table renders with the 🔴 row | 4 rows | 4 rows, 🔴 inside the table | **PASS — closed** |
| R2-04 · delete the `SKILL.md exists` rule **and** its early return | screams | `FileNotFoundError`, exit ≠ 0 | **PASS — closed** (it screams by crashing, which counts) |
| R2-05 · one-file bundle via the documented invocation | rejected | manifest auto-found; `BLIND` when none | **PASS — closed** |
| R2-09 · new `reference/` file absent from MANIFEST | caught | `FATAL: reference/escalation.md is in the tree and not in MANIFEST` | **PASS — closed** |
| R2-13 · `protocol.md:6` author vocabulary | `code \| cowork` | `code \| cowork` | **PASS — closed** |
| R2-16 · README Releases figures | not stale | rewritten to keep the count in the code | **PASS — closed, and well** |
| R2-12 · bootstrap prompts named and written to the project | named | `gtd-bootstrap-code.md`, `gtd-bootstrap-cowork.md` at `README.md:245` | **PASS — closed** |
| R2-15 · repository exists, bundle and `.runs/` untracked | untracked | `git check-ignore` confirms both | **PASS — closed** |
| R2-07 · escalation query back in the cold-start prompt | present | **absent** — FIRST ACTION still lists only `ls -1` and the owner grep | **FAIL — still open** |
| R2-08 · config template ships a correct example | correct | still the bare `grep -lE '^state: +escalated$'`, returns 2 where 1 is live | **FAIL — still open** |
| R2-10 · gain/cost wordings | 24 | 3 | **FAIL — still open** |
| R2-14 · anything checks the `consensus`/`re:` rule | something | nothing; a consensus query gets `want=None` | **FAIL — still open** |

## 1.3 · The release pipeline, steps after the failure

Reproduced locally from `git archive v0.1`, in the YAML's own order.

| Step | Expected | Obtained | |
|---|---|---|---|
| Nothing shippable missing from MANIFEST | passes | `every shippable file is listed` | **PASS** |
| **NEG** · same step with a new unlisted file | FATAL | `FATAL: reference/escalation.md …` | **PASS** |
| Stage exactly what MANIFEST lists | 13 | 13 | **PASS** |
| Build the bundle | zip | 48K, 13 files + 3 dir entries | **PASS** |
| Validate the extracted bundle | VALID | `12 rules over 13 files (1 shipping SKILL.md, 13 manifest paths)` VALID | **PASS** |
| `README.md` and review artefacts absent | absent | only `assets/exchange-README.md` | **PASS** |

**Every step after the one that failed passes.** The bundle is publishable today; a broken checker
is what is stopping it.

## 1.4 · The floor mechanism

| Test | Expected | Obtained | |
|---|---|---|---|
| Run the verification log block (`floor-mechanism.md:108-117`) | evidence of a refusal | a rule **count** and the line `--- record here what each of the four requests actually did ---` | **FAIL → R3-06** |
| `git push --force origin main` denied | denied | denied | **PASS** |
| `git push --force-with-lease` **not** denied | not denied | not denied | **PASS — the carve-out is correct** |
| `git push origin main --force` denied | denied | **allowed** | **FAIL → R3-07** |
| `git push origin +main:main` denied | denied | **allowed** | **FAIL → R3-07** |
| `rm -rf build/` denied | denied | denied | **PASS** |
| `rm -fr` / `rm -r -f` / `rm --recursive --force` denied | denied | **allowed, all three** | **FAIL → R3-07** |
| `xargs rm -rf`, `eval 'rm -rf /'` on `ask` | on ask | **in neither list** | **FAIL → R3-07** |

## 1.5 · NOT APPLICABLE

| Test | Expected | Obtained | |
|---|---|---|---|
| Present everywhere the levels are enumerated | 4 documents | `approvals.md`, `config-template.md` only | **FAIL → R3-09** |
| `README.md:187-191` level table | 4 rows | 3 rows | **FAIL** |
| `SKILL.md:66-70` level table | 4 rows | 3 rows | **FAIL** |

---

# 2 · The three discrepancies, one at a time

You asked for my reading of each, not yours. Here it is.

## 2.1 · Self-test green, real check red — which is it?

**The self-test proves something that is not what fails.** It is not that the instrument works and
the documentation is broken.

`check_doc_commands.py:139` reads `return 0 if (ok and not ok2) else 1`. `ok` is the unmodified run,
which is False today. So the self-test **cannot return 0 while any documented block disagrees with
the fixture** — and both invocations in fact exited 1. The word "green" applies only to the printed
line `ok notices an extra owner message`, and that line is `not ok2`.

`ok2` is False for exactly the same three aggregation reasons `ok` is False. Proven by running the
checker over `protocol.md` alone:

```
   baseline with only protocol.md: ['reference/protocol.md:289 returned 14, the fixture has 2 owner']
   after adding an extra owner message: caught -> ['reference/protocol.md:289 returned 16, ...']
```

The baseline **already fails**. The mutation moved 14 to 16, and either number is a finding, so
`not ok2` would print `ok` whether the mutation were detected, undetected, or absent. **The positive
signal is true by pre-existing failure.**

This is round 2's R2-04 — a mutation caught by a gate other than the rule it names — reproduced in
the instrument built after round 2. The shape survived the fix and moved house.

## 2.2 · The returned files do not match the label

**The checker maps one whole fenced block to one expectation and counts every output line against
it.** `check_doc_commands.py:105-107`:

```python
want = ("open" if "state: +open" in block or "state: open" in block else
        "escalated" if "escalated" in block else
        "owner" if "owner" in block else None)
```

`exchange-README.md:70` is a single block containing four queries. Its label is `open`, because
`state: +open` appears first in the text. Its number is 3 + 1 + 2 + 12 = **18**. The first four
lines printed are the open list followed by the escalation list, which is why an escalation appears
under "open". `protocol.md:289` is 2 + 12 = **14**, the 12 being `ls -1 | tail -20`.

`config-template.md:96` returns `./message-template.md` under "escalated" for a different reason:
that line comes from `find . -newermt yesterday`, which returns every file in the fixture directory,
including the two documents the channel carries.

So: **none of the three failures is a documentation defect.** All three are the comparator. Which
means — and this is the part worth saying plainly — **the checker has not yet found a single defect
in the documentation.** It has found three defects in itself.

## 2.3 · Why the numbers move between environments

Two different causes, and neither is the checker being non-deterministic.

**The line number moved because the file moved.** `extract` computes the fence's line from the file
it is reading. `config-template.md:88` locally and `:96` in CI means the two runs read two different
versions of that file — eight lines were added ahead of the block between them. That is
`verification.md`'s own shelf-life rule: a figure taken correctly, five minutes before the object
moved, looks exactly like a current one.

**The count moved because the block's output is environment-dependent by construction.** Of the 18
lines, 12 come from `find` over a directory whose contents and mtimes are created at run time, and
6 are error text on stderr, which `run()` merges into stdout at line 89. One of those errors varies
by mount layout — demonstrated on this machine, same command, two directories:

```
   in the checker's TMPDIR: 2 line(s)
     | fatal: not a git repository (or any parent up to mount point /)
     | Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
   in /tmp:                  1 line(s)
```

18 here, 17 on a runner where `/tmp` is not a separate mount. **A verdict that depends on where the
temporary directory is mounted is not a verdict.** The root cause is that the checker compares a
*line count* where it means to compare a *set of filenames*, and a line count absorbs anything that
prints.

---

# 3 · New findings, by cost

---

## R3-01 · The checker compares whole blocks against one expectation, and has found no documentation defect yet

**DEFECT — highest cost, because it is currently blocking the release**

**What it says.** `check_doc_commands.py:2` — *"Run every shell command this repository documents,
against a fixture channel."* And `:104-108`, which is where it stops being that:

```python
n = len([x for x in out.splitlines() if x.strip()])
want = ("open" if ... else "escalated" if ... else "owner" if ... else None)
if want and n != EXPECT[want]:
```

**Why it bites.** One `want` per block, one `n` per block, and a block may hold four queries. Every
number it has ever reported is a sum. Measured: the three protocol queries return 3, 1 and 2 —
**exactly** the fixture's ground truth — and the checker reports 14 for the block containing one of
them.

Three consequences, and the third is the expensive one:

1. The CI failure is false, and `release.yml:67` runs it before `:72` staging. So a correct,
   validated, publishable bundle has never been built by the pipeline because a comparator written
   the same day says three correct queries are wrong.
2. A reader of that output learns nothing about the documentation and something misleading about
   it — the FAIL text names a file and a line that are correct.
3. Because the failure is loud and permanent, it will be normalised. A check that is always red is
   a check nobody reads, which is the same end state as one that is always green.

**What I propose.** Compare **sets, not totals**, and per command rather than per block:

- Split blocks on blank lines or comment headers, so one comparable claim is one unit. The comment
  lines already in these blocks (`# Open questions: …`, `# What the person needs to look at: …`)
  are exactly the right delimiters and are already there.
- Record, per unit, the expected **filenames** and compare sets. `EXPECT` becomes
  `{"open": {"…-q1.md", "…-q2.md", "…-q3.md"}, …}`. A set comparison cannot be satisfied by a
  coincidental total, and its failure message names which file is missing or extra.
- Ignore stderr for counting, and **fail any block whose return code is non-zero** as a separate,
  differently-worded finding — "this command did not run" is not the same finding as "this command
  returned the wrong thing".

On (e), your question of whether this is the right instrument: **yes in kind, no in comparator.**
Running the documented commands against a fixture with known ground truth is the correct idea and I
would not replace it. What is wrong is that it compares the one property that cannot distinguish a
right answer from a right total.

---

## R3-02 · The fixture is not built by the documented writer, and the docstring says it is

**DEFECT — this is why the instrument cannot catch what it was built for**

**What it says.** `check_doc_commands.py:25-27`:

> *"The fixture is built here rather than shipped, so it cannot drift from the format the documents
> describe: **the messages are created by the very command `assets/message-template.md` documents**,
> and the ground truth is known by construction."*

**What it does.** `check_doc_commands.py:60-63`:

```python
def msg(name, frm, to, re_, state):
    (ch / name).write_text(
        f"---\nfrom: {frm}\nto: {to}\nre: {re_}\nstate: {state}\n"
        f"head: clock:20260801T120000Z\n---\n\nbody\n", encoding="utf-8")
```

A hand-rolled second implementation of the format. `message-template.md`'s `cat > "$MSG" <<EOF`
block is never invoked.

**Why it bites.** R2-01 was a **drift between the writer and the queries** — the writer emitted two
spaces, the queries expected one. A fixture written by an independent implementation agrees with
whichever side the implementer had in mind, and cannot see the gap. Proven, twice over:

- Reintroduced R2-01 verbatim in an isolated block — `grep -l '^from: owner' *.md` — and the checker
  reported **no finding**, because the hand-rolled fixture writes one space and the broken query
  matches it. The exact defect that motivated this file's existence passes through it silently.
- Reintroduced the padding in `message-template.md` itself. The fixture was byte-identical:
  `fixture message front matter line 1: 'from: owner'`.

So the docstring is a false executable claim in the file whose stated purpose is to stop false
executable claims. That is not irony worth enjoying; it is the finding, because it means the file's
central guarantee is unearned.

**What I propose.** Build the fixture by extracting and running the block from
`message-template.md`, with the variables substituted — the same extraction machinery `extract()`
already provides. Then a change to the documented writer changes the fixture, and a query that stops
matching it fails. If that is too circular for comfort, the honest fallback is to keep the
hand-rolled writer **and delete the docstring's claim**, and add a separate assertion that the two
implementations produce identical front matter. Either way the current text has to go.

---

## R3-03 · One block never executes, and the checker reports a number for it

**DEFECT**

**What it says.** `config-template.md:96-106` ends with:

```sh
grep -lE '^state: +escalated$' <channel>/*.md
```

**Why it bites.** `<channel>` is a placeholder. Bash reads `<` as input redirection, tries to open a
file named `channel`, fails, and the command never runs:

```
| bash: line 11: channel: No such file or directory
```

`run()` returns `rc=1`. `check()` at line 103 discards it — `rc, out = run(...)` and `rc` is never
read again. The block is then scored on the 18 lines produced by everything around it. So the
checker reports *"config-template.md:96 returned 18, the fixture has 1 escalated"* about a query
that did not execute.

This generalises: **every documented block containing an angle-bracket placeholder is unrunnable**,
and there are twelve such lines across `bootstrap-code.md`, `bootstrap-cowork.md` and
`config-template.md`. The two bootstrap prompts escape the checker entirely for a second reason —
their commands sit in plain ` ``` ` fences, not ` ```sh `, so `extract()` never sees them. Those are
the commands the two agents actually run.

**What I propose.** Two things, and the first is one line:

- Treat a non-zero return code as its own finding, worded as *"this documented command did not
  run"*. Today the loudest possible failure — a command that cannot execute at all — is invisible
  underneath a wrong number.
- Give the checker a substitution table (`<channel>` → the fixture path, `<runs directory>` → a temp
  dir) and let it read plain fences in the bootstrap files. Otherwise the rule "a command block is a
  claim" is enforced on the documents that describe the commands and not on the documents that
  issue them.

---

## R3-04 · The self-test's positive signal is true by pre-existing failure

**DEFECT**

Covered in §2.1 with the evidence. Stated as a finding: `check_doc_commands.py:131-139` prints
`ok notices an extra owner message` whenever the unmodified run has any finding at all, which is
independent of whether the mutation was noticed. And `return 0 if (ok and not ok2)` means the
self-test can never pass while the checker is reporting anything — so it cannot be used to validate
the checker separately from the documents it checks, which is the one job a self-test has.

**What I propose.** Compare the finding **sets**, not the booleans: the mutation is detected if and
only if `findings(mutated) - findings(baseline)` contains a finding about the owner query. That is
true regardless of how many pre-existing failures there are, and it is the same set-not-total move
as R3-01. And run the self-test against a **known-good fixture and known-good query set** held in
the test itself, so a broken document cannot disable the instrument's proof of itself.

---

## R3-05 · The deny rules cover one spelling of each operation

**DEFECT — modelled, not executed; see the declaration above**

**What it says.** `floor-mechanism.md:62-77` ships a worked `deny` list, and `:88-104` a four-request
verification whose two deny rows are `git push --force origin main` and `rm -rf build/`.

**Why it bites.** Matching ten spellings against the eleven `Bash(...)` patterns:

```
   DENIED   git push --force origin main               the doc's own test row 1
   ALLOWED  git push --force-with-lease origin main    must NOT be denied - correct
   ALLOWED  git push origin main --force               force push, flag after the refspec
   ALLOWED  git push origin +main:main                 force push via refspec, no --force at all
   DENIED   rm -rf build/                              the doc's own test row 2
   ALLOWED  rm -fr build/                              same operation, flags swapped
   ALLOWED  rm -r -f build/                            same operation, flags split
   ALLOWED  rm --recursive --force build/              same operation, long flags
   ALLOWED  xargs rm -rf                               wrapper the doc says must be on ask
   ALLOWED  eval 'rm -rf /'                            wrapper the doc says must be on ask
```

Each of the doc's two deny tests exercises **precisely the one spelling that is covered.** A person
following Step 3 sees both refuse, writes `verified` in the configuration, and has a floor that is
open to `rm -fr`, to `git push origin +main:main` — a force push with no flag at all — and to flags
placed after the refspec, which is ordinary usage rather than an exotic bypass.

And the file contradicts itself on wrappers. `:85-86`: *"`xargs`, `find -exec`, `watch`, `eval` run
whatever they are given… **They stay on `ask`, always.**"* In the shipped config, `find * -exec*` is
in **deny**, and `xargs`, `watch` and `eval` are in **neither list**. The paragraph names four, the
example handles one, and handles it in the other category.

The `--force-with-lease` carve-out, by contrast, is correct and I verified it. That is the one place
in this file where a pattern was reasoned about against a neighbour, and it is exactly the reasoning
the rest of the list needs.

**What I propose.** Either widen the patterns to the operation rather than the spelling — for `rm`,
that means denying `Bash(rm *)` and putting the safe forms on `ask` — or **say in the file that these
patterns are illustrative and incomplete, and that a floor built from them is `attempted, not
verified` until the person has tested the spellings their own work uses.** The second is cheaper and
more honest, and it is compatible with the file's own thesis. What does not work is a worked example
whose two tests are the two cases it was written to pass.

---

## R3-06 · The verification log contains no evidence of a verification

**DEFECT**

**What it says.** `floor-mechanism.md:123-133`: the Mechanism column takes `verified — <path to log>`,
and *"**Never `verified` without a path.** … a floor certification is an event, and an event with no
artefact is an assertion."* Correct, and it is the right rule.

**What the log contains.** I ran the block at `:108-117` against a settings file built from the
file's own example:

```
| === floor verification · 2026-08-01 16:54:28Z ===
| deny 11 ask 6
| --- record here what each of the four requests actually did ---
```

A timestamp, a **count of rules in a JSON file**, and a placeholder inviting a human to type in what
happened. Nothing in it records a refusal. Nothing in it could distinguish a floor that blocked all
four requests from one that blocked none — the rule count is identical either way, because it reads
the file rather than the behaviour.

So the obligation moved from *an unsupported assertion* to *an unsupported assertion with a
filename*. `verified — .runs/…-floor-verification.log` will pass every review, including this one, by
existing. This is R2-06 one turn further in: round 2 found a certification with no procedure; the
procedure now exists and certifies nothing.

Two smaller things in the same block: `python3 -c "…json.load(open('.claude/settings.json'))…"`
throws if the person put their rules in `settings.local.json` — which `:49` describes as a normal
place for them — and `2>&1 | tee` writes the traceback into the log, which is then cited as
verification.

**What I propose.** The log has to contain the four requests and their four outcomes, and the
outcomes cannot be typed by the same agent that wants the answer to be yes. Two workable shapes,
and I do not know which is right for a modal permission prompt:

- The person pastes the agent's four refusal messages into the log. Slow, honest, and it is the
  person confirming an event only they can see — which is the same shape as everything else the
  floor asks of them.
- The agent writes the four requests into the log **before** attempting them and the outcome after,
  so a missing outcome is visible as a gap rather than as an absence. That at least makes an
  unfinished verification look unfinished.

Until one exists, the honest Mechanism value for every row is `attempted, not verified`.

---

## R3-07 · Two of the four verification requests test the same thing, and one cannot fail on a clean machine

**DECISIÓN SIN TOMAR**

**What it says.** `floor-mechanism.md:101-104`: *"**All four, and all four have to give the expected
answer.** Three of four is not a pass: **each one tests a different precedence**, and the one that
fails is precisely the one you believed you had."*

**Why it bites.** Read the four rows against that claim:

| Row | Claims to test | Actually tests |
|---|---|---|
| `git push --force origin main` | deny | that a deny pattern matches |
| `rm -rf build/` | deny | **that a deny pattern matches** — same property, different pattern |
| `git push` | *"`ask` beats an inherited `allow`"* | that the command asks. On a machine with no accumulated `allow`, it asks anyway |
| `echo hello` | control: config loaded | that `echo` is not blocked. Whether it asks by default is a property of the tool the file never states |

Rows 1 and 2 do not test different precedences; they test the same rule twice. Row 3 is the one you
suspected: on a fresh install its expected result and its failure mode produce the same observation
for different reasons, so it cannot distinguish "ask beat allow" from "nothing was configured and
the tool asked because it always asks". And row 4 is a control whose expected reading depends on a
default the document does not state — if the tool asks about `echo` by default, a correctly loaded
config reads as *"nothing loaded"*.

**What I propose.** Row 3 only means what it claims if an `allow` is deliberately planted first —
so the procedure needs a fifth step: *add a permissive `allow` for `Bash(git push*)`, then confirm
`ask` still wins.* Without that, drop the claim and describe row 3 as a smoke test. And row 2 should
be replaced with something that tests a different property — the obvious candidate is a **path**
rule (`Read(./clients/**)`), since the file denies paths as well as commands and nothing currently
tests that half at all.

---

## R3-08 · The checker's declared scope excludes the newest file containing commands

**LAGUNA**

**What it says.** `check_doc_commands.py:43-45` lists eight documents. `EXAMINED: 5 command blocks
over 8 documents`.

**Measured:**

```
   ```sh blocks in the tree:            13
   ```sh blocks in the eight DOCS:       8
   blocks the checker actually counted:  5
   reference/floor-mechanism.md:         2 blocks, NOT in DOCS
```

Four of the eight listed documents — `README.md`, `SKILL.md`, and both bootstraps — contain **no**
` ```sh ` blocks at all, so the denominator is inflated by files that cannot contribute. Three of the
eight blocks are dropped by the `"grep" not in block` filter at `:100`, silently and without
appearing in the declared scope.

And `reference/floor-mechanism.md` — added yesterday, containing the procedure that is the entire
R2-06 fix, with two runnable blocks including the one in R3-06 — is not checked. **The fix for
"there is no procedure" shipped a procedure with executable claims in it, and the instrument built to
run executable claims does not look at it.** The list at `:43` was not updated when the file was
added, and nothing connects the two.

This is the third round in which a declared scope has been printed and not judged: round 1 found it
in the validator's frontmatter-only pass, round 2 in the extracted-bundle step, and here it is in
the file written to answer round 2.

**What I propose.** Derive `DOCS` from the tree — every `.md` under `reference/`, `assets/` and the
two roots, minus review artefacts — rather than listing it. A hand-maintained list measures whoever
wrote it, which is `protocol.md:43` quoted back. And report the filter's drops explicitly:
`5 of 8 blocks compared, 3 skipped as non-queries`.

---

## R3-09 · A correct query the checker cannot classify is counted and never judged

**DEFECT**

Added a correct, non-aggregated query — `grep -lE '^state: +consensus$' *.md`, which returns exactly
the 2 consensus messages in the fixture — as its own block in `protocol.md`. Result: `seen` went from
5 to 6, and no comparison was made, because `want` falls through to `None` at
`check_doc_commands.py:107`.

So the declared scope grows while the judged scope does not, and the two are reported as one number.
Any future query over `state: settled`, over `to:`, or over the `consensus`/`re:` rule that round 1
asked for and round 2 found unenforced, will be silently uncompared — and will make the instrument
*look* like it is covering more.

**What I propose.** `want is None` must be a finding, not a skip: *"block at X contains a query this
checker has no ground truth for"*. That converts an invisible gap into a visible one, which is the
whole doctrine.

---

## R3-10 · The README does not know about either file added since round 2

**DEFECT**

`README.md:388-406`, "What is in here", lists **five** reference files. There are six.
`reference/floor-mechanism.md` is absent, and `grep -c floor-mechanism README.md` returns **0** — the
README never mentions it anywhere. `scripts/check_doc_commands.py` is likewise absent from the
listing, though `release.yml` runs it.

And the sentence immediately after the listing, `README.md:408`:

> *"The core needs no repository. `git-annex.md` is the only file that assumes one."*

That is now false in the way that matters most. `floor-mechanism.md` ships in the core, is listed in
`MANIFEST`, and assumes Claude Code specifically, a `.claude/settings.json` path, that tool's
`permissions` schema, `git`, and `python3`. `git-annex.md` exists precisely to quarantine
tool-specific assumptions; the new file makes the same kind of assumption without the quarantine, and
the sentence that promised the quarantine was not revisited.

This is the pattern you asked me to look for, in its clearest instance this round: the R2-06 fix
touched `SKILL.md`, `config-template.md`, `MANIFEST` and a new `reference/` file, and did not touch
the README — which is the document a person reads before adopting any of it.

**What I propose.** Add both files to the listing. Then decide the harder half, which is a real
decision: either `floor-mechanism.md` is an annex like `git-annex.md` and the sentence becomes *"the
core needs no repository and no particular tool; `git-annex.md` and `floor-mechanism.md` are the two
files that assume one"* — or the tool-specific material moves into a clearly-marked section and the
core keeps the three-step shape only.

---

## R3-11 · NOT APPLICABLE exists in half the documents that enumerate the levels

**DEFECT**

| Document | Levels listed |
|---|---|
| `reference/approvals.md:14-17` | 4 |
| `assets/config-template.md:34,43-47` | 4 |
| `README.md:187-191` | **3** |
| `SKILL.md:66-70` | **3** |

A cold session reading `SKILL.md` — which `SKILL.md:60-62` makes the entry point for running the
questionnaire — will offer three levels. The fourth exists in the file it is told to read for detail,
and in the template it is told to fill. Which of the two an agent follows is undetermined, and the
questionnaire is the one place in this method where an undetermined option means the person is not
offered a choice they were promised.

Two more things the fix did not settle, and they are your questions:

- **A group of three activities where only one does not apply.** `approvals.md:55` groups
  dependencies, environment configuration and permission files into one question. On a thesis
  project the first two do not apply and the third does. Nothing says whether NOT APPLICABLE is
  answerable per group or only per row, and `config-template.md` has one row per activity while the
  questionnaire has one question per group. The agent must split a grouped answer into per-row
  values with no rule for doing it.
- **How it differs from an unfilled blank.** `config-template.md:47` requires a reason in the Notes
  column, which is the right instinct — but nothing checks it, and a row reading
  `NOT APPLICABLE | |` is indistinguishable from a row nobody reached. Given that
  `README.md:325` treats the configuration as the artefact to re-read when the method drifts, an
  unreasoned NOT APPLICABLE is worse than a blank, because a blank still looks unfinished.

**What I propose.** Add the row to both level tables. And make the reason structural rather than
requested: `NOT APPLICABLE — <reason>` as a single value, so an empty reason is a malformed value
rather than a missing note.

---

## R3-12 · R2-08 is still open, and it is the one worked example a person copies

**DEFECT — carried, not new**

`config-template.md:106`: `grep -lE '^state: +escalated$' <channel>/*.md`, presented under *"In
either case, what still needs the person"*. Measured on the checker's own fixture: it returns **2**
where **1** is live. `protocol.md:281-287` has the derived query that returns 1, and
`exchange-README.md:66-68` explains at length why the bare form is wrong.

It also cannot run at all, for the `<channel>` reason in R3-03. So the block in the configuration
template — the file whose §Part 4 instruction (`approvals.md:198-199`) is *"do not invent one per
installation, because then some of them do not work and nobody finds out"* — contains a command that
does not run and would give the wrong answer if it did.

**What I propose.** Replace the line with the derived query, and add a fixture-backed expectation for
it once R3-01 makes per-command comparison possible. This is the single highest-value thing the fixed
checker would catch on its first correct run.

---

## R3-13 · R2-07 is still open: the cold-start prompt still cannot find what needs the person

**DEFECT — carried**

`bootstrap-cowork.md:31-39`, FIRST ACTION, still lists `ls -1` and the owner grep and points at the
channel README for open questions. There is still no escalation query anywhere in the cold-start
path. The only occurrence of "escalated" in the file is `:57`, prose about what to do when two agents
disagree.

Round 2 reported this. The round-2 fixes touched `exchange-README.md`, `protocol.md` and
`config-template.md` — every place the queries live except the prompt that tells a session which
queries to run first.

---

## R3-14 · The validator will adopt a MANIFEST from the current directory

**DECISIÓN SIN TOMAR**

`validate_skill.py:279`:

```python
for cand in (root / "MANIFEST", Path.cwd() / "MANIFEST", root.parent / "MANIFEST"):
```

Measured, with a two-path MANIFEST planted in an unrelated directory and none next to the target:

```
   (manifest found at /tmp/gtd-qa3-20260801/twoman/MANIFEST)
   BLIND: 1 of 2 manifest paths are absent from …/skill
```

The same bundle gets a different verdict depending on where the shell is standing. Both `Path.cwd()`
and `root.parent` are places that have nothing to do with the artefact being validated — a bundle's
contract belongs beside the bundle.

The mitigation is real and I want to be fair about it: it **prints where it found the manifest**,
which is precisely the declare-what-you-examined habit, and it is why this is a decision rather than
a defect. Someone reading the output can see what happened.

**What I propose.** Drop `Path.cwd()` and `root.parent` from the search, and let the absence of a
manifest beside the target be the `BLIND` it already is when none is found. If the convenience of
running from the repository root matters — which is the actual use case — then special-case exactly
that: a MANIFEST beside `scripts/`, resolved from the script's own location, not from wherever the
user happens to be.

---

## R3-15 · Hardening was applied to `state:` and not to `from:` or `re:`

**LAGUNA — latent**

Round 2's fix anchored the state queries: `'^state: +open$'` — space-tolerant and end-anchored, which
is what stopped the channel README matching itself. The `from:` and `re:` queries got the
space-tolerance and **not** the anchor. Fourteen occurrences across six files, plus three of
`grep -hE '^re:'` with neither tolerance nor anchor:

```
   ./assets/exchange-README.md:72:grep -hE '^re:'
   ./assets/exchange-README.md:78:grep -lE '^from: +owner'
   ./reference/protocol.md:275:grep -hE '^re:'
   …
```

Nothing breaks today: I checked, and no shipped document contains a line starting `from: owner` or a
value that `^from: +owner` would falsely match. But the reason the anchor was added to `state:` was
that the channel carries copies of documents describing the format, and that reason applies
identically to the other two keys. `grep -hE '^re:'` currently pulls `<filename` out of the channel
README's format block into the `answered` set — harmless because no file is named that, which is luck
rather than design.

**What I propose.** `'^from: +owner$'` and `'^re: +'` everywhere, for the same reason the state
queries have it. A fix applied to one of three sibling keys is the shape this project keeps finding.

---

## R3-16 · Smaller, measured

- **`validate_skill.py .` now reports "12 rules over 86 files".** The tree became a repository and
  `rglob("*")` counts `.git`. The declared scope jumped from 14 to 86 with no change in what was
  examined. It is not wrong, but a declared scope whose number is dominated by objects nobody
  validates is a declaration that has stopped meaning what it says. Exclude `.git`.
- **R2-10 is untouched and slightly worse.** Still 3 gain/cost wordings of the 24 the rule at
  `approvals.md:23` requires. NOT APPLICABLE adds a fifth thing the agent must word — the reason —
  with no example anywhere. The rule that *"a person who cannot see the cost has not chosen"* is
  still unowned for five-eighths of the questionnaire, and now has one more unowned field.
- **R2-14 is untouched.** Nothing checks the `consensus`/`re:` constraint, and after R3-09 we know
  that even if someone wrote the query, the checker would count it and never judge it.
- **Neither Spanish prompt file declares its exemption.** Round 2's R2-18. `docs-review-prompt.md`,
  `-round2.md` and now `-round3.md`: three files, zero declarations, while the two findings files
  both carry one.

---

# 4 · What I would not change

- **The instrument itself.** Running documented commands against a fixture is the right idea and the
  right response to round 2. Everything in R3-01 through R3-04 is repairable inside it. Replacing it
  would lose the one genuinely new capability this repository has gained.
- **The `--force-with-lease` carve-out** at `floor-mechanism.md:81-84`. Verified correct: the space
  in `Bash(git push --force *)` does exclude `--force-with-lease`. It is the only pattern in that
  file reasoned about against its neighbour, and the reasoning is right.
- **The README Releases rewrite.** *"The count lives in `validate_skill.py`, not here: a figure
  maintained in two places goes stale in one of them"* — that is round 2's R2-16 fixed by removing the
  class of defect rather than the instance. More of the repository should be written that way.
- **The MANIFEST-completeness step.** Tested both ways, works both ways, and it closes R2-09 by
  construction rather than by discipline.
- **The three protocol queries.** Verified against ground truth: 3, 1, 2. They are correct and the
  checker is what is wrong. Do not touch them to make the checker happy — that is the failure mode
  the brief warned about, and it would be the worst possible outcome of this round.
- **`.runs/` and `*.skill` untracked.** Correct, and `git check-ignore` confirms it rather than the
  `.gitignore` merely claiming it.
- **The pipeline's step order.** Checking the documentation before building the bundle is right;
  a broken checker blocking a good release is an argument for fixing the checker, not for demoting
  the step.
- **The fixture being built rather than shipped.** The reasoning at `check_doc_commands.py:25` is
  sound even though the sentence that follows it is false. Build it — just build it from the
  documented writer.

---

# 5 · The question this method does not ask itself

Round 1: *why two agents.* Round 2: *which sentences are executable, and who ran them.* Both are now
answered in the repository. Here is the third, and it is the one that would have caught almost
everything above.

> **When this check passes, what else would have made it pass?**

The method's doctrine is built on one direction of that question — *has this verifier been seen to
fail?* — and `verification.md:40` states it well. But a check can have been seen to fail once and
still pass for a dozen reasons that have nothing to do with the property it claims to establish.
Nothing in `reference/` asks how **distinctive** a pass is.

Every finding in this round is an instance:

- The prose checker's comparison passes whenever a **total** matches. 18 could have been 3 by
  coincidence; 3 can be right while the set is wrong.
- Its self-test prints `ok` whenever *anything* is failing — the pass is satisfied by noise.
- Its fixture agrees with the queries whenever both were written by the same hand, whether or not the
  documented writer agrees with either.
- The floor's four test requests pass whenever the two spellings someone thought of are the two
  spellings tested; and row 3 passes whether or not `ask` beat anything.
- The floor's verification log satisfies `verified — <path>` whenever **a file exists**.
- `validate_skill.py` passes whenever `12 rules over N files` where N is now mostly `.git`.

That is one shape, six times: **the passing condition is much weaker than the claim it certifies.**
Round 2 asked whether the check had ever been run. Round 3's answer is that running it is necessary
and nowhere near sufficient, because a check nobody has tried to satisfy *dishonestly* has not been
tested against the way checks actually fail — which is not by breaking, but by being satisfiable
another way.

The cheap version of the fix is a habit, and it belongs next to *"a verifier is not trusted until it
has been seen to fail"*: **when you write a check, write down the cheapest wrong thing that would
also pass it.** For a count, that sentence is *"a different set with the same total"* — and writing it
is what makes you compare sets. For the floor log, it is *"an empty file"* — and writing it is what
makes you put the four outcomes in it. For the four requests, it is *"a machine with nothing
configured"* — and writing it is what makes you plant the `allow` first.

The stronger version is the one this repository is now equipped to build: it already has a fixture
with known ground truth. **Mutate the fixture, not just the checker.** Change one message's `state:`,
delete a `re:`, add an owner decision — and require that each mutation changes at least one reported
result. A check that reports the same thing under a fixture that no longer means the same thing is
passing for a reason unrelated to what it claims, and that is measurable rather than merely
suspected.

---

*Reproductions in `/tmp/gtd-qa3-20260801/` — `work/` (mutated tree copies), `pipe/` (the v0.1 release
steps), `floor/` (settings and deny-pattern model), `fx/` (the checker's own fixture, extracted),
`vs/`, `twoman/`, `mstep/`. Nothing in the skill tree was modified; this file is the only thing this
session wrote to it.*
