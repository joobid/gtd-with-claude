# Running without anybody there

**Status: designed, no observed executions. 2026-08-04.** Nothing below has run. It is a contract
for bounding an execution with nobody watching — not a description of what was measured. A section
that reads as tested when it is not is a control reporting success, which is the defect this whole
method exists to catch.

**Unattended operation is not an added capability. It is the existing design taken seriously.** The
method already insists that all state lives on disk, that a session *derives* where things stand
rather than being handed a summary, and that `resuming.md` is a procedure. A scheduled run is that
claim executed with nobody watching. If a cold start works at 10:00 with a person present, it works
at 03:00 without one — **and if it does not, the cold start was the thing that was wrong.**

---

## The blocker, and it is not optional

**`ask` presupposes a person. Remove the person and it is not a weaker `deny` — it is undefined.**

Measured on a real project: `deny 23 · ask 17 · allow 4`. Take the person away and **17 of 44 rules
have no defined behaviour**. Whether the tool hangs until a timeout, denies silently, or never
evaluates the file at all has three different consequences — the first wastes the run, the second is
correct by accident, and the third leaves the rule holding nothing.

**So an unattended run uses a profile in which every `ask` is a `deny`.** That is a property of a
three-valued model where one value names a human, not a configuration preference.

And it is load-bearing for more than the merge: on that same project `Bash(git push*)` is in `ask`,
so an unattended implementing agent **cannot push its own branch** until the floor is changed.

---

## What is never delegated, and why that sentence is general

| Never delegated | |
|---|---|
| The merge | |
| Approving a plan | |
| Accepting a closure | |
| Changing scope mid-flight | |
| The permission configuration | |

**Committing to a branch is reversible and publishes nothing. Merging is what makes something
count.** A green tick is not an authorisation.

**The merge belongs in `deny`, not in prose.** `deny Bash(gh pr merge*)` constrains the agent and
not the person, who runs it in their own terminal. Say what it does not cover in the same breath: a
local `git merge` followed by a push, or the web interface. It is a rule about one spelling, like
every other rule about a command.

**With one PR per sprint that merge is the only gate through which anything reaches the main line.**
Not one safeguard among several — the whole door.

---

## Bounded delegation

**Approving the plan enables nothing.** The person separately and explicitly accepts CONSENSUS mode
for that sprint. Without that acceptance the previous mode stands: it fails closed.

One sprint, one PR, one merge.

**The window is the life of a branch**, derived from two conditions in AND:

1. acceptance recorded — in the channel and in `gtd-config.md`
2. the branch exists and is unmerged — in git

The second lives in version control; the channel usually does not. An orphaned window needs no
timeout, because a new sprint brings its own rule — it is enough that the state file says how long
it has been open with no activity.

```sh
channel-status.sh --delegation
```

Open or closed, since when, by which message, against which branch.

**And a correction that must not be inherited.** An earlier draft claimed that `state: consensus`
requiring `re:` prevented a lone agent from committing on its own. **It does not.** The writer
enforces `re:` over *messages*, not over git operations, and an unattended agent can commit without
writing any message at all — demonstrated: a commit landed with zero messages in the channel. What
holds that safeguard up is the habit of agreeing the commit plan in the channel, and nothing checks
that a commit corresponds to an agreed plan. A real mechanism would be a `pre-commit` hook
requiring the message to cite the channel file where the plan was agreed. That is not built.

**Cost, verified:** Sprint 16 reached the main line through more than one PR. One PR per sprint
means the branch lives longer and arrives more divergent. The existing mitigation is commits by
subject inside the PR — the PR is the unit of merge, the commit the unit of review.

---

## The queue

| | |
|---|---|
| One item per execution | |
| Append only | |
| **Only the person or the other agent add items** | An execution may write what it finds to the channel — that is a record, not a task |
| **An empty queue is a RESULT** | Do not invent work |

**The bound is the queue, not the clock.** An agent told to keep working produces method artefacts
indefinitely: the method's queue always has something in it and the project's does not.

**The implementing side needs no queue.** Its queue is the approved sprint plan. Inventing a
parallel one would create a second source of truth about what it should be doing.

---

## The state file

Derived, not accumulated. In the person's language. Readable in two minutes.

**"Decisions waiting on you: none" is a required answer**, not an omission.

**Two stamps, start and end.** A run that dies halfway leaves the previous state, which is
indistinguishable from one that has not started. With a start stamp written before anything else
and the state written at the end, three cases separate: not run (both old), running (start new, end
old), died (start new, end old, and the start older than one cadence).

**And if the derivation has not changed and git has not moved, the run stops without rewriting the
state.** Then its timestamp means *the last time something happened* rather than *the last time a
clock fired*. That is also the answer to whether the hour is the right cadence: it is not the
cadence that needs changing.

**Parked items are a counter in the state, not an event that scrolls past.**

**`git status` before editing, and the run leaves a signed mark** — its identity and its hour. A
dirty tree carrying your own mark is recoverable; carrying somebody else's it is not. Nothing signs
the trail today, which is why the rule about not being the second writer cannot tell the two apart.

**An execution never creates or modifies its own schedule.**

---

## Ageing

The derivation prints how old each pending item is. A `--decide` from forty hours ago and one from
ten minutes ago stop being the same object the moment they are seen side by side. No new field is
needed: the timestamp is in the filename and the derivation already orders by it.

---

## A sandbox that can create files and not remove them cannot clean up after itself

Measured across a mounted project, from the reviewing side: `touch` succeeds, `mv`
succeeds, and `rm` and `find -delete` both return *Operation not permitted* — **anywhere
under the mount**, and normally outside it.

```
touch <project>/.runs/zz-probe          ok
rm -f <project>/.runs/zz-probe          Operation not permitted, the file survives
mkdir <project>/.claude/skills/zz-dir   ok
rmdir <project>/.claude/skills/zz-dir   Operation not permitted
touch /tmp/zz && rm -f /tmp/zz          ok
```

**It was found twice as something narrower and both readings were wrong** — first as a
property of `.git/index.lock`, then of `.git`. It is neither, and the correction matters
here rather than in the annex: one of the probes above is under `.claude/skills/`, which
has nothing to do with version control. This is not a git fact. It is a limit on what an
unattended session can do anywhere.

So an unattended reviewing run **needs a person to finish tidying**, which is the thing
unattended operation exists to avoid. Three consequences:

- **Every stray file it creates outlives it.** A probe, a scratch copy, a temporary
  fixture. Prefer `/tmp`, which is outside the mount and behaves normally.
- **`git worktree add` from that side leaves a permanent orphan registry** that
  `git worktree prune` will not remove, because it stays locked. Clone to `/tmp` with
  `--no-local` instead. `git-annex.md` carries the version-control detail.
- **A git command that takes a lock and exits still leaves the lock**, silently, because
  it exited 0. The dangerous shape is a lock that makes a later command *look* done: one
  cost a whole prepared block that appeared to execute.

**And note what it costs to establish any of this.** Probing an unlink restriction is a
create-then-delete in the exact place delete is known to fail, so the probe leaves behind
what it is measuring. Read the log of a previous probe before running a new one.

## What the skill cannot ship

**The scheduling.** It is a host capability and it differs between the two sides. Everything here is
about the channel, the queue and the contract — never about a particular scheduler.

---

## What reaches the person

**`SKILL.md`, "How to write to the person", is the rule and it applies everywhere** — chat,
channel, state file, attended or not. Nothing about it is specific to running unattended.

The state file follows it like anything else: four sections, and *"decisions waiting on you:
none"* as a required answer rather than an omission.
