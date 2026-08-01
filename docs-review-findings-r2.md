# Adversarial review · round 2 · QA results and findings

> **Exempt from the repository's language rule** only in that it is a review artefact, not part of
> the skill, and it declares that here. It is absent from `MANIFEST`, so it cannot ship inside the
> bundle. If it ever does, that is a finding about the pipeline.

Round 1 was a reading. This one is an execution: everything below that says PASS or FAIL was run,
and the output is included where it failed. Where something could not be run, it says so and says
why — *"no record here"* is a result; *"does not work"* about something never executed is not.

**Headline, before the detail.** The pipeline is now genuinely sound and the state vocabulary is
coherent. But **five of the shell commands this method ships have never been executed, and four of
them are wrong**, including the single most-cited query in the whole system, which returns nothing
and always will. Round 1 found seventeen problems by reading. This round found the ones that only
appear when you run the thing — which is the round the method's own doctrine says matters.

---

## What was examined, and what was not

| | |
|---|---|
| **Examined** | All 21 files in the tree, including the four added since round 1: `MANIFEST`, `.gitignore`, `docs-review-prompt-round2.md`, and round 1's own report |
| **Executed** | The release pipeline reproduced step by step; the validator and its self-test; 4 negative bundle cases; 1 invented failure; a 40-message channel built with the shipped template command; all 5 shipped channel queries, verbatim; the setup walked end to end on a non-software project; a markdown renderer over `approvals.md` |
| **Executed against both polarities** | The validator (7 mutations + clean), the manifest gate (missing file / present file), `head:` (with repo → `sha:`, without → `clock:`), the `from: owner` query (broken form / working form) |
| **PROXY ONLY — declared** | **A1, skill activation.** I cannot install a skill and open cold sessions from inside one session. What I ran instead: a subagent given the description verbatim alongside 8 competing skill descriptions, deciding per message. That measures the description's discriminative power, **not** the real dispatcher. Treat the rate below as an indication, not a measurement |
| **Could not check** | Whether `find . -newermt yesterday` (`config-template.md:95`) works on macOS. The sandbox is Linux/GNU; BSD `find` parses date strings differently. **Not tested — flagged, not asserted** |
| **Could not check** | Whether an installed `gtd-with-claude` skill actually loads. The bundle is well-formed and validates; that is not the same as observing Cowork load it |
| **Not examined** | The sixteen catalogued defects behind `README.md:346`. They still exist nowhere in this tree, so the 8/6/2 classification cannot be verified from here — see B2(d) below |

**State this was written against:** `head: clock:20260801T131300Z`. Still not a `sha:` — the tree is
still not a repository, which is finding R2-15.

---

# 1 · QA results

## A5 · The release pipeline — reproduced step by step

| Test | Expected | Obtained | |
|---|---|---|---|
| Self-test with manifest (`release.yml:44`) | 7 mutations rejected, clean accepted | 7 rejected, clean accepted, exit 0 | **PASS** |
| Validate source tree (`:47`) | VALID, 12 manifest paths | `12 rules over 14 files (1 shipping SKILL.md, 12 manifest paths)` VALID | **PASS** |
| Stage from MANIFEST (`:49-58`) | 12 files | 12 files | **PASS** |
| MANIFEST trailing newline | last entry staged | present; 12 of 12 read by `while read` | **PASS** |
| Extract + validate bundle (`:76-82`) | VALID with manifest | VALID, exit 0 | **PASS** |
| `README.md` absent from bundle | absent | absent (only `assets/exchange-README.md`) | **PASS** |
| Committed bundle vs tree | — | identical on all 12 manifest paths, no extra files | **PASS** |
| **NEG** · bundle missing one manifest file | rejected | `BLIND: 1 of 12 manifest paths are absent` exit 1 | **PASS** |
| **NEG** · single-file bundle, with manifest | rejected | `BLIND: 11 of 12` exit 1 | **PASS** — round 1's F10 is closed here |
| **NEG** · MANIFEST lists a nonexistent path | rejected | `BLIND: 1 of 13` exit 1 | **PASS** |
| **NEG** · single-file bundle, using the command `README.md:428` documents | rejected | `EXAMINED: 12 rules over 1 files (…, no manifest given)` / **VALID** / exit 0 | **FAIL → R2-05** |
| **NEG** · does the self-test still test its own rules? | yes | deleted the `SKILL.md exists at the root` rule; self-test still printed `ok rejects: no SKILL.md at all` and exited 0 | **FAIL → R2-04** |
| **INVENTED** · new `reference/` file cited by SKILL.md, forgotten in MANIFEST | caught | pipeline green, bundle ships without it, shipped SKILL.md cites a file that is not there | **FAIL → R2-09** |

## A4 · The channel, 40 messages

Built with the command in `assets/message-template.md`, verbatim. Ground truth by construction:
**10 genuinely unanswered open questions · 2 live escalations · 6 `from: owner` messages.**

| Test | Expected | Obtained | |
|---|---|---|---|
| Open-questions query (`exchange-README.md:71-75`) | 10 | **11** — the channel's own `README.md` is returned as an open question | **FAIL → R2-03** |
| Live-escalations query (`:78-81`) | 2 | **4** — every escalation ever, including both closed ones | **FAIL → R2-01** |
| `grep -lE '^from: +owner' *.md` (`:83`) | 6 | **0** | **FAIL → R2-01** |
| Same query, tolerant form `'^from: +owner'` | 6 | 6 | (this is the fix) |
| Filename timestamp is UTC | UTC | `20260801-131039` vs local `20260801-151039` (CEST) | **PASS** |
| `head:` carries a prefix, with a repo | `sha:` | `head:  sha:1c45b61` | **PASS** |
| `head:` carries a prefix, without one | `clock:` | `head:  clock:20260801T130958Z` | **PASS** |
| Body appended with `>>` keeps the header | intact | header intact, 10 lines | **PASS** |
| Nothing tries to compare a `clock:` | no comparison | `protocol.md:191`, `message-template.md:122` both say judge from content | **PASS** |
| **NEG** · plant a `state: consensus` with `re: -` | surfaced by something | surfaced by nothing that ships | **FAIL → R2-14** |

