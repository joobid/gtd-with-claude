# The three parts, and the frontier between them

| | Does | Never does |
|---|---|---|
| **Claude Code** | Implements. Runs what its permissions allow, **and everything it runs leaves a log**. Writes the command blocks the person executes | Runs a destructive command without approval. Touches its own permission configuration. Widens its own declared scope |
| **Claude Cowork** | Specifies, plans, reviews **against the project files**, makes small well-defined fixes | Answers a permission prompt — those are modal and no file reaches them. Edits files while another milestone is open |
| **The person** | Executes what only they can execute. Decides what the two agents cannot settle | Carries a question or an answer by hand. That is what the channel is for |

---

## The frontier that makes review possible

**Cowork verifies state. It cannot verify events.**

| Can | Cannot |
|---|---|
| File contents, configuration, structure, what is unsaved | Whether the tests ran, and what they returned |
| What a project *is*, at the moment of looking | Whether a check rejected something last week |
| | What a command printed |

A project records **state, not history**. That is not a limitation to work around; it is the
shape of the thing, and pretending otherwise produces a specific error:

> **Never assert a negative about an event.** If the project does not record it, the answer is
> *"no record here"*, never *"it was not done"*.

That error is easy to make and expensive to catch, because it sounds like diligence. It is
someone reading a file that could never have contained the answer and reporting the absence as a
finding.

### A verdict on a paraphrase is worth nothing

The same frontier applies to what arrives second-hand. Asked to judge something, ask for the
artefact — the actual output, the actual block, the actual file — not a summary of it. A summary
is somebody's reading, and a verdict on somebody's reading is a verdict on the wrong object.

This is the failure the channel exists to remove, so it is worth naming: relaying *output* by
hand was the first version of it, and relaying *reasoning* is the same thing one level up.

### The consequence: events must leave state behind

Anything whose acceptance criterion is an event has to leave an artefact. That is the whole
reason command blocks write their output to a file — it converts *"the tests passed"*, which only
one session knows, into a file anyone can read afterwards.

The same rule ranks evidence. *"The build is green on this exact version"* is worth more than
*"the build passed"*, because the first is state attached to an identifier and the second is a
memory.

**And this is why the logging rule cannot be conditional on who runs the block.** An agent with a
shell runs things itself — that is what it is for. If only the blocks handed to a person were
logged, everything the implementing agent did alone would be invisible, and the reviewing agent
would correctly report *"no record here"* about the bulk of the work. The frontier would close over
exactly what it exists to review. **Whoever runs it, it leaves a log.**

---

## Who is asked, and when

The person is brought in when, and only when:

| | |
|---|---|
| A message is marked `state: escalated` | The disagreement survived the facts. It is a judgement call, not a measurement |
| A red-category command | See `reference/approvals.md` |
| A permission prompt | No channel reaches it |
| Privacy, real data, history, spending, or anything leaving for a third party | The floor. **Never** settled by agreement between agents |
| A milestone boundary | If the configuration says they approve plans or closures |

Everything else the two agents settle between them and record.

---

## Disagreement is not escalation

Two agents who disagree **exchange until one of them is shown a fact**, with the command that
produced it. Disagreement is usually not a difference of judgement: it is two measurements of
different objects, and the fix is to name the object rather than to pick a side.

**A number that does not reproduce is not a disagreement yet.** Before attributing the difference
to method, check whether the two sides are counting the same thing. Two correct measurements of
different objects look exactly like one correct and one wrong.

What reaches the person is what survived that, marked `escalated` — and it arrives with both
positions and the facts each rests on, not with a request to arbitrate.

---

## Session hygiene

- **One milestone open at a time**, *where the project has something that says which one is open*.
  That is a convention some projects keep and others do not — see `git-annex.md`; in a project
  without it, nobody can check this and it is an agreement rather than a rule. Where it exists as a
  single file declaring the current scope, it is a one-slot resource with two writers. Whoever holds it works and hands it back. Finding it
  declaring somebody else's milestone means there is unfinished foreign work — stop and say so,
  do not overwrite it.
- **Prefer new sessions over long ones.** Most of what a session accumulates should be in the
  project by now. A long context does not only cost more: it grows confident about things it has
  stopped checking.
- **A handover prompt is prose citing identifiers, and it decays.** Paths move, counts change. A
  prompt says *what* to read; the session resolves it against the project. If something in the
  handover does not exist, the project is right and the prompt is old.
