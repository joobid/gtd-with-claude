# The annex: what depends on having a repository

The method works without version control. This file is everything that only makes sense with it.

If a project has no repository, ignore this file entirely — the core does not depend on any of
it.

---

## Where the channel goes

Put it **inside a directory the repository already ignores**, next to the command logs:

```
.runs/exchange/
```

Two reasons, and the second is the one that matters:

1. The channel is raw working output. It is exactly where a real value lands if one is ever
   printed, and an ignored directory means it cannot be committed by accident.
2. **It therefore does not survive a fresh clone.** That is not a defect — it is the property
   that forces every consensus into a tracked file. If the channel were versioned it would start
   being treated as the record, and the record would be a directory nobody reads.

Add the exchange directory to the ignore rules **before writing the first message**, not after.

## `head:` is a commit reference

This is the annex's main contribution: with a repository, the staleness check has a real
identifier instead of a timestamp.

```
head: sha:<short commit, read with a command, never typed>
```

An answer written against a commit the project has moved past is stale, and the reader can
establish that in one comparison instead of by reading the whole exchange.

**Without a repository there is no staleness check**, and the core says so rather than implying
one: `head:` falls back to `clock:<utc>`, which records *when* a message was written and nothing
about the project. A clock reading compared for equality never matches — two clocks read at
different moments always differ — so a rule demanding a re-ask on mismatch would mark every message
stale and loop for ever. The prefix is what keeps the rule silent where it cannot apply.

If a repository-less project has some other stable identifier for its state — a build number, a
release tag, a content hash over what it cares about — use it with its own prefix and the check
comes back.

## Scope, if the project declares it

Some projects keep a file naming what the current milestone is allowed to touch, and a pre-commit
check that compares staged changes against it. Where that exists:

- **It is a one-slot resource with two writers.** One milestone open at a time. Whoever holds it
  works and hands it back; finding it declaring somebody else's milestone means there is
  unfinished foreign work — stop and say so rather than overwriting it.
- **One section, not an accumulation.** Rewrite the milestone declaration; keep the header that
  explains the file. See `reference/verification.md` §7 for why that distinction has to be
  written down rather than implied.
- **Check all four regions**, not two. `verification.md` §9.

## What a hook can and cannot do

A local pre-commit check is often **the only control that actually blocks anything**. Everything
else on a typical repository is advisory unless it has been verified otherwise:

| Frequently assumed | Frequently true |
|---|---|
| The code-owners file requires approvals | It assigns reviewers; it does not block a merge |
| A green pipeline is a gate | It is informative unless branch protection is configured and available |
| A data-privacy job blocks a push | It warns after the fact |
| A pull request needs approval | Not unless the hosting plan supports and enables it |

**Check the mechanism, not the document** — `verification.md` §5. Branch protection may be
unavailable entirely depending on repository visibility and plan, and a control that does not
exist gets cited in decisions precisely because nobody interrogates the configuration.

Whatever the answer turns out to be, **write it down in the project**. The failure is not having
weak controls; it is reasoning from controls whose existence nobody confirmed.

## Rewriting history

This is on the floor and stays there. Two additions specific to repositories:

- **One pass, not two.** If several reasons to rewrite accumulate — a value that should not be
  there, messages in the wrong language, an author to correct — they get done together. Each pass
  invalidates every clone.
- **It needs confirmation that nobody else has copied the repository.** That is a question only
  the person can answer, which is why it cannot be delegated regardless of preference.

## What else lands in `.claude/` and gets committed by accident

A project-scope install of this skill puts **thirteen files** next to the work, and `git status`
shows them as untracked, ready for the first `git add` of the day. It was noticed here by chance,
while looking at something else.

Decide it explicitly, and write the consequence down rather than the choice alone:

| Option | Consequence |
|---|---|
| Version `.claude/skills/` | It travels with the repository, which is the point of a project-scope install |
| Ignore it | It is installed and not versioned. **It does not survive a fresh clone**, and the only thing that makes its absence visible is the installation table in the configuration |

The two settings files are not the same object either, and one line saves an argument later:

- **`.claude/settings.json` is versioned.** It is the project's floor and its hook registrations,
  and both belong to everyone who has the repository.