Root cause of the two query failures, measured:

```
[debug] what the front matter actually contains:
      6 from:  owner        <- two spaces, written by message-template.md:33
[debug] cat -A: from:  owner$
   one space  : 0 of 6      <- grep -lE '^from: +owner'   (every document in the tree)
   two spaces : 6 of 6
```

## A2 · The questionnaire, installed on a non-software project

Test project: a doctoral thesis. No repository, no dependencies, no tests, no branches.

| Test | Expected | Obtained | |
|---|---|---|---|
| Channel created with **two** files | README + template | both present | **PASS** — round 1's F4 closed |
| Questionnaire answers written as first `from: owner` message | present and findable | written, and **the documented query returns 0** | **FAIL → R2-01** |
| Config has one row per thing asked | 8 rows, no gaps | 8 rows | **PASS** |
| Every option carries its cost in the same sentence | 24 gain/cost pairs (8 activities × 3 levels) | **3 supplied** in `approvals.md:28-36` | **FAIL → R2-10** |
| Activities that apply to a non-software project | 8 of 8, or a way to say no | 5 of 8; **no NOT-APPLICABLE value exists** | **FAIL → R2-11** |
| Both bootstrap prompts written into the project | present | **required by `SKILL.md:146`, no filename, no asset, and `README.md:246` still says they are in `assets/`** | **FAIL → R2-12** |
| "Since yesterday" command shipped rather than invented | worked examples | present at `config-template.md:88-100` | **PASS** — F8a closed |
| …and the examples are correct | correct | one of the three is the bare `grep -E '^state: +escalated$'` this method replaced | **FAIL → R2-08** |

## A3 · The floor

| Test | Expected | Obtained | |
|---|---|---|---|
| The three delegation requests are refused with a reason and a safe alternative | scripted | `SKILL.md:89-91`, `approvals.md:135-140` instruct exactly this, with the alternative | **PASS, as instruction** |
| The floor is described honestly as a commitment, not a lock | honest | `README.md:213`, `SKILL.md:95` say it plainly | **PASS** — round 1's F1a closed, and well |
| Both missing classes added to the daily 🔴 row | present | present in the source text | **PASS in text** |
| …and the 🔴 row still renders as part of the table | in the table | **renders as a literal paragraph outside the table** | **FAIL → R2-02** |
| "Deny rule, verified to refuse" has a procedure | some procedure | 4 mentions; **0 files name a permission file, a syntax, or a test command** | **FAIL → R2-06** |

I did not observe a refusal, because I cannot make the skill run a questionnaire at me. What I can
report is stronger than "it says it will": **the refusal is scripted in two places with the reason
and the alternative, and the verification of the mechanism is scripted nowhere.** That asymmetry is
R2-06.

## A1 · Activation — PROXY, not a measurement

Subagent given the description verbatim against 8 competing skills, judging per message.

| | Rate | Detail |
|---|---|---|
| Should activate | **6 / 6** | all six fired, both languages, on the phrases they were written for |
| Should not activate | **3 / 4** | *"revisa este PR"*, *"escríbeme un README"*, *"how do two microservices talk to each other"* all correctly did not fire |
| False positive | **1** | *"¿qué permisos le doy a Claude Code para que no me pregunte tanto?"* fired on *"how do I stay informed without approving everything"* and *"an approval policy"* |

The microservices near-miss did **not** fire, despite *"talk to each other"* appearing verbatim in
the description — the proxy resolved it by topic. That one is not a problem.

The permissions near-miss did. See R2-17 for what I would change, and note the proxy's own
observation, which is the more useful half: three of the quoted trigger phrases —
*"who decides what here"*, *"how much can I delegate"*, *"how do I stay informed without approving
everything"* — **mention no agent, no Claude Code and no Cowork**, so they read as ordinary
governance questions about people.

---

# 2 · Round 1: what is closed, and what is not

Checked by re-running, not by reading the previous report.

