#!/usr/bin/env python3
"""Run every channel query this repository documents, against a fixture with a known answer.

Why this exists, and it is the sharpest finding of two adversarial reviews:

    This method has an elaborate doctrine for verifying claims about a PROJECT --
    declare your scope, break the verifier before trusting it, confirm the mechanism
    rather than the document, never assert a negative about an event. It had NO
    doctrine for verifying the claims made by its own DOCUMENTATION.

`reference/verification.md` names "prose citing an identifier" as a silent frontier.
It did not name **prose containing an executable**, which is the same frontier and
strictly worse: a command in a fenced block does not look like a claim, it looks like
a fact, and every reader assumes somebody ran it.

That is exactly how `grep -l '^from: owner'` survived a full adversarial review, a
rewrite and a release-shaped bundle while matching nothing at all -- the front matter
was written with two spaces and every documented query used one.

So: a fenced command block is a claim, and this runs it.

    python scripts/check_doc_commands.py              check
    python scripts/check_doc_commands.py --self-test  prove it fails when it should

WHAT THE THIRD REVIEW CHANGED HERE, because the first version of this file failed in
three ways at once and every one of them is a lesson this repository already teaches:

  * It compared LINE TOTALS, one per fenced block, against one expected number. A block
    holding four queries summed all four. Every figure it ever reported was a sum, and a
    total cannot distinguish a right answer from a right total. It now compares SETS OF
    FILENAMES, one comparison per query.
  * It built the fixture with a hand-rolled writer while its own docstring claimed the
    messages were "created by the very command message-template.md documents". They were
    not. So the fixture agreed with whichever side the author had in mind, and R2-01 --
    the exact drift this file was built to catch -- passed through it in silence. The
    fixture is now built by EXTRACTING AND RUNNING that block. Change the documented
    writer and the fixture changes with it.
  * Its self-test printed `ok` whenever the unmodified run had any finding at all, which
    is independent of whether the mutation was noticed. It now compares FINDING SETS --
    a mutation is detected only if it adds a finding naming the thing that was mutated --
    and it runs against canonical queries held in this file, so a broken document cannot
    disable the instrument's proof of itself.

The habit underneath all three, which `reference/verification.md` now states as doctrine:
**when you write a check, write down the cheapest wrong thing that would also pass it.**
For a count, that sentence is "a different set with the same total", and writing it is
what makes you compare sets.
"""
from __future__ import annotations

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Documents are DERIVED from the tree, never listed. A hand-maintained list measures
# whoever wrote it: the previous version listed eight files, four of which contain no
# sh blocks at all, and omitted reference/floor-mechanism.md -- which was added to
# answer a review finding, ships in the bundle, and carries two runnable blocks.
DOC_GLOBS = ("reference/*.md", "assets/*.md", "README.md", "SKILL.md")

# Placeholders a document legitimately carries because it is a template. Anything else
# in angle brackets is reported rather than silently mangled by the shell -- `<channel>`
# unsubstituted is read by bash as an input redirection, and the command never runs.
def substitutions(channel: Path) -> dict[str, str]:
    return {"<channel>": str(channel)}


COMMANDISH = re.compile(
    r"(^|\n)\s{0,4}(grep|ls |find |git |unzip|mkdir|python|cd |cat |awk|for |echo |rm )")


