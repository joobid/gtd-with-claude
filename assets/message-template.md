# Writing a message

## The writer is a script, and shipping it that way is the fix

`gtd-msg.sh`, next to this file, creates a message. **Call it. Do not retype what it does.**

```sh
gtd-msg.sh --author cowork --from cowork --to code --state open \
           --slug floor-does-not-ratchet <<'EOF'
## What I found

...
EOF
```

It prints the path of the file it wrote. The body comes from standard input, so it can be a
heredoc, a file, or the output of something else.

**Why a script and not a block to type, and it is measured.** Building the filename by
substitution and feeding a heredoc is a shape no permission pattern can cover — *"contains shell
syntax that cannot be statically analyzed"* — so the most frequent operation in the whole method
prompted the person **every single time**, and the only relief on offer was the standing approval
this skill spends a page warning against.

A named entry point is allowed once and is reviewable in the repository. It is the rule this skill
already gives for `python3 -c` — *allow by entry point, never by interpreter* — turned on the
skill's own machinery.

```
allow: Bash(<path>/gtd-msg.sh*)
```

## What it enforces, so nobody has to remember it

Four things that were prose until they were a script:

| | |
|---|---|
| **The four vocabularies** | `--author`, `--from`, `--to` and `--state` are checked against the values the protocol defines. A typo refuses and writes nothing |
| **`consensus` requires `re:`** | One agent typing "we agreed" into its own front matter is a unilateral claim about two parties. The script refuses rather than trusting that the agent read the rule |
| **The same-second collision guard** | **Measured on day one:** two messages written in the same call landed with the same second in their names, the second answering the first, and the ordering survived only because the slugs happened to sort in causal order. An agent that records a decision and then notifies the other writes two files back to back, so this is the common case rather than the edge one |
| **`head:` carries its kind** | `sha:` where there is a repository, `clock:` where there is not. Read from the source, never typed |

That last one is the reason the writer exists at all. **A generated field is read from its source,
never typed from memory**, and a filename does not look like a claim, so it is the one place an
asserted value passes unexamined. A message stamped five minutes ahead sorts in front of the answer
that replies to it, and `ls -1` stops being ordered — which is the single property the whole design
leans on.

**UTC on both.** The two sessions run in different environments with no guarantee of a shared
timezone, one in a container and one on the person's machine. Local time puts one session's
messages hours away from the other's and inverts the ordering between the only two participants
there are.

## Nothing here is ever reopened

The script creates. It does not edit, and neither does anything else: a correction is **a new file
that answers the old one**, never a rewrite.

That is not only a convention now. `floor-mechanism.md` carries the rule that makes it refuse:

```
deny: Edit(<channel>/**)
```

An agent that reopens a message can lose most of the record and nothing notices, because the tools
that watch a project watch *which* files changed and not how much of each.

---

## Template for the body

```markdown
## What I found

One paragraph. What it is, and why it matters — not how you got there.

## How to reproduce it

The command, and its output. A figure without the command that produced it is an assertion,
and an assertion is what the other agent will have to verify from scratch anyway.

## What I propose

What you would do, and what it costs. If you see two ways, say both and say which and why.

## What I could not check

The frontier is real and stating it is not a weakness. "No record here" is a finding;
"not done" would be a claim about something you cannot see.
```

**And if you are waiting on something, name the artefact that ends the wait** — the log that has
not appeared, the message nobody answered. Not "waiting for the owner".

---

## Choosing `state:`

| | When | Constraint |
|---|---|---|
| `open` | You are asking. Nothing has been agreed | — |
| `consensus` | The two agents agree | **`re:` must point at a message from the other agent.** The script refuses without it |
| `settled` | The person decided | `from: owner`, `to: both`. No exchange required, and not reopened |
| `escalated` | The disagreement survived the facts | Goes to the person with **both positions and the evidence each rests on**, not as a request to arbitrate |

## Recording what the person said

A `from: owner` message is a paraphrase you are writing **about somebody else**, that both agents
will then treat as not reopenable. Three obligations come with that:

- `--from owner --to both --state settled`
- **The `ASKED:`/`ANSWERED:` block goes in the language the conversation happened in.** The rest of
  the message stays English. It is the only part of this system the person needs to be able to
  audit, and it is about them
- **Show it back in the same turn**, in one line. A "no" produces a new message correcting this one

If it replaces an earlier decision, `--re` points at the message it revokes. Without that link the
revocation is invisible to anyone reading by grep rather than by date.

## Answering

- Set `--re` to the filename you are answering. That is what makes an open question discoverable as
  one nothing has closed.
- **Check `head:` first.** If it is a `sha:` and no longer matches, the question is stale — say so
  and ask it again rather than answering into a moved project. Asking is one file. If it is a
  `clock:`, there is nothing to compare; judge from the content.
- Disagreeing? Show a fact with its command. A number that does not reproduce is not a
  disagreement yet: check first whether the two sides are measuring the same object.
