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


def extract(doc: Path) -> list[tuple[int, str]]:
    """Every fenced sh block, with the line it starts on."""
    out, text = [], doc.read_text(encoding="utf-8")
    for m in re.finditer(r"^```sh\n(.*?)^```", text, re.S | re.M):
        out.append((text[:m.start()].count("\n") + 1, m.group(1)))
    return out


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

def writer_block() -> str:
    """The block `assets/message-template.md` documents. Extracted, never reimplemented.

    This is the whole point. A second implementation agrees with whichever side its
    author had in mind and cannot see a drift between the writer and the queries --
    which is the defect that made this file necessary.
    """
    for _, b in extract(ROOT / "assets/message-template.md"):
        if 'cat > "$MSG"' in b:
            return b
    raise SystemExit("FATAL: assets/message-template.md no longer contains the writer "
                     "block this fixture is built from. Nothing was checked.")


def build_fixture(ch: Path, tmp: Path) -> dict[str, set[str]]:
    """Ten messages written by the documented command. Ground truth by construction."""
    ch.mkdir(parents=True, exist_ok=True)
    # The channel carries copies of two documents, exactly as SKILL.md instructs -- and
    # that is not incidental: those copies contain the format description, so a loosely
    # anchored query matches the instrument it runs over. The fixture reproduces that.
    for a in ("assets/exchange-README.md", "assets/message-template.md"):
        shutil.copy(ROOT / a, ch / ("README.md" if "exchange" in a else "message-template.md"))

    block = writer_block()

    def write(author, frm, to, re_, state, slug) -> str:
        b = block
        for var, val in (("CHANNEL", str(ch)), ("AUTHOR", author), ("FROM", frm),
                         ("TO", to), ("SLUG", slug), ("RE", re_), ("STATE", state)):
            b, n = re.subn(rf'^{var}="[^"]*"', f'{var}="{val}"', b, count=1, flags=re.M)
            if not n:
                raise SystemExit(f"FATAL: the documented writer no longer sets {var}. "
                                 f"The fixture cannot be built, so nothing was checked.")
        rc, out, err = run(b, tmp)
        if rc != 0 or not out:
            raise SystemExit(f"FATAL: the documented writer failed: {err or out}")
        return Path(out.splitlines()[-1]).name

    q1 = write("cowork", "cowork", "code", "-", "open", "q-one")
    q2 = write("cowork", "cowork", "code", "-", "open", "q-two")
    q3 = write("code", "code", "cowork", "-", "open", "q-three")
    q4 = write("code", "code", "cowork", "-", "open", "q-four-answered")
    c1 = write("cowork", "cowork", "code", q4, "consensus", "answer-to-q-four")
    e1 = write("code", "code", "cowork", "-", "escalated", "esc-live")
    e2 = write("code", "code", "cowork", "-", "escalated", "esc-closed")
    d1 = write("cowork", "owner", "both", e2, "settled", "decision-closing-esc")
    d2 = write("code", "owner", "both", "-", "settled", "decision-standalone")
    c2 = write("cowork", "cowork", "code", "-", "consensus", "note")

    return {
        "open": {q1, q2, q3},                       # q4 is answered by a later re:
        "escalated": {e1},                          # e2 is closed by an owner decision
        "owner": {d1, d2},
        "consensus": {c1, c2},
        "listing": {p.name for p in ch.iterdir()},  # messages plus the two copied docs
    }


# ---------------------------------------------------------------------------
# Classification and comparison
# ---------------------------------------------------------------------------

# A channel query greps a front-matter key, or lists the channel. Deliberately narrow:
# the writer block in message-template.md contains `re: $RE` inside its heredoc, and a
# looser test read that as a query with no ground truth -- an instrument reporting a
# finding about the very command it depends on.
KEY_GREP = re.compile(r"grep [^\n]*'\^(state|from|re): ?\+?")
BARE_LS = re.compile(r"(^|\n)\s*ls -1(\s*\||\s*$)")


def is_channel_query(unit: str) -> bool:
    return bool(KEY_GREP.search(unit) or BARE_LS.search(unit))


def classify(unit: str) -> str | None:
    """Which ground truth this query claims to produce. Order matters: the escalation
    query mentions `from: owner` in its own derivation, so it must be tested first."""
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
    scope = {"compared": 0, "skipped": 0, "unfenced": 0}
    subs = substitutions(ch)

    if docs is None:
        docs = sorted({p for g in DOC_GLOBS for p in ROOT.glob(g)})

    for p in docs:
        rel = p.relative_to(ROOT) if p.is_relative_to(ROOT) else p.name
        # Commands living in a fence that is not ```sh are invisible to extract(). The two
        # bootstrap prompts are entirely that shape, and they hold the commands the agents
        # actually run first. Counting them is not checking them -- but an unexamined
        # region that nobody counts is the declared-scope defect this file exists to avoid.
        scope["unfenced"] += len(re.findall(r"^```(?!sh$)\w*\n.*?^```",
                                            p.read_text(encoding="utf-8"), re.S | re.M))
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
                if rc != 0:
                    findings.append(
                        f"{rel}:{line} did not run (exit {rc}) -- {err.splitlines()[0] if err else 'no message'}")
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

    block = writer_block()

    def plant(frm, to, re_, state, slug) -> None:
        b = block
        for var, val in (("CHANNEL", str(ch)), ("AUTHOR", "code"), ("FROM", frm),
                         ("TO", to), ("SLUG", slug), ("RE", re_), ("STATE", state)):
            b = re.sub(rf'^{var}="[^"]*"', f'{var}="{val}"', b, count=1, flags=re.M)
        run(b, tmp)

    mutations = [
        ("an extra decision by the person", "owner",
         lambda: plant("owner", "both", "-", "settled", "mutant-decision")),
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
        for f in findings:
            print(f"  FAIL {f}")
        print(f"\nEXAMINED: {scope['compared']} channel queries compared against a "
              f"{len(expect['listing'])}-file fixture built by the writer "
              f"assets/message-template.md documents")
        print(f"NOT EXAMINED: {scope['skipped']} units that are not channel queries, and "
              f"{scope['unfenced']} blocks in a fence other than ```sh -- including both "
              f"bootstrap prompts, which carry commands this checker never runs")
        print("OK" if not findings
              else "COMMANDS IN THE DOCUMENTATION DO NOT DO WHAT THEY CLAIM")
        return 0 if not findings else 1


if __name__ == "__main__":
    sys.exit(main())