| | Finding | Status |
|---|---|---|
| F1a | Floor described as mechanism | **Closed.** `README.md:211-227` is the best writing in the repository |
| F1b | Money + third party missing from 🔴 | **Text fixed, rendering broken** → R2-02 |
| F1c | No mechanism behind the floor | **Half.** Instruction added, procedure absent → R2-06 |
| F2 | `consensus` unilateral | **Documented, unenforced** → R2-14 |
| F3 | Owner record: language + read-back | **Closed.** `exchange-README.md:41-43`, `protocol.md:87-98`, both bootstraps |
| F4 | Code cannot reach the template | **Closed and verified.** `SKILL.md:118-129` copies both files; the reasoning added is correct |
| F5 | `head:` without a repository | **Closed and verified both ways.** The `sha:`/`clock:` split is the right answer |
| F6 | Channel queries | **Redesigned correctly, and the implementation does not work** → R2-01, R2-03 |
| F7 | Bootstrap prompts not persisted | **Half** → R2-12 |
| F8 | "Since yesterday" | **Half.** Examples shipped, probe rule added; one example is wrong → R2-08 |
| F9 | Who executes | **Closed.** `roles.md:21-25` and `README.md:297-302` settle it, and the logging rule is now unconditional |
| F10 | Pipeline validated the wrong object | **Closed in the pipeline, open in the documented command** → R2-05 |
| F11a | No state for a person's decision | **Closed.** `settled` + `to: both` |
| F11b | Both worked examples mislabelled | **Closed.** `README.md:99` is now `escalated` |
| F11c | No `to: both` | **Closed** |
| F12 | Questionnaire answers not in the channel | **Added, and neutralised by R2-01** — see below |
| F13 | "Carries its own check" undefined | **Closed.** `approvals.md:156-160` — and that paragraph is what broke the table |
| F14 | No precedence rule | **Closed.** `protocol.md:100-108` |
| F15 | Timezone | **Closed and verified.** UTC on both lines |
| F16a | Not a repository | **Open** → R2-15 |
| F16b | Undeclared language exemption | **Half.** The findings file declares it; neither prompt file does |
| F16c | README ships inside the bundle | **Closed and verified.** MANIFEST excludes it, with the reason written in MANIFEST itself |
| F17a-c | Counting, config rows, milestone rule | **Closed** |
| F17d | Filename author | **Half** → R2-13 |

**The F12 case is worth stating on its own**, because it is the clearest illustration of what this
round is about. `SKILL.md:137-140` added Step 5 with this justification:

> *"without this step `grep -E '^from: +owner'` returns nothing on day one while both agents are told to
> treat it as the list of what is settled."*

I performed Step 5 on the test project. The documented query returns **0**. The fix was correct, was
applied, and is neutralised by a defect in the query it was written to feed — introduced by a
different round-1 fix, in a different file, in the same pass.

---

# 3 · New findings

Ordered by what it costs if nobody fixes it.

---

## R2-01 · `grep -lE '^from: +owner'` matches nothing, in every file that cites it

**DEFECT — highest cost in this round**

**What it says.** Ten citations across six files. `exchange-README.md:83`:

```
grep -lE '^from: +owner' *.md      # every decision the person has made
```

Also `README.md:165`, `protocol.md:161` and `:205`, `SKILL.md:139`, `bootstrap-code.md:46`,
`bootstrap-cowork.md:35`, and — the expensive one — inside the live-escalations query at
`exchange-README.md:78` and `protocol.md:154`.

**Why it bites.** The front matter is written by `message-template.md:33`, which is
`from:  $FROM` — **two spaces**. The pattern `-E '^from: +owner'` has one. It never matches.

Measured on the 40-message channel:

```
   one space  : 0 of 6
   two spaces : 6 of 6
   [debug] cat -A on a real message:  from:  owner$
```

Three consequences, in ascending order of cost:

1. The person's own audit tool — *"every decision you have made, findable in one line"*
   (`README.md:162`) — returns an empty list for ever. It fails the same way the method's own
   central sentence describes: it exits zero and prints nothing, and nothing about an empty result
   looks wrong.
2. Both bootstrap prompts instruct their agent to run it **before proposing anything**. Both agents
   will conclude the person has decided nothing, on every session, for ever.
3. The live-escalations query builds its `closed` set from it. Measured: `closed` is empty, so the
   query returned **4 escalations instead of 2** — including both that a `from: owner` message had
   closed. The one query that tells the person what needs them is wrong in the direction of noise,
   which is the direction that gets it ignored.

Note also that the alignment is inconsistent in the template itself: `state:` and `head:` follow one
convention, `from:`, `to:` and `re:` another. Any query written by eye will keep hitting this.

**What I propose.** Two changes, and both are needed:

- Every `^from: owner` becomes `-E '^from: +owner'` in all ten places. Same for any future query
  over a padded key.
- **Stop padding the front matter.** `from: owner` with one space, everywhere, and the template
  writes it that way. Alignment that only exists to look tidy is what created a class of queries
  that cannot match. If the padding stays, then the padding is part of the format and belongs in the
  format description at `protocol.md:11-19`, which today shows it without saying it is significant.

---

## R2-02 · The 🔴 row is not in the traffic-light table

**DEFECT**

**What it says.** `approvals.md:151-161`. The table header and the 🟢 and 🟡 rows are at 151-154.
Then lines 156-160 are a **paragraph** — the round-1 fix defining "carries its own check". Then line
161 resumes with `| 🔴 | Anything that discards unsaved work … spending money, or sending anything to
a third party | No. Bring it to the other agent first |`.

**Why it bites.** A markdown table ends at the first non-table line. Rendered:

```
table rows rendered: 3
    ['', 'What it is', 'What to do']
    ['🟢', 'Reading, searching, status and history', ...]
    ['🟡', 'Adding named files, saving a checkpoin', ...]
is the RED row inside a table? False
--- how the red row actually renders ---
    | 🔴 | Anything that discards unsaved work, force-publishing, deleting, ...
```

The red row renders as a raw line of pipe characters below the table. Two round-1 fixes were applied
to the same six lines — F1b added the two floor classes to the red row, F13 added the definition
paragraph — and the second one severed the first. What fell out is the row that carries the floor
into the daily instrument, which is the whole reason F1b existed. And `approvals.md:163-165`, three
lines later, explains why that row matters: *"A floor that half the daily triage does not mention is
a floor that gets forgotten by Tuesday."*

**What I propose.** Move the definition paragraph below the complete table. Trivial, and then verify
it — which is R2-A in the epilogue.

---

## R2-03 · The open-questions query returns the channel's own README, for ever