- **`.claude/settings.local.json` is not.** It carries one machine's absolute paths and one
  person's accumulated approvals, and neither travels.

## What a reviewing sandbox leaves in `.git`

The general fact belongs to `unattended.md`: on a mounted project that sandbox can create and
rename and **cannot unlink**, anywhere under the mount. What is version control's business is what
that does to a repository.

- **A read-only git command is enough to leave a lock.** It takes `.git/index.lock`, finishes,
  fails to remove it, and still exits 0. The next `git add` or `git commit` then refuses while
  `git status` and `git push` keep working — so a prepared block runs half way and reads as done.
  Measured: exactly that cost a whole block, and later a release whose commit never happened while
  its branch pushed cleanly.
- **`git worktree add` leaves a permanent orphan registry**, which `git worktree prune` will not
  remove because it stays locked.
- **A commit can leave `HEAD.lock` and stray `tmp_obj_*`**, and `HEAD.lock` blocks everything that
  moves HEAD afterwards — including the tag.

So: **no `git worktree add` and no scratch files under the mounted repository from that side.**
Clone to `/tmp` with `--no-local`, which works. And when a block must run against the repository,
have it clear an orphaned lock as its first step, after checking `pgrep git` — a lock with a live
process behind it is a different fact and must not be deleted.

## Reviewing agent permissions

Tool permission files accumulate standing approvals, and they accumulate in the direction of
whatever was convenient at the time. Review them the way you would review any control:

- Broad wildcard rules are the ones with reach. Exact-string approvals rarely match twice and are
  mostly noise.
- Check whether any accumulated rule authorises something the project explicitly forbids
  elsewhere. That combination — a written prohibition and a saved approval for it — is common and
  invisible from either side alone.
- **An agent does not edit its own permission file.** An agent that can widen its own limits has
  advisory limits.

## What a declared scope feels like to use

Two things nobody expects, both learned by hitting them:

- **It serialises your batches.** The narrow case — a file inside the declared scope, modified and
  not staged — usually *blocks* rather than warns. So a scope naming two files refuses the commit
  of the first while the second is still pending, and two unrelated edits cannot ride in one
  declaration. The rhythm is **scope → commit → scope → commit**, one subject at a time. That is
  the feature working, not the tool misbehaving: it is what stops a batch from quietly carrying
  half of somebody else's work. But it is worth knowing before the first refusal, because the
  natural first attempt is to declare everything in flight and commit it together. It cost four
  refusals in one afternoon before anyone wrote this down.

- **Work outside the declared scope is the invisible region** — §9 of `verification.md`, the
  fourth region of a check that partitions on two conditions — and it is fine to have things
  there. A local edit belonging to no milestone is legitimate. It should be **reported, never
  blocked**: a check that forbids ordinary work gets switched off, and then it protects nothing.

## The daily triage, in version-control vocabulary

`approvals.md` Part 3 asks one question — *if this is wrong, do I get it back?* — against
whatever a project uses as its record. Here is that table with the record being a repository,
and the specific spellings that belong in each row.

It lives here rather than there for a reason worth stating: **the triage is the instrument used
every day**, and the questionnaire is shown once. A daily instrument written only in commits and
branches would have quietly narrowed the whole method to codebases, which is exactly what the
core promises it does not do.

| | Here that means |
|---|---|
| 🟢 | `status`, `log`, `diff`, `show`, `grep`, running tests, editing a file already committed |
| 🟡 | `add <named paths>`, `commit`, `switch -c`, `stash push`, creating new files |
| 🔴 | `reset --hard`, `checkout` over unsaved work, `clean`, `push --force`, `filter-branch`, `filter-repo`, `rebase` on a published branch, `add .` or `add -A` |

Three notes, each of which cost something to learn:

- **`add .` and `add -A` are red, not amber**, and the reason is not tidiness. They stage whatever
  happens to be in the tree, so what gets committed is decided by what was lying around rather
  than by anyone. It is the same defect as `>` on an existing file: an operation that looks
  narrower than it is.
- **`push --force-with-lease` is not `push --force`.** It aborts if the remote moved, which is the
  property that makes it recoverable. Denying both pushes people towards the unsafe one.
- **Amber still needs its own check.** `commit` that prints what it committed, `add` that prints
  what is staged. Exit zero says `git` ran, not what it did.