def fences(doc: Path) -> list[tuple[str, str, int]]:
    """Every fenced block, in order, as (info string, body, starting line).

    Walked line by line rather than matched with a regex, and that is not fussiness.
    A pattern like `^```(?!sh$)\\w*\\n(.*?)^```` treats the CLOSING fence of an sh block
    as an opening one, swallows the prose after it, and reports a 160-line "block" that
    is three real blocks and the text between them. It was counting fence MARKERS in
    pairs of two without knowing which of each pair was an opener -- so every count of
    non-sh blocks this file has ever printed, including the 27 two reviews quoted, came
    from an instrument that could not tell an opening fence from a closing one.

    Fences alternate. Tracking that is four lines and it is the whole fix.
    """
    out, open_at, info, buf = [], None, "", []
    for n, ln in enumerate(doc.read_text(encoding="utf-8").splitlines(), 1):
        if ln.startswith("```"):
            if open_at is None:
                open_at, info, buf = n, ln[3:].strip(), []
            else:
                out.append((info, "\n".join(buf) + "\n", open_at))
                open_at = None
        elif open_at is not None:
            buf.append(ln)
    if open_at is not None:
        raise SystemExit(f"FATAL: {doc.name} has an unclosed fence opened at line {open_at}. "
                         f"Nothing in that file was checked.")
    return out


def extract(doc: Path) -> list[tuple[int, str]]:
    """Every fenced sh block, with the line it starts on."""
    return [(n, body) for info, body, n in fences(doc) if info == "sh"]


def units(block: str) -> list[str]:
    """One comparable claim per unit. Blocks separate their queries with a blank line."""
    return [u for u in re.split(r"\n\s*\n", block) if u.strip()]


def run(script: str, cwd: Path) -> tuple[int, str, str]:
    r = subprocess.run(["bash", "-c", script], cwd=cwd, capture_output=True,
                       text=True, timeout=30)
    return r.returncode, r.stdout.strip(), r.stderr.strip()


# ---------------------------------------------------------------------------
# The fixture, built by the documented writer
# ---------------------------------------------------------------------------

WRITER = ROOT / "assets/gtd-msg.sh"


def write_message(ch: Path, tmp: Path, author: str, frm: str, to: str,
                  re_: str, state: str, slug: str, extra: str = "") -> str:
    """Create one fixture message BY RUNNING THE SHIPPED WRITER.

    This used to extract a fenced block out of `message-template.md`, because the writer
    was a block the agent retyped. It is a script now, and running it is strictly better:
    the fixture is produced by the exact artefact that ships, guards included.

    Two properties come free from invoking it directly rather than through `bash`:
    **the executable bit is checked** (a bundle that loses it fails here rather than in
    somebody's project), and so are the four refusals, since a writer that stopped
    enforcing them would still build a fixture and the queries would silently drift.
    """
    if not WRITER.is_file():
        raise SystemExit(f"FATAL: {WRITER.name} is gone. The fixture is built by the "
                         f"shipped writer, so nothing was checked.")
    cmd = (f'"{WRITER}" --channel "{ch}" --author {author} --from {frm} --to {to} '
           f'--re {re_} --state {state} --slug {slug} {extra}<<\'EOF\'\n'
           f'## body\nbody\n\n## What you have to do\nnothing\n'
           f'\n## Options and their cost\nnone\n\n## What stops\nnothing\n'
           f'\n## Evidence\nMANIFEST\nEOF\n')
    rc, out, err = run(cmd, tmp)
    if rc != 0 or not out:
        raise SystemExit(f"FATAL: the shipped writer failed ({rc}): {err or out}")
    return Path(out.splitlines()[-1]).name


