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
