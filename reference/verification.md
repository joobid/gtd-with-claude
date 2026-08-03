# Why agreement between two agents is worth anything

Delegating to CONSENSUS rests on a claim: that two agents agreeing is better evidence than one
agent asserting. That claim is only true if both are measuring, and measuring is a discipline
rather than an intention.

Everything here comes from the same sentence:

> **A check whose failure mode is to report success is worse than no check at all.**

Worse, not equal. A missing check is a known gap. A check that reports success without having
looked gets cited in discussions, decisions get built on it, and nobody interrogates it — because
it is *the check*.

---

## 1 · Every verifier declares what it examined

"No problems" and "no problems in 140 files" are different statements, and the first is
indistinguishable from not having looked.

So a check prints its scope alongside its verdict, and **refuses to approve when the scope is
empty**. Three outcomes, not two:

| | |
|---|---|
| **clean** | Examined at least what it claims to cover, found nothing |
| **finding** | Examined properly, found something real |
| **blind** | Examined less than it claims. **This is not an approval** |

The blind state is the one that usually does not exist, and it is where the failures live: a tool
run from the wrong directory, a search over an empty input, a check looking for a kind of thing
the project does not contain. All of them print success and return zero.

**And a declared scope ages.** A floor written when the project had 165 files still says 165 when
it has 194, and the check can quietly stop looking at 29 of them while reporting exactly what it
reported before. Whatever maintains the declaration has to run, or the declaration is a claim
with an expiry date and no date on it.

## 2 · A verifier is not trusted until it has been seen to fail

Break it on purpose against a case it must catch, and check that it screams. Then restore it.

Two cautions, both learned the expensive way:

- **Check the return code, not the output.** A verifier that fails to start prints nothing and
  returns a code nobody read; empty output is indistinguishable from success to anyone reading
  text.
- **And a message naming an outcome is tied to the code that produced it, never printed beside
  it.** `echo "exit=$?  lock removed"` prints *removed* whatever happened, and somebody skimming a
  recovery log reads the word and not the number. Measured on a real recovery: the line said
  `exit=1  lock removed`, and the two halves disagreed.
- **Breaking it on purpose requires guessing the failure mode correctly. Declaring what it
  examined protects you even when you guess wrong.** Of the two habits, the second is primary —
  it was discovered by the first one failing.

**This applies to a verifier written in five minutes to confirm a fix.** Those are the ones that
get believed without proof, because they feel like part of the fix rather than a new instrument.

### And a verifier tested in the wrong environment is untested, whatever its positive control says

**Measured, and it is the case that makes the rule.** A reviewing agent proposed an `awk` semantic
check, exercised it against known positives, and got exit 0 over 264 files. The implementing agent
ran the same script over the same tree and it **aborted on the third file** — a `.docx` the
exclusion list did not cover — printing no findings at all. Wired like the checks around it, with
`|| true`, that step would have gone green while examining three files.

**Neither agent was careless, and the reviewer could not have found it from its own side.** Its
`awk` was GNU awk, which tolerates invalid multibyte input. The implementer's was BWK awk, which
does not. The positive control fired, correctly, and told nobody anything: **a control that fires
in a working environment says nothing about a broken one.**

The rule above is written about the *cases* a verifier must catch. Extend it to the *environment*:

- **Test it where it runs.** If it runs in more than one place, test both, or pin the interpreter
  and the locale so there is only one behaviour to reason about.
- **A non-zero exit fails the job. Never `|| true`.** It is the only guard that holds for the
  implementation nobody has looked at yet.

And note which way the asymmetry ran here: the check lives in CI, where the tolerant `awk` runs,
so the failure appears **only on a developer's machine**. Green in CI and silently dead locally is
worse than red everywhere, because it teaches people to trust a green that measured three files.

## 3 · Measuring

Five rules, each from a case where the arithmetic was right and the object was wrong.

