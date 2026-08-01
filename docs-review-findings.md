# Adversarial review · findings

> **Exempt from the repository's language rule only in that it is a review artefact, not part
> of the skill — and it declares that here, because a structural exemption that is not declared
> is the class of hole this method exists to find.** It is absent from `MANIFEST`, so it cannot
> ship inside the bundle. If it ever does, that is a finding about the pipeline.

Written for the Cowork session that designed this method, by a Cowork session that arrived cold
at the tree with no prior context and the brief in `docs-review-prompt.md`.

Read this the way the method says to read anything second-hand: **the artefact is the tree, not
this file.** Every finding carries a file, a line and the sentence, so nothing here has to be
taken on trust. Where a finding is about an *event* rather than *state*, the command that
produced it is included, because you cannot verify an event by reading a file — that is this
project's own rule and it applies to its reviewer.

---

## What was examined, and what was not

Declared, because "no problems" and "no problems in N files" are different statements.

| | |
|---|---|
| Examined | All 17 files in the tree: 13 shipping files, `scripts/validate_skill.py`, `.github/workflows/release.yml`, `docs-review-prompt.md`, `gtd-with-claude.skill` |
| Executed | `validate_skill.py .`, `validate_skill.py . --self-test`, a deliberately broken bundle through the validator, a byte diff of `gtd-with-claude.skill` against the tree, `git log`, `date` |
| **Not examined** | The sixteen catalogued defects the method comes from. They are cited in `README.md:311` and exist nowhere in this tree, so every claim resting on them is unverifiable from here |
| **Not examined** | Any running instance. No `gtd-config.md`, no channel directory and no `.runs/` exist anywhere under the tree — **no record here**, which is not the same as "never run" |
| **Could not check** | Whether the release pipeline behaves as written. It has never executed (see F16), so its behaviour is inferred from reading YAML, not measured |

**State this was written against:** `head: 20260801T115200Z`. Not a commit reference — the tree is
not a repository, which is itself F16. Timestamps below are Europe/Madrid.

---

## The three classes, as requested

**DEFECT** — wrong, change it. **GAP** — absent, needed. **UNDECIDED** — ambiguous because nobody
chose; someone has to choose. Ordered by what it costs if nobody fixes it, not by where it appears.

---

## F1 · The floor is a document, and this repository says a document is not a control

**DEFECT — highest cost, because it is the central promise**

**Today.** `README.md:204`: *"If you ask to delegate one of these, the skill will not do it."*
`SKILL.md:89`: *"If someone insists on delegating one of these, do not do it."*

And `verification.md:106-113`, in this same tree:

> *"A control that does not exist is worse than a verifier that reports success without looking...
> The pattern to watch for: a policy file that names reviewers, a status check that looks
> mandatory, a rule everyone repeats. Any of them can be advisory. **Confirm the mechanism, not
> the document.**"*

And `git-annex.md:55`: *"A local pre-commit check is often **the only control that actually blocks
anything**."*

**Why it bites.** The floor is four rows of a markdown table read by the agent it restricts. No
step of the setup writes a deny rule into any tool's permission configuration. Step 5 writes
`gtd-config.md`; nothing writes to `.claude/settings.json` or its equivalent. Apply §5 to the
floor and the verdict is unambiguous: **the mechanism does not exist, only the document does.**
The guarantee the method presents as the one that makes the other two safe is precisely the
pattern `verification.md` §5 teaches the reader to distrust.

Second half, mechanical and checkable: **the daily triage does not cover the floor.**
`approvals.md:154`, the 🔴 row, reads *"Anything that discards uncommitted work, force-publishing,
deleting, touching real data, rewriting history, or adding everything at once"*. **Spending money**
and **anything that reaches a third party** are missing — two of the four classes. The floor is
shown once during setup, and the only instrument used every day omits half of it.
`roles.md:61` lists all four correctly, which is evidence this is an omission in `approvals.md`
rather than a decision.

Third: `verification.md:40` says *"A verifier is not trusted until it has been seen to fail."*
The floor has never refused anything and **there is no procedure anywhere in this tree to test
it**. `validate_skill.py` has `--self-test`. The floor has no equivalent.

**Proposed change.**

1. Separate what the floor is from what it is not, in the README. What it **is**: an explicit
   commitment that makes a violation detectable afterwards and arguable by name — that is worth
   something and should be claimed. What it **is not**: a block. Replace *"the skill will not do
   it"* with wording that does not assert mechanism.
2. Add a setup step that writes the corresponding deny rules into Claude Code's permission
   configuration and **verifies they exist and refuse**. Spending and third-party reach almost
   always pass through deniable commands or tools, so this is achievable for at least two of the
   four classes.
3. Record the outcome per class in `gtd-config.md`: `mechanism: deny rule, verified` or
   `mechanism: none — agreement only`. A floor that says which of its four rows has teeth is
   honest; one that says all four do is not.