**DEFECT**

**What it says.** `exchange-README.md:73`: `for f in $(grep -lE '^state: +open$' *.md); do`.

**Why it bites.** `exchange-README.md:17` — inside the file the query runs over, because
`SKILL.md:122` copies it into the channel as `README.md` — reads:

```
state: open | consensus | settled | escalated
```

`grep -E '^state: +open$'` is a prefix match. It hits. Measured: the query returned **11 files where 10
were live, and the eleventh was `README.md`**, on day one and every day after.

This is the method's own signature defect, in the file that documents the query: *a check that
scans everything except — or in this case including — the instrument itself.* `verification.md:116-126`
is about exactly this shape, and `SKILL.md:122` is what puts the instrument inside the scope.

Note that the escalations query escapes by luck: `^state: escalated` does not prefix-match line 17,
because the line starts with `state: open`. Change the order of the values in that documentation
line and the second query breaks too.

**What I propose.** Anchor the queries to whole values — `grep -lx 'state: open'` won't work with
padding, so `grep -lE '^state: +open$'` — **and** exclude the two copied assets explicitly. The
second is worth doing even after the first, because the channel now contains two documents that
describe the format they live among, and any future query has the same exposure. A one-line
`shopt`-free filter such as `for f in *.md; do case "$f" in README.md|message-template.md) continue;; esac` is
uglier and correct.

---

## R2-04 · The self-test no longer proves the rule it names

**DEFECT — measured by breaking it**

**What it says.** `release.yml:39-42`: *"It mutates a temporary copy once per rule and fails unless
every one is rejected."* `validate_skill.py:181-189` lists seven mutations, one of which is
`"no SKILL.md at all"`.

**Why it bites.** The manifest gate (`validate_skill.py:80-89`) runs **before** the SKILL.md
existence check (`:101`). When the mutation deletes `SKILL.md`, the manifest gate rejects the copy
because `SKILL.md` is a manifest path — so the mutation is caught, but not by the rule it was
written to prove. The rule it names is never exercised.

Proven by deleting that rule and re-running:

```
101:    pass  # RULE DELETED ON PURPOSE
SELF-TEST: 7 deliberate mutations
  ok   rejects: no SKILL.md at all          <- with the rule deleted
  ok   accepts: the unmodified skill
exit=0
```

A self-test that passes with a rule removed is a check whose failure mode is to report success — in
the one script whose docstring (`validate_skill.py:14-16`) claims *"A verifier that has never been
seen to fail is not evidence."* The round-1 fix that made the pipeline correct is what masked it.

**What I propose.** Run each mutation twice: once with the manifest and once without, and require
rejection in both. Two lines in `self_test`. That restores the one-mutation-one-rule property the
comment claims, and it is itself testable by the deletion experiment above.

---

## R2-05 · The command the README documents still passes a one-file bundle

**DEFECT**

**What it says.** `README.md:427-429`:

```
scripts/validate_skill.py <dir>              validate
scripts/validate_skill.py <dir> --self-test  prove it fails when it should
```

Neither documented form passes `--manifest`.

**Why it bites.** Round 1's F10 — a bundle containing only `SKILL.md` returning VALID — is closed in
`release.yml` and **open in the tool as documented**:

```
$ python3 scripts/validate_skill.py b2/gtd-with-claude
EXAMINED: 12 rules over 1 files (1 shipping SKILL.md, no manifest given)
VALID
exit=0
```

The output does declare `no manifest given`. And then it prints `VALID` and exits 0 — which is the
defect `validate_skill.py:74-79` names in its own comment, added in this same round:

> *"The declared scope was printed and never judged, which is the same defect one level up:
> declaring what you examined is worthless if nothing looks at the declaration."*

The comment describes the bug the code still has when invoked the way the README documents.

**What I propose.** Default `--manifest MANIFEST` when a `MANIFEST` file sits next to the target or
in the working directory, and make its absence a `BLIND` result rather than a pass. If someone
genuinely wants frontmatter-only, that becomes an explicit `--no-manifest`, which is a flag nobody
sets by accident. Then update `README.md:427-429`.

---

## R2-06 · "Deny rule, verified to refuse" has no procedure anywhere

**LAGUNA — the highest-stakes one conceptually**

**What it says.** `SKILL.md:102-104`:

> *"Where the tool has a permission configuration, write **deny rules** for the commands these
> classes travel through — and then **verify they refuse**, rather than assuming the file took
> effect. A rule that has not been seen to block is a rule nobody has tested."*

And `config-template.md:55` gives it a slot: `<deny rule, verified to refuse / none — agreement only>`.

**Why it bites.** Measured across the tree: four mentions of the concept, and **zero files that name
a permission file, a path, a syntax, or a command to test one**. No `settings.json`, no
`.claude/`, no example rule, no example refusal.

So the installing agent reaches Step 3 holding an instruction it cannot follow and a form field it
must fill. The three available outcomes are: invent a syntax and get it wrong silently; write
`none — agreement only` for all four rows regardless of what was possible; or write
`deny rule, verified to refuse` having verified nothing. The third is the default failure, because
it is the one that looks like success and matches what the surrounding prose expects.

And then that value is read by every later session as evidence that a mechanism exists. This is
`verification.md:106-113` — *a control that does not exist gets cited in decisions precisely because
nobody interrogates it* — reproduced one level in, by the fix that was written to escape it. Round 1
said the floor was a document pretending to be a mechanism. It is now a document that **certifies**
a mechanism, with no procedure for the certification.

**What I propose.** Either give it a procedure or withdraw the claim; both are honest, and doing
neither is not.