1. **No figure about behaviour without opening what produces it.** If it cannot be run, replicate
   the logic and say that you replicated it.
2. **Declare the object in the same sentence as the figure.** "The file contains X" and "the
   application computes X" are different claims.
3. **Every estimate declares its unit of work** — and declaring the unit does not guarantee the
   unit *is* the work. A count of things that look like the task can include things that cannot
   be touched at all, and miss a whole group that turns out to be zero.
4. **When someone else's figure does not reproduce, check first whether it measures the same
   thing** before attributing the difference to method. Two correct measurements of different
   objects look exactly like one correct and one wrong.
5. **A hand-written list of terms measures whoever wrote it, not the project.** To size
   something, enumerate the project and classify; the list is only useful for prioritising inside
   what is already enumerated.

### A count and its own enumeration are two claims, and they drift

When a sentence gives a number and then lists the things, **the list is the measurement and the
number is a recollection.** Count the list.

This failed three times in one day on the project this method came from, and in both directions:
*"four sections"* enumerating five, *"seven executable lines (24-30, 46)"* which are eight,
*"three locks"* which were two. Twice over and once under, so it does not even have a constant
bias — which rules out the comforting explanation that somebody is systematically optimistic.

It is the same shape as comparing totals instead of sets, moved from a check into a sentence. The
check has the rule; prose had none, and prose is what people read.

## 4 · Scope

**A tool whose reach is wider than the task must have its scope mandatory, not configurable.** A
parameter with a default is a parameter that gets forgotten, and when it is forgotten the default
is the wide scope.

Three faces, all of which have to be checked:

| | |
|---|---|
| **Empty** | The tool ran over nothing and reported success |
| **Narrow** | Part of the work was left out of the batch |
| **Wide** | The tool reached work belonging to something else |

Writing files has the same three faces, and the wide one is `>`. **A file that already exists is
edited, never overwritten** — replacing it takes everything you did not mean to change, and a
check that watches *which* files changed will not notice.

### The shape that hides inside a correct measurement

**A measurement has a shelf life, and nothing on it declares when it expired.** A figure taken
correctly, five minutes before the project moved, looks exactly like a current one — it was
executed, the command was right, the arithmetic was right. It is worse than not measuring,
because there is nothing about it to distrust.

The defence is the same one as everywhere else: the figure travels with what it was measured
against. A count without a version attached is a count you cannot date.

**And it applies to generated values too.** A timestamp typed from memory instead of read from
the clock, an identifier written from recall instead of resolved, are asserted values in the one
place nobody inspects — because a filename or a metadata line does not look like a claim.

### An agent cannot observe its own start time

The state/events frontier is usually pointed at the *other* agent. Point it at yourself: **there
is one event about your own process that you cannot observe, and it is when it began.**

Resuming a session appends to the existing conversation, so the context spans the restart and
nothing in it marks the process boundary. The transcript is continuous because, as a conversation,
it is.

**Measured.** An implementing agent recorded a probe as INCONCLUSIVE on the stated grounds that
*"this session predates the configuration edit"*. It did not: the startup warnings it had itself
printed named rules that only existed after that edit, and the modal it triggered cited one of them
by name. The log was honest and the header was wrong, which is the worst combination to catch from
inside.

**When a measurement depends on when your process started, do not assert it.** Read something the
restart would have changed, or ask the person. It is one line, and it converts a null result into a
positive one.

## 5 · Before trusting a control, check that it exists

A control that does not exist is worse than a verifier that reports success without looking: the
verifier at least runs and can surprise you, while a phantom is cited in discussions and nobody
interrogates it, because it is "how the project is configured".

The pattern to watch for: a policy file that names reviewers, a status check that looks
mandatory, a rule everyone repeats. Any of them can be advisory. **Confirm the mechanism, not the
document.**

## 6 · Point the instrument at itself, on purpose

This is a practice, not a warning, and it has the highest yield of anything here.