def build_fixture(ch: Path, tmp: Path) -> dict[str, set[str]]:
    """Ten messages written by the documented command. Ground truth by construction."""
    ch.mkdir(parents=True, exist_ok=True)
    # The channel carries copies of two documents, exactly as SKILL.md instructs -- and
    # that is not incidental: those copies contain the format description, so a loosely
    # anchored query matches the instrument it runs over. The fixture reproduces that.
    for a in ("assets/exchange-README.md", "assets/message-template.md"):
        shutil.copy(ROOT / a, ch / ("README.md" if "exchange" in a else "message-template.md"))

    def write(author, frm, to, re_, state, slug, extra="") -> str:
        return write_message(ch, tmp, author, frm, to, re_, state, slug, extra)

    q1 = write("cowork", "cowork", "code", "-", "open", "q-one")
    q2 = write("cowork", "cowork", "code", "-", "open", "q-two")
    q3 = write("code", "code", "cowork", "-", "open", "q-three")
    q4 = write("code", "code", "cowork", "-", "open", "q-four-answered")
    c1 = write("cowork", "cowork", "code", q4, "consensus", "answer-to-q-four",
               '--lands-in MANIFEST ')
    # Escalations are addressed to the person: that is what escalating means here.
    e1 = write("code", "code", "owner", "-", "escalated", "esc-live", "--fyi --action none ")
    e2 = write("code", "code", "owner", "-", "escalated", "esc-closed", "--fyi --action none ")
    d1 = write("cowork", "owner", "both", e2, "settled", "decision-closing-esc",
               '--closes body --fyi --action none ')
    # Was `settled` with `re: -` until the writer stopped allowing it, and that refusal is
    # M19: twenty-three real decisions were recorded exactly this way, and every one was
    # invisible because the derivation excludes `settled`. A decision that opens work is
    # `open`, addressed to whoever acts -- so the fixture cannot express the old shape either.
    d2 = write("code", "owner", "both", "-", "open", "decision-standalone", "--fyi --action none ")
    # `re:` pointing at the other agent, because that is what the protocol requires and
    # the shipped writer now refuses without it. The hand-written block this fixture used
    # to be built from let an invalid `consensus` through for months, and nothing noticed
    # until the writer became a script that enforces its own rule.
    c2 = write("cowork", "cowork", "code", q3, "consensus", "note", '--lands-in MANIFEST ')
    # The common case, and the one the fixture was missing: an agent has prepared
    # something and needs the person. `to: owner` + `state: open`, exactly as the
    # bootstrap prompts prescribe. A day of real use produced three of these and zero
    # escalations, and the documented person-facing query looked only at escalations.
    # The one thing in the fixture that genuinely waits on the person, so it is the one
    # that carries --decide and --blocks. Everything else addressed to them is --fyi.
    w1 = write("code", "code", "owner", "-", "open", "block-awaiting-you",
               '--decide "run it or not" --blocks "the migration" ')
    # Agreed with the person and not carried out. Without this message the fixture cannot
    # tell the old person-facing derivation from the new one -- both filtered on
    # `open|escalated`, both returned {e1, w1}, and a checker that returns the same answer
    # for a correct and an incorrect query is not checking that query at all. It shipped
    # blind through the round that fixed exactly this defect elsewhere.
    w2 = write("cowork", "cowork", "owner", w1, "consensus", "agreed-with-you-not-done",
               '--lands-in MANIFEST --fyi --action none ')

    return {
        # d2 belongs here now, and its arrival IS M19: the same decision written the
        # old way was `settled`, and every query in this method excluded it.
        "open": {q1, q2, d2},                           # q3, q4 and now w1 are answered by a later re:
        "escalated": {e1},                          # e2 is closed by an owner decision
        # Addressed to the person and not closed. w1 is answered but NOT settled, and being
        # answered is not being done -- that distinction is the whole point of this row.
        "waiting": {e1, w1, w2, d2},
        "owner": {d1, d2},
        "consensus": {c1, c2},
        # Messages only. The queries use `2*.md` and not `*.md`, because the channel
        # carries its own README and message template and a bare glob counts those two
        # as messages -- which is what "EXAMINED: 13 messages" said when there were 11.
        "listing": {p.name for p in ch.iterdir() if p.name.startswith("2")},
    }


# ---------------------------------------------------------------------------
# Classification and comparison
# ---------------------------------------------------------------------------

# A channel query greps a front-matter key, or lists the channel. Deliberately narrow:
# the writer block in message-template.md contains `re: $RE` inside its heredoc, and a
# looser test read that as a query with no ground truth -- an instrument reporting a
# finding about the very command it depends on.
KEY_GREP = re.compile(r"grep [^\n]*'\^(state|from|re|to): ?\+?")
# `ls -1` optionally narrowed to `2*.md`. The narrowing was added to stop the channel's own
# README and message template being counted as messages, and it silently dropped both listing
# queries out of this checker's scope -- two fewer comparisons, and an OK. A pattern that
# recognises one spelling of a query stops recognising it the day somebody improves the query.
BARE_LS = re.compile(r"(^|\n)\s*ls -1( +2\*\.md)?(\s*\||\s*$)")