- The procedure version: a short `reference/` section, or an addition to `git-annex.md`, giving one
  worked example — the file, one deny rule, the command that should be refused, and what a refusal
  looks like versus what an ineffective rule looks like. Then the config value means something.
- The withdrawal version: change the slot to `<mechanism attempted: yes/no — verified: yes/no>` and
  require the verification evidence to be a path to a log. `verification.md:199-220` already says
  every event must leave an artefact; a floor certification is an event, and today it is the one
  claim in the method allowed to be an unsupported assertion.

I do not know which is right. It has to be decided, because the current state is the worst of the
two.

---

## R2-07 · The escalation query is gone from the cold-start prompt

**DEFECT**

**What it says.** `bootstrap-cowork.md:31-39`, FIRST ACTION, now lists exactly two commands:

```
  ls -1 <channel> | tail -20
  grep -lE '^from: +owner' <channel>/*.md
```

followed by a paragraph explaining that a bare grep is wrong for open questions and that the real
queries are in the channel README.

**Why it bites.** Round 1's version listed three greps, one of them `state: escalated`. The rewrite
correctly removed the naive open-questions grep and **removed the escalations query with it without
replacing it**. A cold Cowork session — the exact case this file exists for, and by
`roles.md:68-70` the case the method wants you to reach for often — will now list the last twenty
files, run a query that returns nothing (R2-01), and never ask what is waiting for the person.

`roles.md:35` still says the person is brought in when a message is marked `escalated`. Nothing in
the cold-start path looks for one.

**What I propose.** Put it back, pointing at the derived query rather than the bare grep, in the
same sentence as the open-questions pointer. One line.

---

## R2-08 · The config template ships the bare query the method just replaced

**DEFECT**

**What it says.** `config-template.md:98-99`, inside the worked examples for "what has happened since
yesterday":

```sh
# In either case, what still needs the person
grep -lE '^state: +escalated$' <channel>/*.md
```

**Why it bites.** `protocol.md:139-142` and `exchange-README.md:66-68` both spend a paragraph
explaining that this exact shape is wrong — *"a bare `grep -E '^state: +open$'` returns every question
ever asked, which at month three is sixty paths the person cannot triage"* — and the escalated
variant has the same property, verified above (4 returned, 2 live). The one place the person is told
to **copy a command into their own configuration file** hands them the naive version.

`approvals.md:198-199` added the instruction *"`config-template.md` ships worked examples; do not
invent one per installation, because then some of them do not work and nobody finds out."* The
shipped example is one that does not work.

Second, smaller, and **unverified**: `config-template.md:95` uses `find . -newermt yesterday`.
That is GNU syntax. It ran here (Linux). macOS `find` accepts `-newermt` but parses the date
argument differently and may reject the word `yesterday`. **I could not test this — the sandbox is
Linux.** Given that one of the two intended sessions runs on the person's own machine, it is worth
someone running it there before it ships as the no-repository default.

**What I propose.** Replace the line with the derived escalations query from
`exchange-README.md:78-81`, or a pointer to it. And test the `find` line on macOS, or replace it
with something portable.

---

## R2-09 · MANIFEST is checked in one direction only

**LAGUNA — this was the invented failure**

**What it says.** `MANIFEST:3-5`: *"Single source of truth: the release pipeline stages from this
list AND verifies the extracted bundle against it."*

**Why it bites.** It verifies **manifest ⊆ bundle**. Nothing ever checks **tree ⊆ manifest**. A file
added to `reference/` or `assets/` and cited by `SKILL.md`, but not added to MANIFEST, ships as a
dangling reference under a fully green pipeline.

Demonstrated: added `reference/escalation.md`, cited it from `SKILL.md`, left MANIFEST alone.

```
tree has: 6 reference files ; MANIFEST lists: 5
source tree      -> VALID
extracted bundle -> VALID
SKILL.md in the shipped bundle cites reference/escalation.md:  1
is the file in the bundle?  NO — ships a dangling reference, pipeline green
```

This is the failure that will actually happen, because R2-06 and R2-07 both point toward adding a
reference file, and MANIFEST is the step a person forgets — it is a second list that has to be
updated by hand, which `protocol.md:43-44` already identifies as the shape that *"fails the moment
somebody forgot, and fails silently."* The MANIFEST comment claims to have avoided two drifting
lists; it created a tree/manifest pair instead of a stage/verify pair.

**What I propose.** One more check in the pipeline: every `reference/*.md` and `assets/*.md` in the
tree appears in MANIFEST, or the build fails and names it. Deliberate exclusions get an explicit
`# not shipped:` line so the exclusion is a statement rather than an omission. Cheap, and it closes
the failure mode by construction rather than by discipline.

---

## R2-10 · The questionnaire supplies 3 of the 24 option wordings it requires

**LAGUNA**

**What it says.** `approvals.md:23`: *"**Every option is presented with what it gains and what it
costs, in the same sentence.**"* And `:25`: *"A person who cannot see the cost has not chosen — they
have accepted a default with a label on it."*

**Why it bites.** Eight activities × three levels = 24 wordings. Counted in the tree: **three**, at
`approvals.md:28-36` — CONSENSUS for version control, DELEGATED for dependencies, and a generic
DECIDE. For the other five activities the installing agent invents both halves on the spot.

The gain half is easy to invent. The cost half is the one the rule exists to protect, and it is the
one an agent under-produces, because a cost is a reason not to choose the thing the agent just
described. The predictable outcome is three well-argued questions and five that read like
*"CONSENSUS — the agents agree and tell you afterwards"* — which is a default with a label on it,
verbatim what `:25` forbids.