4. Add the two missing classes to the 🔴 row of `approvals.md:154`.

---

## F2 · `consensus` is declared unilaterally, and it is the level that authorises acting without the person

**DEFECT**

**Today.** `approvals.md:18`: *"CONSENSUS is not a weak DECIDE. It means the two agents have to
exchange and agree — **a single agent acting alone is not consensus**"*. `protocol.md:228`: *"Mark
`consensus` only when it is one."*

**Why it bites.** The format cannot represent a two-party agreement. A message is one immutable
file written by **one** agent, and that agent types `state: consensus` into its own front matter.
There is no counter-signature, no acknowledgement, nothing the second agent must write for the
agreement to exist. `state: consensus` is structurally a unilateral assertion of a bilateral fact
— which is the literal definition of what `approvals.md:18` forbids.

Concrete: the person sets version control to CONSENSUS. Claude Code writes a message marked
`state: consensus` saying "agreed, taking the checkpoint", and acts. Cowork never read it. The
person never finds out, because the record says consensus and the record is what gets audited.
`README.md:297` already lists this as a degradation symptom — but treats it as a discipline
problem when it is a format problem: **the format offers no way to do it correctly.**

**Proposed change.** Make it mechanical and greppable: `state: consensus` is only valid on a
message whose `re:` points at a message **from the other agent**. A consensus with `re: -` is
one-sided and authorises nothing. Stricter variant if preferred: the consensus message is always
written by the agent that did *not* make the proposal. Either way it is one sentence in
`protocol.md` and one row in `message-template.md:73`, and it makes the rule checkable instead
of aspirational.

---

## F3 · The record of what the person said is a paraphrase with maximum authority and no read-back

**DEFECT — this is the answer to "what happens when someone records it wrong"**

**Today.** `protocol.md:108-109`: *"anything the person is asked, and what they answered, is
written to the channel by whichever agent heard it"*. `bootstrap-code.md:56`: *"ASKED: what you
asked, **in their words as far as you have them**"*. And the standing it is given —
`protocol.md:130-132`, `bootstrap-cowork.md:44-46`: *"Those are decisions, not opinions. If one of
them rules out what you were about to propose, **it is settled and you do not reopen it**."*

And `roles.md:31-35`, in this same tree:

> *"**A verdict on a paraphrase is worth nothing.** Asked to judge something, ask for the artefact
> — the actual output, the actual block, the actual file — not a summary of it. A summary is
> somebody's reading, and a verdict on somebody's reading is a verdict on the wrong object."*

**Why it bites.** The method forbids acting on paraphrase everywhere **except one place**: the
person's own decisions, where paraphrase is the only representation that exists, is written by an
agent without supervision, is immutable, and receives the highest standing in the system. No file
in this tree says the agent must show the person the message it just wrote in their name.

This is also where the English rule collides with the informing promise — and the collision is
narrower than it looks. Agent-to-agent traffic in English is well argued (`protocol.md:89-91`) and
should stay. But `README.md:158-162` sells this to the person as their audit tool:

> *"Filing them under your name is what makes every decision you have made findable in one line:
> `grep -lE '^from: +owner'`"*

If they chose Spanish in Step 1, the only record of their own decisions — written by an agent,
unconfirmed, immutable, and binding on both agents — is in a language they do not read.
`protocol.md:89` justifies the rule with *"They are not for the person"*, which was true when the
channel carried only agent-to-agent traffic. When `from: owner` was added, that premise stopped
being true and the rule was not revisited. **Verified: `grep -rn -i language` across all seven
shipping documents returns no exception anywhere.**

**Proposed change.** Two separable things.

1. `from: owner` messages carry the `ASKED:`/`ANSWERED:` block **in the language the conversation
   happened in**; everything else in the message stays English. Minimal exception, does not break
   the grep or the synchronisation convention. If that is unacceptable, duplicate:
   `ANSWERED (es):` / `ANSWERED (en):`.
2. The agent **shows the person the message in the turn it writes it**, in their language, in one
   line. A "no" produces a new message correcting the old one. Without this, the rule reads: an
   agent writes down what you decided, in a language you do not read, and both agents then treat
   it as not reopenable.

---

## F4 · Claude Code cannot reach the command that generates a message. It will type the filename by hand on day one

**DEFECT — the one that breaks the first time anybody uses this for real**

**Today.** Setup copies exactly **one** file into the project — `SKILL.md:101`: *"Create the
directory and copy `assets/exchange-README.md` into it as `README.md`."*

`bootstrap-code.md:32` tells Claude Code: *"Read `<channel>/README.md` for the format and **use
the command in the template** to create the file"*.

`exchange-README.md:26-29` — the only file Claude Code receives — says: *"The timestamp comes from
the clock and `head:` from the project — never from memory... **Use the command in the
template.**"*

**The command is not there.** `assets/message-template.md` lives in Cowork's read-only skills
cache. It is never copied into the project. Claude Code has no path to it.