def is_channel_query(unit: str) -> bool:
    return bool(KEY_GREP.search(unit) or BARE_LS.search(unit))


def classify(unit: str) -> str | None:
    """Which ground truth this query claims to produce. Order matters: the escalation
    query mentions `from: owner` in its own derivation, so it must be tested first.

    Comments are stripped before matching. They used to count, so a perfectly correct
    owner query carrying `# decisions; some close a state: escalated message` -- a comment
    the documentation elsewhere writes as prose -- was compared against the escalation
    ground truth and reported as broken. The ordering reason above is about two greps
    colliding; extending it to prose is what made it fire on a sentence.
    """
    unit = re.sub(r"#.*$", "", unit, flags=re.M)
    if "to: +(owner|both)" in unit or "to: +owner" in unit:
        return "waiting"
    if "state: +escalated" in unit or "state: escalated" in unit:
        return "escalated"
    if "state: +open" in unit or "state: open" in unit:
        return "open"
    if "state: +consensus" in unit or "state: consensus" in unit:
        return "consensus"
    if "from: +owner" in unit or "from: owner" in unit:
        return "owner"
    if BARE_LS.search(unit):
        return "listing"
    return None


def check(ch: Path, expect: dict[str, set[str]],
          docs: list[Path] | None = None) -> tuple[list[str], dict[str, int]]:
    """Run the documented channel queries and compare filename SETS, one per query."""
    findings: list[str] = []
    scope = {"compared": 0, "skipped": 0, "unfenced": 0, "unfenced_with_commands": 0}
    subs = substitutions(ch)

    if docs is None:
        docs = sorted({p for g in DOC_GLOBS for p in ROOT.glob(g)})

    for p in docs:
        rel = p.relative_to(ROOT) if p.is_relative_to(ROOT) else p.name
        # Commands living in a fence that is not ```sh are invisible to extract(). The two
        # bootstrap prompts are entirely that shape, and they hold the commands the agents
        # actually run first. Counting them is not checking them -- but an unexamined
        # region that nobody counts is the declared-scope defect this file exists to avoid.
        #
        # And it counts the ones that CARRY A COMMAND, not every fence. Counting fences
        # said "27 unexamined blocks" when 21 of them were front-matter and message
        # samples: a declared scope four and a half times the size of the thing it stood
        # for, which is this file's own section 1 defect -- a scope printed accurately and
        # measuring the wrong object.
        for info, body, _n in fences(p):
            if info == "sh":
                continue
            scope["unfenced"] += 1
            if COMMANDISH.search(body):
                scope["unfenced_with_commands"] += 1
        for line, block in extract(p):
            for unit in units(block):
                if not is_channel_query(unit):
                    scope["skipped"] += 1
                    continue

                script = unit
                for k, v in subs.items():
                    script = script.replace(k, v)
                left = re.findall(r"<[a-z][a-z ]*>", script)
                if left:
                    findings.append(
                        f"{rel}:{line} carries a placeholder this checker cannot "
                        f"substitute: {left[0]} -- the command as written does not run")
                    continue

                want = classify(unit)
                if want is None:
                    findings.append(
                        f"{rel}:{line} queries the channel and this checker has no "
                        f"ground truth for it. Add one, or the scope grows and the "
                        f"judged scope does not")
                    continue

                scope["compared"] += 1
                rc, out, err = run(script, ch)
                # exit 1 from `grep` means "matched nothing", which is a RESULT, not a
                # broken command -- and it is the archetypal symptom of the defect this
                # file exists to catch. The guard used to fire on it, so the one case
                # where the set difference is most informative was the one case it was
                # never computed: a query matching nothing got reported as a syntax
                # problem and the reader was sent to look in the wrong place.
                # Above 1 is a real failure, and so is the placeholder case handled above.
                if rc > 1:
                    findings.append(
                        f"{rel}:{line} did not run (exit {rc}) -- "
                        f"{err.splitlines()[0] if err else 'no message'}")
                    continue

                got = {Path(x.strip()).name for x in out.splitlines()
                       if x.strip().endswith(".md")}
                if got != expect[want]:
                    missing = sorted(expect[want] - got)
                    extra = sorted(got - expect[want])
                    detail = []
                    if missing:
                        detail.append(f"missing {missing}")
                    if extra:
                        detail.append(f"unexpected {extra}")
                    findings.append(
                        f"{rel}:{line} ({want}) returned {len(got)} of "
                        f"{len(expect[want])} -- " + "; ".join(detail))

    if scope["compared"] == 0:
        findings.append("BLIND: no channel query was compared. This is not a pass.")
    return findings, scope