This is not a documentation gap; it is the questionnaire's only stated quality bar, unowned for
five-eighths of the questionnaire.

**What I propose.** Write the remaining 15 wordings into `approvals.md`, next to the activity groups.
It is the single highest-value page of writing left in this repository, and it is the kind of thing
this author writes well — the three that exist are good. If that is too much, then say explicitly
that the three shown are the pattern and that the agent must produce a cost sentence for each
remaining option **and show it**, so a missing cost is visible rather than merely absent.

---

## R2-11 · Three of the eight rows have no honest answer on a non-software project

**DECISIÓN SIN TOMAR — confirms B2(c)**

**What it says.** `README.md:408`: *"The core needs no repository. `git-annex.md` is the only file
that assumes one."*

**Why it bites.** Not having a repository and not being software are different things, and the
questionnaire only handles the first. Walked on a thesis project:

| Activity | On a thesis |
|---|---|
| Recording and publishing work — checkpoints, branches, merges | no branches, no merges |
| Installing dependencies | nothing to install |
| Changing environment configuration | no environment |

Three of eight. And `config-template.md:34-41` offers exactly `<DECIDE / CONSENSUS / DELEGATED>`
with **no NOT-APPLICABLE value** — the only `not applicable` in the tree is at `:25`, about version
control exclusion. So the person answers a question that does not apply, or the agent picks
something, and the config file records a delegation level for an activity that will never occur.
Which is worse than a blank, because `README.md:325` treats the configuration as the thing to
re-read when the method drifts.

The vocabulary reinforces it: `approvals.md` mentions *checkpoint*, *branch*, *merge*, *dependency*,
*test* eleven times between them, and nothing offers a non-software reading of any of them.

I do not think this reopens the closed decision that the core is agnostic. It says the core is
**repository**-agnostic, which it now genuinely is, and is not yet **domain**-agnostic, which it
claims by implication rather than by statement.

**What I propose.** Pick one, and it is a real choice:

- Add `NOT APPLICABLE` to the level vocabulary and one line in `approvals.md` telling the agent to
  offer it and to say why a row got it. Honest, small, and makes the config readable later.
- Or state the scope: this questionnaire assumes a project with versioned artefacts and a build-like
  environment, and a non-software project uses Groups 2, 4 and 5 only. Also honest, and cheaper.

What does not work is the current position, where the README implies generality and the
questionnaire quietly does not have it.

---

## R2-12 · Step 6 says write the prompts into the project; the README still says they are in `assets/`

**DEFECT**

**What it says.** `SKILL.md:146`: *"**Write both filled-in prompts into the project**, next to the
configuration file — not only into the chat."* Round 1's F7, correctly fixed.

`README.md:246`, unchanged: *"Both are in `assets/`, filled in with your real paths."*

**Why it bites.** Two documents in the same bundle give different instructions for the same step, and
the README's is the one round 1 established is false — `assets/` holds the templates with
placeholders, inside Cowork's cache. A reader who follows the README does not get the fix.

And the fix is under-specified even where it is right: `SKILL.md:146` gives no filename, and there is
no asset for the filled versions. Two installations will name them differently, and
`bootstrap-cowork.md:13-15` — which tells a cold session what to read — has a placeholder for the
config file and **no line at all for the prompts**, so a cold session has no way to find the file it
was itself supposed to be pasted from.

**What I propose.** Fix `README.md:246` to match `SKILL.md:146`. Name the two files in `SKILL.md`
(`gtd-bootstrap-code.md`, `gtd-bootstrap-cowork.md` or whatever, but name them), and add a line for
them to the read-list at the top of both bootstrap prompts.

---

## R2-13 · `protocol.md` contradicts itself about who can be a filename author, 17 lines apart

**DEFECT**

**What it says.** `protocol.md:6`:

```
<channel>/YYYYMMDD-HHMMSS-<author>-<slug>.md        author: code | cowork | owner
```

`protocol.md:23-25`, the round-1 fix: *"**The `<author>` in the filename is whoever typed the file**
— the session that wrote it. It can differ from `from:`, which is the person for a recorded
decision."* If the author is whoever typed it, it is never `owner` — the person types nothing.

`exchange-README.md:9` has the corrected form: `author: whoever typed it — code | cowork`.

**Why it bites.** The fix was applied to the prose and to the copy that ships in the channel, and not
to the format block seventeen lines above it in the same file — which is the part an agent reads when
it wants the format. Round 1 flagged this as F17d; it is now half-fixed in a way that is worse than
before, because the two readings now sit in one file and each looks authoritative.

**What I propose.** `author: code | cowork` at `protocol.md:6`. One word.

---

## R2-14 · The `consensus` constraint is documented in four places and enforced in none

**DECISIÓN SIN TOMAR**

**What it says.** `message-template.md:93`: *"**`re:` must point at a message from the other agent.**
A consensus with `re: -` is one agent asserting a two-party fact, and authorises nothing."* Also
`protocol.md:193`, `exchange-README.md:37-39`, `config-template.md:44-45`, `README.md:131-133`.

**Why it bites.** Round 1's F2 asked for the constraint precisely because it would make the rule
*"checkable instead of aspirational"* — that phrase is now in the repository three times. Nothing
checks it. Planted a violating message in the 40-message channel and ran every shipped query:

```
   planted: state: consensus with re: -
   surfaced by: 0 queries
```

So the constraint is exactly as aspirational as before, with more sentences saying it is not. The
difference round 1 was arguing for was between a rule and a mechanism, and the fix delivered the
rule.

