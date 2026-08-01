# Writing a message

## Create the file with a command, never by hand

Both the timestamp and `head:` are **generated values**. Typed from memory they are asserted
rather than measured, in the one place nobody inspects — a filename does not look like a claim.

A message stamped even a few minutes ahead sorts in front of the answer that replies to it, and
the directory stops being ordered. That is the single property the whole channel rests on.

**UTC on both.** The two sessions run in different environments with no guarantee of a shared
timezone — one in a container, one on the person's machine. Local time puts one session's messages
hours away from the other's and inverts the ordering between the only two participants there are.

```sh
CHANNEL=".runs/exchange"          # or wherever the channel lives
AUTHOR="cowork"                   # who is typing: code | cowork
FROM="cowork"                     # who it is from: code | cowork | owner
TO="code"                         # code | cowork | owner | both
SLUG="floor-does-not-ratchet"     # short, hyphenated, says what it is about
RE="-"                            # filename this answers, or -
STATE="open"                      # open | consensus | settled | escalated

mkdir -p "$CHANNEL"
# A commit reference is a property of the project and supports a staleness check.
# A clock reading is not, and says so, so nobody compares it for equality.
if HEAD=$(git rev-parse --short HEAD 2>/dev/null); then HEAD="sha:$HEAD"
else HEAD="clock:$(date -u +%Y%m%dT%H%M%SZ)"; fi
MSG="$CHANNEL/$(date -u +%Y%m%d-%H%M%S)-$AUTHOR-$SLUG.md"

cat > "$MSG" <<EOF
---
from: $FROM
to: $TO
re: $RE
state: $STATE
head: $HEAD
---
EOF
echo "$MSG"
```

`cat >` is safe here **because the file is new by construction** — the timestamp guarantees it.
Everywhere else in a project, `>` on an existing file is the wide scope of writing files.

## Then append the body. Do not rewrite the file

```sh
cat >> "$MSG" <<'EOF'

## What I found

...
EOF
```

**`>>`, not a write of the whole file.** An agent holding a file-writing tool will happily replace
the file including the header it just generated — and then the timestamp and `head:` are whatever
that agent believed them to be, which is exactly the fabricated-value problem the command above
exists to prevent. The header is generated once and never retyped.

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

---

## Choosing `state:`

| | When | Constraint |
|---|---|---|
| `open` | You are asking. Nothing has been agreed | — |
| `consensus` | The two agents agree | **`re:` must point at a message from the other agent.** A consensus with `re: -` is one agent asserting a two-party fact, and authorises nothing |
| `settled` | The person decided | `from: owner`, `to: both`. No exchange required, and not reopened |
| `escalated` | The disagreement survived the facts | Goes to the person with **both positions and the evidence each rests on**, not as a request to arbitrate |

The `consensus` constraint is what makes the rule checkable instead of aspirational. Without it,
one agent can write "agreed, proceeding" and act while the other never read it — and the record
says consensus, and the record is what gets audited.

## Recording what the person said

A `from: owner` message is a paraphrase you are writing **about somebody else**, that both agents
will then treat as not reopenable. Three obligations come with that:

- `from: owner`, `to: both`, `state: settled`
- **The `ASKED:`/`ANSWERED:` block goes in the language the conversation happened in.** The rest of
  the message stays English. It is the only part of this system the person needs to be able to
  audit, and it is about them
- **Show it back in the same turn**, in one line. A "no" produces a new message correcting this
  one

If it replaces an earlier decision, `re:` points at the message it revokes. Without that link the
revocation is invisible to anyone reading by grep rather than by date.

## Answering

- Set `re:` to the filename you are answering. That is what makes an open question discoverable as
  one nothing has closed.
- **Check `head:` first.** If it is a `sha:` and no longer matches, the question is stale — say so
  and ask it again rather than answering into a moved project. Asking is one file. If it is a
  `clock:`, there is nothing to compare; judge from the content.
- Disagreeing? Show a fact with its command. A number that does not reproduce is not a
  disagreement yet: check first whether the two sides are measuring the same object.