# ---------------------------------------------------------------------------
# The self-test, which must not depend on the documents being correct
# ---------------------------------------------------------------------------

# Canonical queries, held here rather than read from the documentation. A broken
# document must not be able to disable the instrument's proof of itself.
CANON = """\
# open
answered=$(grep -hE '^re: +' *.md | awk '{print $2}' | grep -v '^-$' | sort -u)
for f in $(grep -lE '^state: +open$' *.md); do
  echo "$answered" | grep -qx "$(basename "$f")" || echo "$f"
done

# escalated
closed=$(grep -lE '^from: +owner$' *.md | xargs -r grep -hE '^re: +' | awk '{print $2}' | sort -u)
for f in $(grep -lE '^state: +escalated$' *.md); do
  echo "$closed" | grep -qx "$(basename "$f")" || echo "$f"
done

grep -lE '^from: +owner$' *.md
"""


def self_test(ch: Path, expect: dict[str, set[str]], tmp: Path) -> bool:
    """Every mutation must ADD a finding naming what was mutated.

    Set difference, not booleans. The previous version returned `ok and not ok2`, which
    printed a pass whenever anything at all was failing -- a positive signal true by
    pre-existing failure, which is the same defect as a total matching by coincidence.
    """
    canon = tmp / "canon.md"
    canon.write_text(f"# canonical\n\n```sh\n{CANON}```\n", encoding="utf-8")

    base, scope = check(ch, expect, docs=[canon])
    if scope["compared"] != 3:
        print(f"  FAIL the self-test's own queries did not all run "
              f"({scope['compared']} of 3 compared)")
        return False
    if base:
        print("  FAIL the canonical queries disagree with the fixture, so no mutation "
              "below can be attributed:")
        for f in base:
            print(f"       {f}")
        return False

    def plant(frm, to, re_, state, slug, extra="") -> None:
        write_message(ch, tmp, "code", frm, to, re_, state, slug, extra)

    mutations = [
        ("an extra decision by the person", "owner",
         lambda: plant("owner", "both", "-", "open", "mutant-decision", "--fyi --action none ")),
        ("a new unanswered question", "open",
         lambda: plant("code", "cowork", "-", "open", "mutant-question")),
        ("a new live escalation", "escalated",
         lambda: plant("code", "cowork", "-", "escalated", "mutant-escalation")),
    ]

    ok = True
    for name, key, mutate in mutations:
        before = set(check(ch, expect, docs=[canon])[0])
        mutate()
        after = set(check(ch, expect, docs=[canon])[0])
        new = [f for f in after - before if f"({key})" in f]
        print(f"  {'ok  ' if new else 'FAIL'} notices {name}")
        ok = ok and bool(new)

    return ok


# ---------------------------------------------------------------------------
# The other executable block this repository publishes
# ---------------------------------------------------------------------------

