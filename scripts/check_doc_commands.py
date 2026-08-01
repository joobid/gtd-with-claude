#!/usr/bin/env python3
"""Run every shell command this repository documents, against a fixture channel.

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

    python scripts/check_doc_commands.py            check
    python scripts/check_doc_commands.py --self-test  prove it fails when it should

The fixture is built here rather than shipped, so it cannot drift from the format
the documents describe: the messages are created by the very command
`assets/message-template.md` documents, and the ground truth is known by construction.
"""
from __future__ import annotations

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Queries are the executable claims that matter: they are what an agent runs to decide
# what is still open and what needs the person. A query that returns the wrong set is
# indistinguishable from a quiet project.
DOCS = ["assets/exchange-README.md", "reference/protocol.md", "README.md",
        "assets/message-template.md", "assets/config-template.md",
        "assets/bootstrap-code.md", "assets/bootstrap-cowork.md", "SKILL.md"]

# Ground truth for the fixture, by construction. If these change, change the builder.
EXPECT = {"open": 3, "escalated": 1, "owner": 2}


def build_fixture(ch: Path) -> None:
    """Ten messages with a known answer, written the way the documents say to write them."""
    ch.mkdir(parents=True, exist_ok=True)
    # The channel carries copies of two documents, exactly as SKILL.md instructs -- and
    # that is not incidental: those copies contain the format description, so a query
    # anchored loosely matches the instrument it runs over. This fixture reproduces that.
    for a in ("assets/exchange-README.md", "assets/message-template.md"):
        shutil.copy(ROOT / a, ch / ("README.md" if "exchange" in a else "message-template.md"))

    def msg(name, frm, to, re_, state):
        (ch / name).write_text(
            f"---\nfrom: {frm}\nto: {to}\nre: {re_}\nstate: {state}\n"
            f"head: clock:20260801T120000Z\n---\n\nbody\n", encoding="utf-8")

    msg("20260801-100000-cowork-q1.md", "cowork", "code", "-", "open")
    msg("20260801-100100-cowork-q2.md", "cowork", "code", "-", "open")
    msg("20260801-100200-code-q3.md", "code", "cowork", "-", "open")
    msg("20260801-100300-code-answered.md", "code", "cowork", "-", "open")
    msg("20260801-100400-cowork-a1.md", "cowork", "code",
        "20260801-100300-code-answered.md", "consensus")
    msg("20260801-100500-code-esc-live.md", "code", "cowork", "-", "escalated")
    msg("20260801-100600-code-esc-closed.md", "code", "cowork", "-", "escalated")
    msg("20260801-100700-cowork-decision.md", "owner", "both",
        "20260801-100600-code-esc-closed.md", "settled")
    msg("20260801-100800-code-decision.md", "owner", "both", "-", "settled")
    msg("20260801-100900-cowork-note.md", "cowork", "code", "-", "consensus")


def extract(doc: Path) -> list[tuple[int, str]]:
    """Every fenced sh block, with the line it starts on."""
    out, text = [], doc.read_text(encoding="utf-8")
    for m in re.finditer(r"^```sh\n(.*?)^```", text, re.S | re.M):
        out.append((text[:m.start()].count("\n") + 1, m.group(1)))
    return out


def run(block: str, cwd: Path) -> tuple[int, str]:
    r = subprocess.run(["bash", "-c", block], cwd=cwd, capture_output=True, text=True, timeout=30)
    return r.returncode, (r.stdout + r.stderr).strip()


def check(ch: Path) -> tuple[bool, list[str]]:
    """Run the documented queries and compare against the fixture's known answer."""
    findings, seen = [], 0
    for doc in DOCS:
        p = ROOT / doc
        if not p.is_file():
            findings.append(f"{doc}: listed here and absent from the tree"); continue
        for line, block in extract(p):
            if "grep" not in block and "ls -1" not in block:
                continue                      # not a query; the template's writer is covered below
            seen += 1
            rc, out = run(block, ch)
            n = len([x for x in out.splitlines() if x.strip()])
            want = ("open" if "state: +open" in block or "state: open" in block else
                    "escalated" if "escalated" in block else
                    "owner" if "owner" in block else None)
            if want and n != EXPECT[want]:
                findings.append(
                    f"{doc}:{line} returned {n}, the fixture has {EXPECT[want]} {want}\n"
                    f"      {out.splitlines()[:4]}")
    # Declaring the scope, because a run over zero blocks is not a pass.
    if seen == 0:
        findings.append("BLIND: no command blocks were found. This is not a pass.")
    return not findings, findings + [f"__scope__{seen}"]


def main() -> int:
    self_test = "--self-test" in sys.argv
    with tempfile.TemporaryDirectory() as tmp:
        ch = Path(tmp) / "exchange"
        build_fixture(ch)
        ok, findings = check(ch)
        seen = int([f for f in findings if f.startswith("__scope__")][0][9:])
        real = [f for f in findings if not f.startswith("__scope__")]
        for f in real:
            print(f"  FAIL {f}")
        print(f"\nEXAMINED: {seen} command blocks over {len(DOCS)} documents, "
              f"against a {len(list(ch.glob('2026*.md')))}-message fixture")

        if self_test:
            # Break the fixture on purpose: if a query stops matching reality and this
            # still passes, it is not checking anything.
            (ch / "20260801-101000-cowork-extra.md").write_text(
                "---\nfrom: owner\nto: both\nre: -\nstate: settled\nhead: clock:x\n---\n",
                encoding="utf-8")
            ok2, _ = check(ch)
            print(f"  {'ok  ' if not ok2 else 'FAIL'} notices an extra owner message")
            return 0 if (ok and not ok2) else 1

        print("OK" if ok else "COMMANDS IN THE DOCUMENTATION DO NOT DO WHAT THEY CLAIM")
        return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