The recurring pattern: a check that scans everything **except the file that declares its own
exception**. A rule that enumerates five surfaces and never names the document containing the
rule. A link checker with a dead link inside its own comment. A file whose header says it gets
rewritten, accumulating five sections because nobody re-read it.

They are all the same hole, and they share one property: **nobody looks there, because it is the
instrument.** Whoever built it knows what it does, so they check the work instead.

Two habits, both cheap:

- **Every structural exemption carries its own assertion.** If a file is skipped by a check, there
  is a test that looks at it *with the exemption lifted*. That exemption is, by definition, the
  one place in the project nothing watches.
- **When you write a rule, ask whether it applies to itself, and write the answer down.** The
  defect is rarely the answer — it is the silence. A governing document that does not say whether
  it governs itself will be read both ways.

## 7 · Two correct rules can have a wrong intersection

A rule that says what **not** to do, without naming what has to **survive**, leaves every
compliant reading looking correct.

The case that produced this: a file was destroyed by being overwritten, so the rule became *edit,
never overwrite*. It was followed exactly — and each new section got appended above the last,
because "edit" permits adding. Five milestones later the file was mostly obsolete sections and
none of them described the live content. The rule was right. What it did not say was that the
**header** had to survive and the **section** had to be replaced.

> **State the invariant, not just the forbidden method.** And when a preservation rule
> ("nothing is deleted") meets an object that declares itself transient, the preservation rule
> does not apply — that is data hygiene, not a licence for files to accumulate.

## 8 · Four names that a change does not carry with it

Whenever something gets renamed — a symbol, a file, a key, a section — four frontiers exist where
the new name does not follow, and only the first is loud.

| Frontier | What it looks like | Loud? |
|---|---|---|
| A name that is also a **string** | Accessed by reflection or by lookup, often with a fallback value | **Silent** when there is a default: it returns the default instead of failing |
| An **argument consumed as a key** | Declared in one place as a parameter, read elsewhere as a literal key | Loud, but only on the path that runs |
| **Prose citing an identifier** | A message, comment or document naming a constant, a path or a command | Silent. Nothing reads prose |
| A symbol belonging to **something outside the project** | An interface with a file, a service or a person's own artefact | **Silent, and no check in the project can ever see it** |
| **Prose containing an executable** | A fenced command block in a document | **Silent, and worse than the row above: a command does not look like a claim, it looks like a fact, and every reader assumes somebody ran it** |

The fourth is the dangerous one. Before renaming, the question is not *is this in our language?*
but **does this project own the name?** If the symbol crosses a boundary the project does not
control, it is data, not an identifier — the same category as a stored key or a published field.

A useful tell: if a rename touched one symbol of a pair and not the other, it was applied **by
form** — matching what looked like a candidate — rather than **by category**. That asymmetry is
evidence, and it is easier to spot than the breakage.

## 9 · A check that partitions on two conditions has four regions

Name all four before deciding which ones to act on. Two of them usually get implemented, one is
obviously fine, and the fourth is where things quietly live:

| | Included | Not included |
|---|---|---|
| **Inside the declared scope** | correct | caught: incomplete work |
| **Outside the declared scope** | caught: foreign work | **invisible** |

The invisible region falls between the two filters — each one excludes it for a different reason.
It is not necessarily an error to have things there, so it should **report rather than block**: a
check that forbids legitimate local work gets switched off, and then protects nothing. The
difference between "I decided that" and "nobody looked" is the whole point.

### The fifth row is the one that cost the most

A documented query that matches nothing survived a full adversarial review, a rewrite and a
release-shaped bundle — because it was read as a fact rather than as a claim. Ten citations across
six files, and the front matter it searched was written with two spaces while every query used one.

> **A fenced command block is a claim, and it carries the output it produced when someone ran it.**