**Why it bites.** The failure is not an error message. Claude Code writes the filename and the
`head:` field from its own context — committing exactly the defect `protocol.md:64-85` is most
emphatic about (*"A value asserted instead of measured, in the one place nobody inspects"*) —
because the method asked it to use a tool it never handed over. `verification.md:161` already
classifies the reference itself: *"Prose citing an identifier... **Silent. Nothing reads prose.**"*
And the consequence is the one `protocol.md:70-73` calls the single assumption the whole design
leans on: a fabricated timestamp is indistinguishable from a read one until a message sorts in
front of its own reply.

**Proposed change.** `SKILL.md:101` copies **two** files into the channel:
`exchange-README.md` and `message-template.md`. `exchange-README.md:29` cites the real relative
path instead of "the template". Two lines.

Related, smaller, same failure mode: even with the command in hand,
`message-template.md:23-33` creates the file with front matter and then says *"Then write the body
into that file"* without saying how. An agent holding a `Write` tool will rewrite the whole file
including the generated header, and the fabricated-value problem returns. An explicit
`cat >> "$MSG"` closes it.

---

## F5 · Without a repository, `head:` is the clock again, not project state

**DEFECT**

**Today.** `protocol.md:59-61`: *"every message records what it was written against — a commit
reference, a timestamp, a version, whatever identifies the state in that project. **If `head:` no
longer matches when the answer arrives, the answer is stale and the question gets asked again.**"*

The implementation, `message-template.md:20`:

```sh
HEAD=$(git rev-parse --short HEAD 2>/dev/null || date -u +%Y%m%dT%H%M%SZ)
```

**Why it bites.** Without a repository, `head:` is **the UTC time the message was written**. It is
not a property of the project — it is a second copy of the timestamp already in the filename. The
staleness check then fails under both readings, and both are bad:

- Literal reading of `protocol.md:61` ("if `head:` no longer matches"): it **never** matches,
  because two clocks read at different moments always differ. Every message is stale. The rule at
  `message-template.md:80` then says *"say so and ask it again rather than answering"* → an
  unbounded loop of re-asking and no answers.
- Charitable reading ("has the project moved?"): the comparison cannot be made, because the value
  says nothing about the project. A `head:` from three hours ago is equally consistent with an
  untouched project and with one rebuilt from scratch.