**What I propose.** It is four lines of shell, and it belongs next to the other two queries in
`exchange-README.md`: for each `state: consensus`, read its `re:`, and report it if `re:` is `-` or
if the referenced file's `from:` equals this file's `from:`. That turns `README.md:322`'s degradation
symptom — *"`state: consensus` appears without a fact having been exchanged"* — from something you
have to notice into something you can run. Whether it is worth a fourth query is a judgement; but
the current position claims checkability without providing it.

---

## R2-15 · Still not a repository, and the tree holds the artifact its own `.gitignore` forbids

**LAGUNA**

`git rev-parse` in the tree: `fatal: not a git repository`. So:

- `.gitignore` was added and does nothing.
- `release.yml` still has never run. Everything I report about it in §1 is a **local reproduction**,
  step by step in the YAML's own order — it is evidence, but it is not the pipeline running.
- `.gitignore:6-8` says: *"Build products. The bundle is produced by the release pipeline from
  MANIFEST, not committed — **a committed bundle is one nobody can prove came from the tag**"* — and
  `gtd-with-claude.skill` is sitting in the tree, which is the file this round-2 brief told me to
  install from. It is currently identical to the tree on all 12 manifest paths, so nothing is broken
  today; the point is that nobody can establish that without doing what I just did.

**What I propose.** Initialise the repository and cut a tag, or delete the two files that describe a
world where one exists. Between those, everything about the release story is a claim about
something that has never happened — which is the class of claim this method exists to flag.

---

## R2-16 · The README's Releases section describes an older pipeline

**DEFECT**

`README.md:415-418`:

> *"1. It **proves its own validator first** — **six** deliberate mutations…"* — there are **seven**
> (`validate_skill.py:181-189`).
> *"3. It checks all **thirteen** files were staged, **by name**"* — there are **twelve**, and it is
> not by name any more, it is by MANIFEST.

Round 1 removed `README.md` from the bundle (13 → 12) and added a mutation (6 → 7), and the section
describing both was not updated. It is the one part of the README a reader has no way to check
without opening two other files, and it is where the repository makes its strongest claim about its
own rigour.

**What I propose.** Update the three numbers, or replace them with a sentence that cannot go stale
(*"one mutation per rule, and the count is in `validate_skill.py`"*). The second is better; a figure
that has to be maintained in two places is `verification.md:187-196` in miniature.

---

## R2-17 · Three trigger phrases mention no agent at all

**DECISIÓN SIN TOMAR**