def check_floor_template(tmp: Path) -> tuple[list[str], int]:
    """The floor log template has to be able to hold what the procedure produces.

    This file declared, run after run, that it examined channel queries and not the
    other blocks -- and the comment above DOC_GLOBS said in so many words that
    `floor-mechanism.md` "carries two runnable blocks". It was discovered, counted
    among the unexamined, and never run.

    Then the instruction "run each request twice" was added and the template that
    records the results was not, in the same commit. Ten results, five slots, and it
    shipped. **The honest line naming what this file did not look at turned out to be
    a prediction**, which is the strongest argument there is for declaring scope: the
    gap was visible in every run for weeks before anything fell into it.

    The invariant below cannot be satisfied by accident. Both sides are parsed from
    the document -- the number of requests from the table that describes them, the
    number of shapes from the sentence that doubles them, and the number of blanks
    from actually running the template -- so a change to either side that forgets the
    other fails here rather than in somebody's log six months later.
    """
    doc_path = ROOT / "reference/floor-mechanism.md"
    doc = doc_path.read_text(encoding="utf-8")

    rows = re.findall(r"^\| (\d+) \| (.+?) \|", doc, re.M)
    if not rows:
        return ([f"{doc_path.name}: no numbered request table found. Nothing was checked "
                 f"about the floor template, which is not a pass."], 0)
    requests = [r for r in rows if not r[1].strip().lstrip("*").startswith("Nothing")]
    non_requests = len(rows) - len(requests)
    shapes = 2 if "Run each request twice" in doc else 1
    expected = len(requests) * shapes + non_requests

    block = next((b for _, b in extract(doc_path) if "floor-verification.log" in b), None)
    if block is None:
        return ([f"{doc_path.name}: the log template block is gone. The procedure tells "
                 f"the person to write a log and there is nothing to write it with."], 0)

    work = tmp / "floor"
    work.mkdir(parents=True, exist_ok=True)
    rc, out, err = run(block, work)
    if rc != 0 or "LOG: " not in out:
        return ([f"{doc_path.name}: the log template did not run (exit {rc}) -- "
                 f"{(err or out).splitlines()[0] if (err or out) else 'no message'}"], 0)

    log = work / out.split("LOG: ")[-1].strip()
    blanks = sum(1 for ln in log.read_text(encoding="utf-8").splitlines()
                 if ln.rstrip().endswith("outcome:"))
    if blanks != expected:
        return ([f"{doc_path.name}: the template leaves {blanks} outcomes to fill and the "
                 f"procedure produces {expected} ({len(requests)} requests x {shapes} "
                 f"shape(s) + {non_requests} not a request). One of the two was changed "
                 f"without the other."], 1)
    return ([], 1)


def main() -> int:
    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        ch = tmp / "exchange"
        expect = build_fixture(ch, tmp)

        if "--self-test" in sys.argv:
            passed = self_test(ch, expect, tmp)
            print(f"\nEXAMINED: 3 mutations of a {len(expect['listing'])}-file fixture, "
                  f"against canonical queries held in this file")
            return 0 if passed else 1

        findings, scope = check(ch, expect)
        floor, floor_checked = check_floor_template(tmp)
        findings += floor
        for f in findings:
            print(f"  FAIL {f}")
        print(f"\nEXAMINED: {scope['compared']} channel queries and {floor_checked} floor "
              f"log template compared against a "
              f"{len(expect['listing'])}-file fixture built by the shipped "
              f"writer, assets/gtd-msg.sh")
        print(f"NOT EXAMINED: {scope['skipped']} units that are not channel queries, and "
              f"{scope['unfenced_with_commands']} of {scope['unfenced']} blocks in a fence "
              f"other than ```sh carry commands -- including both bootstrap prompts, which "
              f"are the first thing each agent runs and which this checker never does")
        print("OK" if not findings
              else "COMMANDS IN THE DOCUMENTATION DO NOT DO WHAT THEY CLAIM")
        return 0 if not findings else 1


if __name__ == "__main__":
    sys.exit(main())