That is the same rule this file already applies to figures — *no figure about behaviour without
opening what produces it* — applied to a document's own commands. The stronger form, and the one
worth building: **extract every fenced block and run it against a fixture in the pipeline.** It is
the self-test pointed one level out. The validator proves the bundle; nothing proved the prose.

## 10 · Extending a barrier does not re-examine what it already recorded

When a check gets better, the new logic covers what arrives next. What was recorded under the old
logic stays as it was — and the check, running its new logic, correctly reports that there is
nothing new.

This is the general shape of every guardrail migration, and it is silent by construction. When
you widen a check, **re-apply it to its own existing record in the same change**, and say that
you did.

## 11 · When this check passes, what else would have made it pass?

**Write down the cheapest wrong thing that would also pass**, before trusting the check. For a
count, that sentence is *"a different set with the same total"* — and writing it is what makes you
compare sets instead of totals.

Three of this repository's own instruments failed exactly there. One compared line totals, so four
queries summing to the right number looked correct. One built its fixture with a hand-rolled writer
while claiming it used the shipped one, so it agreed with whichever side the author had in mind.
One printed `ok` whenever the unmutated run had any finding at all, which is independent of whether
the mutation was noticed.

**And mutate the fixture, not only the checker.** A checker that survives its own mutation may still
be reading an object that cannot express the defect: the fixture had no `consensus` addressed to the
person, so the correct and the incorrect derivation returned the same set and both passed. The
mutation has to reach the *data*, or you have tested the code around a hole.

## 12 · A verdict from outside leaves no artefact unless you catch it

Everything above governs events **inside** the work: a command ran, a check passed, a rule
refused. Each has a rule, and the rule is always the same one — turn the event into state so
somebody who was not there can read it.

There is a second class, and it had no rule at all: **an event that happens elsewhere and comes
back as a verdict.** An install. An upload. A publish. A gate refusing. You do not run these; you
submit to them and something answers, and the answer arrives once, in an interface, and is gone.

> **Attempt it, capture what came back verbatim, and put the file where the claim lives.**

Three things make this the easiest artefact in the method to lose:

- **It feels like a result rather than an event.** *"It installed"* sounds like a state of the
  world, so nobody thinks to log it — while *"the tests passed"* has been drilled into a log for
  years.
- **The failure is the informative half, and failures get fixed rather than filed.** You read the
  error, change something, try again, and the message that told you what the gate actually
  enforces exists only in the memory of whoever was at the keyboard.
- **It gets reconstructed later into prose**, in a commit message or a code comment, which reads
  like a record and is a recollection. A week on, nobody can say which version was refused or what
  exactly it said.

So a claim of the form *"this is accepted by X"* carries a path, on the same terms the floor
already lives under: **never `accepted` without a log.** And the log is written before the attempt
with the outcome blank, so an attempt nobody finished looks unfinished rather than absent.

Note what this is not. It is not evidence that the artefact is good — it is evidence of what one
gate said on one day about one version. That is exactly why it has to be written down rather than
remembered: it is narrow, it expires, and it is the only thing you have.

---

## 13 · Write the prediction before you run the probe

Everything above builds instruments. This one is about the only failure the instruments never
caught.

The first execution of the floor procedure produced nineteen observations and **five false
conclusions** — plausible ones, stated with confidence, each of which would have gone into a
report as a finding. *"In ten probes not one prompt appeared."* *"Two `ask` rules matched and
nothing prompted."* Both were wrong for the same reason: the agent cannot see a prompt, so it read
its own blindness as evidence of absence.

**Not one of the five was caught by a check.** All five were caught by somebody looking again —
four retracted by the agent that had written them, one by the reviewer. The verifiers, the
self-tests, the declared scopes: none of them was pointed at this, because none of them can be.
A conclusion is not an artefact.

The one thing that did work, and it worked both times it was used:

> **Before running a probe, write down what you expect it to show — and what result would mean
> you were wrong.** Then run it.