`config-template.md:26` asks the installer to record *"`head:` identifies state as `<commit
reference / timestamp / version>`"* while nothing anywhere explains how to compute the `version`
option — so in practice every repository-less project falls to the clock.

Stated plainly, since this is the question the brief asked: **the agnostic core is promising a
guarantee that only exists with a repository.** This is not graceful degradation; the field
silently changes meaning and the rule that depends on it does not.

**Proposed change — someone has to choose, and I do not think there is an obviously right answer.**

- **(a)** Say it. In the core, `head:` is informative and **there is no staleness check**; the git
  annex adds one. Honest, free, removes a promise the core does not keep.
- **(b)** Give a fallback that is actually state — an aggregate hash or newest-mtime over the
  files the project cares about. Ugly, but it is a property of the project and it compares.
- **(c)** Replace the equality comparison with an explicit "has the project changed since `head:`"
  test — which requires (b) to be answerable at all.

What does not work is the current position, which is (a) written in the vocabulary of (b).

---

## F6 · `grep -E '^state: +open$'` does not return unanswered questions. It returns every question ever asked

**DEFECT — and it is what happens at 400 files**

**Today.** `exchange-README.md:57`:

```
grep -lE '^state: +open$' *.md          # questions nobody has answered
```

Same command and same claim in `protocol.md:216-219` and `bootstrap-cowork.md:35`.

The design is correct — `protocol.md:46-48`: *"An open question is a message with `state: open`
that no later message answers... which means **the state of the conversation is derived, not
stored**."*

**Why it bites.** The command does not implement the design. Because files are immutable, an
answered message **still says `state: open` forever**. That grep returns every question ever
asked. Getting what the comment promises requires cross-referencing the `re:` field of every later
message — exactly the work the comment implies is unnecessary.

Worse for the escalation grep (`exchange-README.md:58`, *"what the person needs to look at"*): it
is the only alarm the person has, and it returns every escalation in the project's history,
resolved and unresolved alike. **No convention anywhere defines how an escalation is closed** —
immutability prevents editing, and no `re:`-based closing rule is stated.

**Month three, 400 files:** the grep returns sixty paths and the person cannot tell which are
live. `README.md:298` diagnoses the symptom (*"The channel fills up and nobody reads the older
half"*) and attributes it to messages being written for the record rather than the reader. The
cause is mechanical, not cultural: **the query does not work.** There is also no archival or
per-milestone cut policy anywhere, even though `git-annex.md:22` establishes the channel as
transient by design and `verification.md:148-150` already reasons about preservation rules meeting
transient objects.

**Proposed change.**

1. Replace both commands with ones that do the cross-reference — collect every `re:` value, subtract
   from the files carrying `state: open`. It is three lines, not one. If three lines will not fit
   in `exchange-README.md`, the honest move is to delete the comment, because today it is false.
2. Define closure: a message whose `re:` points at an escalation, written `from: owner`, closes it.
   That makes "what needs me" computable and is consistent with everything else.
3. Decide what happens at 400 files. Today the answer is "nothing".

---

## F7 · The two filled-in bootstrap prompts are not persisted anywhere. At month three they do not exist

**GAP**

**Today.** `SKILL.md:112-113`: *"Give the person `assets/bootstrap-code.md` and
`assets/bootstrap-cowork.md`, **filled in with the real paths**, to paste into each session."*
`README.md:225`: *"Both are in `assets/`, filled in with your real paths."*

**Why it bites.** That last sentence is false. What is in `assets/` are the templates with
`<placeholders>`, inside Cowork's skills cache. The filled-in versions exist only in a chat
message. No setup step writes them into the project.

And the method already ruled on this, one step earlier — `SKILL.md:107`:

> *"**The configuration is a project file, not a chat decision** — a decision that lives only in a
> conversation is not a decision, because conversations end."*

Applied in Step 5, forgotten in Step 6, on the two artefacts the person needs **every time they
open a session**, not once. Month three: the person opens Claude Code without the prompt. The
agent does not read the channel, does not grep `from: owner`, does not write conversations back.
The method is still installed and has silently stopped existing — and nothing detects it, because
there is no check for "did this session start with the prompt?".

Third piece, unused: `bootstrap-code.md:15` refers to *"the project's own instructions file, if
there is one"*. The method knows Claude Code has a persistent instructions file and writes nothing
into it, preferring a paste-prompt that `roles.md:91` itself describes as *"prose citing
identifiers, and it decays"*. The method knows the defect in its own startup mechanism and uses
that mechanism anyway.

**Proposed change.** Step 6 writes both filled-in prompts into the project next to
`gtd-config.md`, and offers to add a three-line pointer to the project's instructions file where
one exists. `README.md:225` cites the real path instead of `assets/`.

---

## F8 · "What has happened since yesterday" has no implementation, and its acceptance test is a pass over empty input

**GAP + a failed self-application**

**Today.** `README.md:36` sells it as one of five things you get: *"One command tells you what
happened since yesterday."* `approvals.md:184-186` makes it a requirement: *"Write that command
into the configuration file, specific to their project... and **run it once before claiming it
works**. A reporting promise that has never been executed is the same class of defect as a check
that has never been seen to fail."* `config-template.md:78` leaves
`<the actual command for this project>`.

**Why it bites.** Two things.

There is not one example anywhere — not in `assets/`, not in `reference/`, not in the README. Every
installation invents it, which guarantees drift between projects and guarantees that in some of
them it does not work. It is the only mechanism the person touches daily and the only one with no
template.

And the acceptance test the text mandates — *"run it once before claiming it works"* — executes
during Step 5, when **the channel is empty and the project has done nothing**. It returns zero
lines and the agent marks it working. That is verbatim `verification.md:31-33`:

> *"a tool run from the wrong directory, **a search over an empty input**, a check looking for a
> kind of thing the project does not contain. All of them print success and return zero."*

The method instructs its own setup to perform the blind check its verification file defines as the
central failure — and does not notice.

**Proposed change.** Ship two or three example commands in `config-template.md` (channel + logs;
channel + git log). And change the acceptance criterion from *"run it once"* to *"write a probe
message into the channel and confirm the command returns it"* — the version that cannot pass over
an empty input. Then the rule satisfies itself.

---

## F9 · Who executes is contradicted across files, and it breaks the state/events frontier

**DEFECT**

**Today.** `README.md:33`: *"You still run the commands. **Nothing here executes anything on your
behalf**."* `README.md:276`: *"It does not run anything for you. You still execute the commands."*
`README.md:45`: Claude Code *"Writes the command blocks you execute"*.

Against `roles.md:5`: Claude Code *"Implements. **Runs the tests.** Writes the command blocks the
person executes"*.

**Why it bites.** These cannot both hold, and the difference is where evidence comes from.
`verification.md:204` reads *"**Any block of commands handed to a person to run** writes its output
to a file. Without exception, even a single line."* The logging rule is **conditioned on the block
being handed to a person**. Anything Claude Code runs itself is covered by no logging rule at all —
and Claude Code does run things itself, because it holds a shell.

Consequence: Cowork verifies state, not events. If Code runs the tests itself and writes no log,
Cowork can know nothing about them and will correctly report *"no record here"*. The frontier that
makes review possible closes over the work being reviewed. This is not an edge case; it is the
normal case.

It also removes a layer from the floor. If the person types, the floor is enforced by a human with
a finger on the key. If Code executes, the floor is enforced by the restricted agent itself — which
is F1 with no mitigation left.

**Proposed change.** Choose, and write it down. The version I believe is true: *Claude Code
executes what its permissions allow and **everything it executes leaves a log**; the person
executes what the permissions block.* Then `verification.md:204` stops being conditioned on "handed
to a person" and becomes "any block, whoever runs it", and `README.md:33` and `:276` get rewritten,
because today they promise the person a control they do not have.

---

## F10 · The pipeline step the README is proudest of accepts a bundle containing one file

**DEFECT — measured, not inferred**

**Today.** `README.md:363-365`, presenting step 4 as the closing argument:

> *"It builds the zip, **extracts it somewhere clean, and validates that** — the artifact is what
> gets installed, and it is a different object from the tree it was built from."*

`release.yml:86-92` does exactly that: `python scripts/validate_skill.py verify/gtd-with-claude`.

**Why it bites.** The validator only checks `SKILL.md` frontmatter. The thirteen-file completeness
check (`release.yml:57-72`) runs against `build/`, **not against the extracted artifact**. So the
step whose written justification is *"the tree and the zip are different objects"* applies to the
zip a strictly weaker check than it applies to the tree — in precisely the dimension (are all the
files present?) for which the tree/zip distinction matters.

Measured. A bundle containing **only** `SKILL.md`, with no `reference/` and no `assets/`:

```sh
mkdir -p sim/gtd-with-claude && cp SKILL.md sim/gtd-with-claude/
cd sim && zip -qr ../broken.skill gtd-with-claude && cd ..
mkdir v && unzip -q broken.skill -d v
python3 scripts/validate_skill.py v/gtd-with-claude
```

```
EXAMINED: 12 rules over 1 files (1 shipping SKILL.md)
VALID    (exit 0)
```

The pipeline would publish, under a green `VALID`, a skill that installs and can do nothing — the
exact failure `validate_skill.py:5-7` names as its reason to exist. Note also that the report
**declares its scope ("over 1 files") and the declaration does not affect the verdict**: the
`blind` state of `verification.md:25-33` only fires at zero files (`validate_skill.py:63`). The
declared scope is printed and never judged.

For the record, the rest holds: `--self-test` passes all six mutations plus the positive polarity,
and `gtd-with-claude.skill` is byte-identical to the tree across all thirteen files.

**Proposed change.** Move the thirteen-name loop after the `unzip`, or fold it into the validator
as a rule (`--expect-manifest`). Two lines of YAML. And make a non-empty-but-implausible scope a
`blind` outcome rather than a pass.

---

## F11 · `state:` has no value for "the person decided", and both worked examples in the tree are mislabelled

**UNDECIDED**

**Today.** `message-template.md:73` defines `consensus` with a hard condition: *"The other agent's
position and yours meet, **and a fact was exchanged**. Two agents who have not exchanged a fact
have not agreed."*

The tree then uses it twice in ways incompatible with that definition:

- `protocol.md:135-150`, the canonical `from: owner` example: `state: consensus`. No two agents, no
  fact exchanged. A person's decision labelled with the value meaning "the two agents agreed".
- `README.md:94-116`, the flagship example: `state: consensus`, while the body says *"Three
  options, and **I do not think we should pick one between us**... Writing this to the plan file as
  **an open decision for the owner**"*. By `roles.md:58` that is the definition of `escalated`
  (*"It is a judgement call, not a measurement"*).

**Why it bites.** The overlap has already produced two divergent readings inside this tree, written
by the same author. And there is an operational consequence: `README.md:297` lists *"`state:
consensus` appears without a fact having been exchanged"* as a degradation symptom. The canonical
example **is an instance of the method's own decay symptom**. An agent learning the format by
imitation — which is how formats are learned — will mark as consensus what should be escalated, and
`grep -E '^state: +escalated$'`, the person's only alarm, will under-return. The failure is silent and
runs in the dangerous direction: fewer interruptions than the person asked for.

**Proposed change.** A fourth value, `settled`, for the person's decisions: no two agents required,
no fact required, means "not reopened". `consensus` recovers a single definition and
`README.md:297` becomes a symptom again rather than a description of the example. One row in four
files. **And both examples must be relabelled** — while they stand, the definition does not matter.

**Same decision, second half:** `protocol.md:13-14` restricts `to:` to `code | cowork | owner`. A
`from: owner` message must be read by **both** agents (`protocol.md:109`: *"read by the other before
it proposes anything"* — but the "other" of an owner message is both). The vocabulary has no value
for that; the example writes `to: cowork` (`protocol.md:137`), which formally excuses the agent
that wrote it from ever re-reading it. `to: both` is needed.

---

## F12 · The questionnaire runs before the channel exists

**DEFECT — sequencing**

`SKILL.md`: Step 2 is the questionnaire, Step 4 creates the channel. The founding decisions — the
language, the seven delegation levels, where the channel lives, which model does what — are taken
when there is nowhere to write them. No step says "now write the questionnaire answers into the
channel as `from: owner` messages".

Consequence: `README.md:158-162` promises `grep -lE '^from: +owner'` returns *"every decision you have
made"*, and on day one it returns **zero** — missing the most important ones.
`bootstrap-code.md:38-45` tells Claude Code to treat that grep as the list of what is settled. The
config file partially covers this, but that creates two sources of truth for the same thing with no
precedence rule — which is exactly what F14 needs and does not have.

**Proposed change.** Step 5b: the setup writes one `from: owner` message carrying the questionnaire
answers. Its `head:` is the project's baseline.

---

## F13 · "Yes, if the block carries its own check" is defined nowhere

**GAP**

`approvals.md:153`, the 🟡 row: *"**Yes, if the block carries its own check**"*. And
`approvals.md:174`, among the ways to say no: *"No. That block does not carry its own check."*

It is the criterion for the middle row of the only daily instrument, and no file in this tree
defines it. Does it mean the block writes its log? That it prints its return code? That it verifies
its own effect after acting? All three are reasonable readings and they produce different decisions
— and the amber row carries the volume. The person applying this at nine in the morning has no way
to know which one is meant.

**Proposed change.** One sentence in `approvals.md`. My reading of `verification.md:199-220` is
that it means *the block checks and shows its own effect after applying it, not merely that the
command exited zero* — but that is a reading, and this is exactly the kind of thing that has to be
chosen rather than inferred.

---

## F14 · No precedence rule when the person contradicts an earlier decision

**UNDECIDED**

Messages are immutable. If the person decided X last week and not-X today, there are two
`from: owner` files and the grep returns both. Nothing says the later one wins. `re:` is defined as
*"filename this message answers"* (`protocol.md:15`) — whether a revoking decision "answers" the
revoked one is undefined, and nothing requires them to be linked.

The agent cannot resolve it without violating another rule: `bootstrap-cowork.md:44-46` says *"it is
settled and you do not reopen it"* about the older decision. One disciplined agent will honour last
week's; another will honour `ls` order. Both readings are defensible and nobody notices until they
collide.

**Proposed change.** Two lines: the most recent `from: owner` message on a subject governs, **and it
must carry `re:` pointing at the one it revokes**. Without the `re:`, the revocation is invisible to
anyone reading by grep rather than by date.

---

## F15 · No timezone is fixed, and the two sessions do not share a clock by construction

**UNDECIDED**

`message-template.md:21` uses `date +%Y%m%d-%H%M%S` — **local time**. The line immediately above
(`:20`) uses `date -u` for the `head:` fallback. Two timezones in one six-line template, uncommented.

`protocol.md:70-73` is categorical about why this matters: *"A message stamped five minutes ahead of
the real time sorts in front of the answer that replies to it. The directory stops being ordered,
and `ls -1` stops being the index — **which is the single assumption the whole design leans on**."*

The risk is specific to this method's topology: the two participating sessions run in different
environments with no guarantee of a shared timezone — Cowork in a Linux sandbox, Claude Code on the
person's machine. **In this review's environment they happened to match** (both `Europe/Madrid`,
checked with `date` and `date -u`), so I cannot claim it always breaks. But a container on UTC puts
Cowork's messages two hours behind Code's, and the directory ordering inverts silently between the
only two participants the method has.

**Proposed change.** UTC on both lines. A channel whose only property is ordering should not depend
on the locale settings of two different machines. If local time is preferred for readability, then
say so, detect the timezone during setup, and record it in `gtd-config.md`.

---

## F16 · The repository does not meet its own requirements in three small places

Grouped because each is cheap, but together they are the answer to "does the method comply with
itself".

- **This is not a git repository.** `git log` in the tree returns *"fatal: not a git repository"*.
  Direct consequence: `release.yml`, which triggers on `push: tags: v*`, **has never run**, and
  `gtd-with-claude.skill` was built by hand — against the argument in its own file,
  `release.yml:3-5`: *"Building it on a tag **rather than by hand** means the published bundle is
  always the tagged tree."* The bundle is clean today (diffed: identical across all thirteen files);
  the problem is that the stated guarantee is not what produced it. And applying the annex to its
  own home: in this project `head:` would be a timestamp — F5, indoors.
- **`docs-review-prompt.md` is in Spanish**, in a repository whose closed decision is that
  everything is in English. It does not ship, so the exception is defensible — but it is declared
  nowhere, and `verification.md:129-131` says exactly what to do about that: *"**Every structural
  exemption carries its own assertion.** If a file is skipped by a check, there is a test that looks
  at it with the exemption lifted."* One line inside the file closes it. **This file has the same
  status** and should carry the same assertion.
- **The README ships inside the bundle and describes a tree that does not ship.** `release.yml:52`
  copies `README.md` into the bundle; `README.md:333-351` lists `scripts/` and `.github/workflows/`,
  which `release.yml:46-47` deliberately excludes. And `README.md:213` links `../../releases/latest`,
  a GitHub-relative path that goes nowhere inside an installed skill. That is the *"link checker with
  a dead link inside its own comment"* of `verification.md:122`, in the file that says it.

---

## F17 · Minor, not developed

- **`approvals.md:40`: "Twelve activities, grouped into five questions"**, then `:71`: *"Four
  activities are not in the groups"*. It only reconciles if version control counts as **one**
  activity, while the text describes it as four things (*"committing, publishing, branches,
  merges"*). An asserted figure, in the companion file to `verification.md:64` (*"Declare the object
  in the same sentence as the figure"*).
- **`config-template.md:32-38` has seven rows** for the eight activities the questionnaire offers:
  Group 3 is three items (dependencies, configuration, permission files) and the template collapses
  them into two. One questionnaire answer has nowhere to be recorded.
- **`roles.md:6`** says Cowork never *"Edits files while another milestone is open"* — but "milestone
  open" only has a mechanism where the project keeps a scope file, which is conditional and lives in
  the git annex (`git-annex.md:40`, *"Some projects keep a file..."*). In the agnostic core the
  prohibition is not checkable by anyone.
- **The filename segment for a `from: owner` message.** `protocol.md:6` says the segment is the
  `author: code | cowork | owner`; `protocol.md:154` says `from:` is `owner` "whoever typed the
  file". It does not say which goes in the filename. The two agents will choose differently and
  `ls -1` stops being readable by author.

---

## Backlog

Discrete changes, each independently shippable. Suggested order is F4 → F1 → F2/F3 → the rest, on
the grounds that F4 breaks on first use, F1 is the promise, and F2/F3 are the two places where the
record can be wrong without anyone noticing.

| # | File(s) | Line | Class | Change |
|---|---|---|---|---|
| F1a | `SKILL.md`, `README.md` | 89, 204 | DEFECT | Stop asserting mechanism for the floor; state what it does and does not block |
| F1b | `approvals.md` | 154 | DEFECT | Add spending and third-party reach to the 🔴 row |
| F1c | `SKILL.md`, `config-template.md` | new step, 44-57 | GAP | Write deny rules where a mechanism exists; record per class whether it was verified |
| F2 | `protocol.md`, `message-template.md` | 228, 73 | DEFECT | `consensus` requires `re:` pointing at the other agent's message |
| F3a | `protocol.md`, `exchange-README.md` | 89, 35 | DEFECT | `ASKED:`/`ANSWERED:` in the language it happened in; rest stays English |
| F3b | `protocol.md`, both bootstraps | 152-165 | GAP | Show the person the `from: owner` message in the turn it is written |
| F4a | `SKILL.md` | 101 | DEFECT | Copy `message-template.md` into the channel too |
| F4b | `exchange-README.md` | 29 | DEFECT | Cite the real relative path, not "the template" |
| F4c | `message-template.md` | 33-39 | GAP | Say how the body is appended (`>>`), not just that it is written |
| F5 | `protocol.md`, `message-template.md`, `config-template.md` | 59-61, 20, 26 | UNDECIDED | Choose (a) no staleness check in the core, (b) a real non-git fallback, or (c) a changed-since test |
| F6a | `exchange-README.md`, `protocol.md`, `bootstrap-cowork.md` | 57-58, 216-225, 35-36 | DEFECT | Replace the two greps with ones that cross-reference `re:`, or delete the false comments |
| F6b | `protocol.md` | 216-229 | GAP | Define how an escalation is closed |
| F6c | — | — | UNDECIDED | Decide the channel's growth policy at 400 files |
| F7 | `SKILL.md`, `README.md` | 112-113, 225 | GAP | Write both filled-in prompts into the project; fix the false "in `assets/`" |
| F8a | `config-template.md` | 75-82 | GAP | Ship two or three example "since yesterday" commands |
| F8b | `approvals.md` | 184-186 | DEFECT | Acceptance test becomes "probe message returns", not "run it once" |
| F9 | `README.md`, `roles.md`, `verification.md` | 33/276, 5, 204 | DEFECT | Settle who executes; make the logging rule unconditional on who runs the block |
| F10a | `release.yml` | 86-92 | DEFECT | Run the thirteen-name check against the extracted bundle |
| F10b | `validate_skill.py` | 61-64 | DEFECT | An implausibly small scope is `blind`, not a pass |
| F11a | `protocol.md`, `message-template.md`, `exchange-README.md`, `roles.md` | 16, 68-74, 18, 58 | UNDECIDED | Add `settled` for the person's decisions |
| F11b | `README.md`, `protocol.md` | 99, 139 | DEFECT | Relabel both worked examples |
| F11c | `protocol.md`, `exchange-README.md` | 13-14, 14 | GAP | Add `to: both` |
| F12 | `SKILL.md` | Step 5 | DEFECT | Write the questionnaire answers into the channel as `from: owner` |
| F13 | `approvals.md` | 153 | GAP | Define "carries its own check" |
| F14 | `protocol.md` | 130-132 | UNDECIDED | Later `from: owner` governs, and must carry `re:` to what it revokes |
| F15 | `message-template.md` | 20-21 | UNDECIDED | One timezone. UTC recommended |
| F16a | — | — | GAP | Put the tree under version control before the first release |
| F16b | `docs-review-prompt.md`, this file | 1 | GAP | Declare the English-only exemption inside each exempt file |
| F16c | `README.md` | 213, 333-351 | DEFECT | The shipped README must not describe files the bundle excludes |
| F17a | `approvals.md` | 40 | DEFECT | Reconcile "twelve activities" with what is enumerated |
| F17b | `config-template.md` | 32-38 | DEFECT | One row per activity the questionnaire asks about |
| F17c | `roles.md` | 6 | UNDECIDED | Either give "milestone open" a core mechanism or move the rule to the annex |
| F17d | `protocol.md` | 6, 154 | UNDECIDED | Which name goes in the filename of a `from: owner` message |

---

## What I would not change

A reviewer who finds thirty problems and calls all thirty serious has not prioritised.

- **"No file wakes anybody up"** (`README.md:265`, `protocol.md:198`, `exchange-README.md:72`).
  Declared three times, in the right places, with the reason. A real limitation, well communicated.
  Leave it.
- **The channel not surviving a fresh clone** (`git-annex.md:22`). The argument — that if it
  survived it would start being treated as the record — is good and defends itself.
- **English for agent-to-agent traffic.** F3 asks for an exception covering `from: owner`, not the
  revocation of the rule. `protocol.md:89-91` is correct about what the channel was; it simply did
  not get revisited when a subset stopped being agent-to-agent.
- **Filename collision when two agents write in the same second.** The author is in the filename, so
  it needs same author + same second + same slug. Not a problem, and not worth a mechanism. **The
  real concurrency problem is logical, not filesystem-level** — it is F2.
- **Immutability**, even though it causes F6. The fix belongs in the query, not the storage;
  allowing edits would close the grep and open the failure `protocol.md:27-34` describes, which is
  far worse.
- **The redundancy between README, SKILL.md and `reference/`.** It is functional: each file has a
  different reader and none can assume another was read. The three places where the redundancy
  *diverges* are F9 and F11; those need fixing. The rest is correct as it stands.
- **On "none of this has ever been executed":** this does not invalidate everything equally. The
  verification culture does not need to have run — it is a set of claims about how things fail,
  drawn from sixteen real defects, and it stands on reading. What does depend on an execution nobody
  has seen is **everything written in the language of mechanism**: *"the skill will not do it"*,
  *"one command tells you"*, *"it writes `gtd-config.md`"*, *"the pipeline will not publish a bundle
  it has not checked"*. Those four are the ones to either downgrade to the language of intent or
  turn into real mechanism. Most of the list above is that separation done case by case.

---

## The question this method does not ask itself

**Why does this need two agents?**

The documents ask, with great care, *how* two agents should talk, *who* decides what among the
three, and *what* makes their agreement worth anything. They never ask what the second agent
catches that the first would not, given the same verification culture.

The data to answer it exists. `README.md:311-313`: *"sixteen catalogued defects, roughly a third of
which were introduced by the same agents that were reviewing the others."* That demonstrates the
**verification discipline** works. It does not demonstrate that a **second session** was necessary.
Of those sixteen, the unasked question is: how many were caught because Cowork was looking at the
project and the plan while Code was looking at the code — a position one session cannot occupy — and
how many would have been caught anyway by a review pass inside the same session, or by a fresh cold
session over the same work?

It matters because the entire ceremony — the channel, `head:`, immutability, the `state:`
vocabulary, both bootstrap prompts, all of F2 — is the price of having two sessions. If the answer
is "fourteen of sixteen came from the discipline, not the second session", then the method is paying
for a channel to obtain something it already had, and the real product is
`reference/verification.md` with a review prompt on top. If the answer is "eight of sixteen were
only visible from outside", then the channel is justified and **that should be the first section of
the README** — because today it is written nowhere. `approvals.md:90-94` comes closest (*"each
catches what the other is not positioned to see"*) but asserts it in the abstract, without a single
case.

This is the one finding in this review that cannot be answered by reading the tree. The sixteen
defects are catalogued somewhere. Classifying them by *who was positioned to see it* is probably
half a day, and it decides whether this is a method or a wrapper.

*(A shorter second one, if useful: the documents describe in detail how the method degrades
(`README.md:288-305`) but never say **who** reviews that table, **how often**, or **what evidence
would make the person abandon it**. A method that enumerates its own decay symptoms and assigns
nobody to look for them has written a check with no executor — a variant of the defect the whole
repository is named after.)*

---

*This file is in English by the repository's convention, and — per `verification.md:129-131` — it
declares its own status: it is a review artefact, not part of the skill, and it must not be staged
by `release.yml`. If it ever ships in the bundle, that is a finding about the pipeline, not about
this file.*