**What it says.** `SKILL.md:3` lists as triggers: *"asks `who decides what here`, `how do I stay
informed without approving everything`, `how much can I delegate`"* and *"wants to install a working
agreement"*.

**Why it bites.** None of those four names Claude Code, Cowork, an agent, or a session. As written
they are ordinary questions about human governance — decision rights on a team, how much to hand to a
report, writing down an approval policy for people. And in the proxy the one false positive came from
this family: *"¿qué permisos le doy a Claude Code para que no me pregunte tanto?"* fired on *"how do
I stay informed without approving everything"* plus *"an approval policy"*.

That query is about the tool's permission settings. It is a reasonable thing to want to answer with
`approvals.md` in hand — *"yes and don't ask again is usually the wrong answer"* is directly relevant
— so I do not think a partial fire is indefensible. But it is a fire, and it was named as a
should-not.

**What I propose.** Scope the three quoted questions rather than adding negative triggers, which age
badly. *"asks who decides what between them and the two agents"*, *"how much can I delegate to Claude
Code and Cowork"*. The description has 134 characters spare (890 of 1024, measured), which is enough.

I would not try to exclude the permissions question. The honest fix there is in the skill's own
behaviour: if it fires on a permissions question, situation A of `SKILL.md:28-39` should recognise
that no setup was asked for and answer the question instead of running a questionnaire. Nothing in
`SKILL.md` covers "triggered, but the person did not ask for the method" — which is a third situation
next to A and B, and it is missing.

---

## R2-18 · Neither prompt file declares the exemption the third one declares

**LAGUNA — small**

`docs-review-findings.md` opens with an explicit exemption block. `docs-review-prompt.md` and
`docs-review-prompt-round2.md` are equally Spanish, equally in the tree, equally absent from
MANIFEST, and say nothing. `verification.md:129-131`: *"**Every structural exemption carries its own
assertion.**"* Applying a rule to one of three instances of the same case is how the rule stops being
a rule.

**What I propose.** Two lines, or one shared note. Or decide that review artefacts as a class are
exempt and say so once, somewhere that covers all three.

---

# 4 · A6 · What the README leaves a cold reader holding

I read `README.md` end to end before anything else. These are the points where I stopped and had to
open another file. Each one is a candidate for the README, not a defect.

| Question the README raises and does not answer | Where the answer actually is |
|---|---|
| **What is a milestone?** Used ten times, load-bearing for "lands in a project file in the same milestone", never defined | nowhere, in fact |
| **How does an escalation get closed?** The README says escalations reach the person; nothing says what ends one | `protocol.md:165` |
| **What are the queries?** The README shows exactly one — `grep -lE '^from: +owner'` at :165, the broken one — and never mentions that the live-state queries are not one-liners | `protocol.md:137-163` |
| **What does the "since yesterday" command look like?** Promised at :36 as one of the five things you get; never shown | `config-template.md:88-100` |
| **What is in `gtd-config.md`?** Named at :242 as the output of setup; not one row shown | `config-template.md` |
| **What is `to: both`?** `settled` gets a clause at :133; `to: both` never appears in the README although it is required on every owner message | `protocol.md:14` |
| **What happens when the channel gets long?** :323 names it as a degradation symptom with no remedy; the archive policy exists elsewhere | `protocol.md:169-180` |
| **What is the daily triage?** The 🟢/🟡/🔴 instrument is the thing the person uses most and the README does not mention it exists | `approvals.md:144-168` |

The last one is the one I would act on. A reader deciding whether to adopt this reads the README and
comes away knowing the questionnaire is a one-time event, without learning that there is a daily
instrument at all.

---

# 5 · What I would not change

- **The `sha:`/`clock:` split.** Round 1 offered three ways out of the `head:` problem and this took
  the honest one — the core says out loud that it has no staleness check. Verified both branches.
  Leave it exactly as it is.
- **`README.md:211-227`, the floor said plainly.** *"It is a commitment, not a lock… Claiming
  otherwise would make the floor the phantom control of its own method."* This is the best paragraph
  in the repository and it makes R2-06 a gap in the mechanism rather than a lie in the text.
- **The queries being long.** `protocol.md:139` — *"These are not one-liners, and the reason
  matters."* Correct, and correct to say so. They are wrong today for other reasons; the shape is
  right.
- **The duplication of the queries in `protocol.md` and `exchange-README.md`.** They have different
  readers — one is the reference, one ships into the channel where Claude Code can reach it. Verified
  identical today. Duplication with different audiences is fine; what it needs is for a fix to R2-01
  to land in both, which is a checklist item, not a design problem.
- **The microservices near-miss.** *"talk to each other"* appears verbatim in the description and the
  proxy still did not fire. Lexical overlap alone is not the risk it looks like; I would not spend
  description budget defending against it.
- **The bundle sitting in the tree.** It is currently identical to the tree, and until there is a
  repository and a release, a downloadable bundle is the only way anyone installs this. What is wrong
  is the `.gitignore` comment asserting it is not there — fix the world or fix the sentence, but the
  file itself is doing useful work today.
- **`MANIFEST` as a hand-maintained list**, despite R2-09. The alternative — deriving what ships from
  a pattern — is how `README.md` got into the bundle in the first place. An explicit list with a
  completeness check is better than an implicit rule; the missing piece is the check, not the list.
- **On B2(d), the 8/6/2 classification.** You asked whether the argument survives without believing
  the numbers. I think it mostly does, and the README already does the work: `:359-362` concedes it
  is one project, reconstructed after the fact, by an interested party, with two ambiguous cases. What
  makes it hold up is not the ratio but the **worked examples in each row** — *a real identifier
  inside a barrier's own exemption* is self-evidently invisible from inside the implementing session,
  and *a hook installed without its execute bit* is self-evidently invisible from outside it. A reader
  who distrusts the counts can still read the two lists and see that they are different kinds of
  thing. I would not defend the number 8. I would defend the claim that the two positions see
  different classes, and that is the claim the section actually needs. The one thing I would add is
  the honest denominator: **this is sixteen defects from one project**, and the section reads as if
  the split were a property of the method rather than of that project.

---

# 6 · The question this method does not ask itself

Round 1's was *why two agents* — `README.md:334-362` now answers it, and answers it well.

Here is the new one, and it comes directly from what this round measured.

> **Which sentences in these documents are executable, and which of those has anyone executed?**

Every defect in section 3 that costs anything is in a **shell command or a table that was written and
never run**: the `from: owner` query in ten places, the open-questions query returning its own README,
the 🔴 row that is not in a table, the config template's worked example, the documented validator
invocation, the self-test's masked mutation. Six of the eighteen findings, and the top five by cost.

The method has an elaborate doctrine for verifying claims about **the project**: declare your scope,
break the verifier before trusting it, confirm the mechanism rather than the document, never assert a
negative about an event. It has no doctrine at all for verifying claims made **by its own
documentation**. Prose is treated as prose.

And `verification.md:161` came within one row of noticing:

> *"**Prose citing an identifier** — A message, comment or document naming a constant, a path or a
> command. **Silent. Nothing reads prose.**"*

That table names prose citing an identifier as a silent frontier. It does not name **prose containing
an executable**, which is the same frontier and strictly worse: a command in a fenced block does not
look like a claim, it looks like a fact, and every reader assumes someone ran it. That is precisely
why `grep -lE '^from: +owner'` survived a full adversarial review, a rewrite, and a release-shaped
bundle without anyone noticing it matches nothing.

The cheapest form of the answer is a fifth entry in that table and a rule to go with it: **a fenced
command block is a claim, and it carries the output it produced when someone ran it.** The same rule
this method already applies to figures — *no figure about behaviour without opening what produces
it* — applied to its own documentation. Under that rule every finding in section 3 that cost anything
would have been caught at the moment it was written, by the person writing it, at a cost of one
paste.

There is a stronger form, and it is the one I would actually build: **extract every fenced `sh` block
in the repository and run it against a fixture channel in the pipeline.** You have the fixture — this
review built one, forty messages with known ground truth. It is the same move as
`validate_skill.py --self-test`, pointed one level out: the validator proves the bundle, and nothing
proves the prose. Round 1 said *point the instrument at itself*. The instrument has been pointed at
the skill, at the bundle and at the validator. It has never been pointed at the documentation, which
is where this project keeps its actual product.

---

*Reproductions live in `/tmp/gtd-qa-20260801/` — `pipeline/`, `channel/` (the 40-message fixture),
`tesis/` (the non-software install), `withrepo/`. Nothing in the skill tree was modified. This file
is the only thing this session wrote to it.*