It costs a sentence, and it converts an observation into a test. Without the prediction, an
ambiguous result gets read in whichever direction the reader already leaned, and the reading feels
like observation rather than interpretation. With it, the ambiguity is visible: the result matches
the prediction, contradicts it, or fits neither — and the third case is the one that produces the
real finding.

It also catches the specific shape above, which is the commonest. *"I expect no prompt"* is not a
prediction an agent can test, because it cannot observe prompts. Writing it down forces the
question *how would I see that?*, and the answer — **I would not, the person would** — arrives
before the false conclusion instead of after it.

### And the part that does not scale

Say it plainly rather than end on the habit: **the control around the control is still that
somebody takes it seriously.** Every mechanism in this document is a way of making that person's
attention go further — declaring scope so a blind run is visible, breaking a verifier so a silent
one is not trusted, naming the cheapest wrong thing so a lucky pass is caught. None of them
replaces the attention; they concentrate it.

That is the honest limit of this whole file, and knowing it is what keeps the rest useful. A
method that claimed otherwise would be the phantom control it warns about, one level up.

---

## Every command block leaves a record

This is the mechanism that converts an event into state, and it is what lets the reviewing agent
work at all.

**Any block of commands writes its output to a file — whoever runs it.** Without exception, even a
single line.

The "whoever" is load-bearing. An implementing agent holds a shell and runs things itself; if the
rule only covered blocks handed to a person, everything that agent did alone would leave no trace,
and the reviewing agent would be correct to say *"no record here"* about most of the project. The
frontier that makes review possible would close over the work being reviewed.

```
<runs-directory>/YYYYMMDD-HHMMSS-<slug>.log
```

Four rules about the content:

1. **Capture both output streams.** Errors travel on the one nobody reads.
2. **Take the return code on the line after the command**, never inside a formatting call with a
   substitution in it — the substitution runs first and you capture its code instead.
3. **The header declares what it ran against** — the version, the branch, whatever identifies the
   state. A record that does not say what it ran against cannot be judged still valid, and a
   figure measured before the project moved looks exactly like a current one.
4. **The block prints its own log path, and the agent that wrote the block reads it.** Nobody hands
   output to anybody. Asking a person to paste results back makes them the transport again, which
   is the failure this method opens by naming — and **what travels through a chat is altered by
   it**: a commit body pasted between sessions can lose the blank line between subject and body,
   with neither end able to tell.

   **It runs both ways**, and only one direction was written down. A summary handed to the person
   to carry **forward** is the one an agent produces while being helpful: measured, a reviewing
   agent handed over a block summarising a message already sitting complete in the channel. **Never
   hand the person a message to relay.** The tell is that the summary looks *useful* — shorter,
   shaped to what they want — which is exactly what makes it a second lossy copy.

   **Two exceptions, both where no log exists to read**: an install verdict and a permission rule's
   refusal happen outside the project and come back once, in an interface. Those get pasted
   verbatim onto a line the block left blank — see §12.

And one rule about the directory, corrected by measurement after being written the other way round.
It was *"raw output by design; nothing scans it, and what protects it is that it does not leave."*
**That is false, and it hid a live exposure.** A third party's name and national ID were removed
from the tracked tree by a commit that turned the barrier green — and stayed intact in the channel
message reporting the fix, because the run directory is gitignored and the project's scanner had
therefore never looked at it. **Outside version control is not outside disk.** Talking about a value
copies it here; removing it from the tree does not remove it from here.

```sh
channel-status.sh --audit <runs dir>
```

**And it opens a conflict this method has to state rather than inherit.** A channel message is never
edited — a correction is a new file. The first floor class says the damage is not undone by
reverting. On this one file the two rules contradict each other, so **class 1 is the single
exception to immutability**: redact the value in place, leave an immutable mark saying what was
redacted and why, and never remove the message. Without the exception the protocol requires keeping
what the floor forbids keeping.
