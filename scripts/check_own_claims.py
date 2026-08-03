#!/usr/bin/env python3
"""Check the claims this repository makes ABOUT ITSELF, not the artefact it produces.

    python scripts/check_own_claims.py             check
    python scripts/check_own_claims.py --self-test prove each claim fails when it should

Why this file exists, and it is the sharpest thing the fifth review said:

    Of the three objectives this method declares, the pipeline checked ZERO.
    Of the four closed decisions, ONE -- installability, tested hard, twice.

    Everything here builds instruments for the ARTEFACT. Nothing built one for the
    repository's own statements. And the three defects that cost the most in that
    review were all of one kind: a number written in two files that stopped agreeing,
    a value shape enforced in three documents out of four, an example that models the
    opposite of what the paragraph above it teaches.

    Every one of those is a four-line grep of exactly the same shape as the MANIFEST
    completeness step that has existed here since round 2. The repository knew how to
    build this instrument and had only ever pointed it outwards.

The rule that follows, and it is the general one:

    A DOCUMENT THAT STATES A RULE AND A DOCUMENT THAT FOLLOWS IT ARE TWO LISTS, AND
    TWO LISTS DRIFT. The drift is invisible because each stays internally consistent.

That is the same sentence MANIFEST carries at the top, applied to prose instead of to
files. Each claim below is one place this repository says something about itself; each
is checked against every shipped document; and each is proven by breaking it.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Only what ships. The README is included because it is the face of the project and
# two of these defects lived there; review artefacts are not, and never were.
def shipped() -> list[Path]:
    m = [ln.strip() for ln in (ROOT / "MANIFEST").read_text().splitlines()
         if ln.strip() and not ln.startswith("#")]
    return [ROOT / p for p in m if p.endswith(".md")] + [ROOT / "README.md"]


# The two files that are allowed to assume a tool or a repository, because they say so
# in their own first lines. Everything else is the core, and the README claims the core
# works on a thesis, a research project or a campaign.
ANNEXES = {"git-annex.md", "floor-mechanism.md"}


def claim_head_prefix(docs: list[Path]) -> list[str]:
    """Every `head:` example carries its kind.

    `protocol.md` teaches that the prefix is what separates an answer whose staleness
    can be checked from one whose cannot -- and the README's own two worked examples
    modelled it without one. An example is what gets copied; the paragraph is not.
    """
    bad = []
    for p in docs:
        for n, ln in enumerate(p.read_text().splitlines(), 1):
            m = re.match(r"^\s*head:\s*(\S+)", ln)
            # `<...>` is a placeholder and `$VAR` is the writer substituting one; both
            # are the shape being taught rather than an example of a value.
            if m and not re.match(r"^(sha:|clock:|<|\$)", m.group(1)):
                bad.append(f"{p.name}:{n} head: example has no kind prefix -- {m.group(1)!r}")
    return bad


def claim_four_levels(docs: list[Path]) -> list[str]:
    """Anywhere the delegation levels are enumerated, all four appear.

    Three rounds running, the fourth level reached some of the documents that list
    them and not others -- and the questionnaire is the one place where a missing
    option means the person is not offered a choice the method promises them.
    """
    bad = []
    for p in docs:
        t = p.read_text()
        if "DELEGATED" in t and "CONSENSUS" in t and "NOT APPLICABLE" not in t:
            bad.append(f"{p.name} enumerates the levels and omits NOT APPLICABLE")
    return bad


def claim_reason_is_part_of_the_value(docs: list[Path]) -> list[str]:
    """`NOT APPLICABLE` never appears bare where a value is being shown.

    The rule says the reason is part of the value and not a note beside it, precisely
    so that an empty reason is malformed rather than missing. A document that states
    the rule and then prints the bare value teaches the bare value.
    """
    bad = []
    for p in docs:
        for n, ln in enumerate(p.read_text().splitlines(), 1):
            # Only where a VALUE is being SHOWN: the label cell of a table row, or the
            # inside of a `<...>` placeholder. Prose naming the level -- including the
            # sentence explaining why a bare one is wrong -- is naming it, not printing
            # it, and flagging that would make the instrument fire on its own rule.
            plain = ln.replace("*", "").replace("`", "")
            spots = []
            if plain.lstrip().startswith("|"):
                spots.append(plain.split("|")[1])
            spots += re.findall(r"<([^>]*)>", plain)
            for s in spots:
                for m in re.finditer(r"NOT APPLICABLE(.{0,14})", s):
                    if not re.match(r"\s*(—|--)\s*\S", m.group(1)):
                        bad.append(f"{p.name}:{n} a value is shown as bare NOT APPLICABLE, "
                                   f"with no reason attached")
    return bad


def claim_counts_agree(docs: list[Path]) -> list[str]:
    """A quantity written in prose in more than one file says the same thing everywhere.

    `SKILL.md` said "the four requests that test them" and, six lines later, "one of
    the five test requests". Both were about the same procedure. The file that says it
    twice is the file an agent executes during setup.
    """
    words = {"three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8}
    counted: dict[str, set[tuple[int, str]]] = {}
    for p in docs:
        for n, ln in enumerate(p.read_text().splitlines(), 1):
            for m in re.finditer(r"\b(three|four|five|six|seven|eight)\b[^.\n]{0,24}?"
                                 r"\b(requests|levels|classes|objectives|goals)\b", ln):
                counted.setdefault(m.group(2), set()).add((words[m.group(1)], f"{p.name}:{n}"))
    bad = []
    for noun, hits in counted.items():
        values = {v for v, _ in hits}
        if len(values) > 1:
            where = ", ".join(f"{v} at {w}" for v, w in sorted(hits))
            bad.append(f"the number of {noun} disagrees between files -- {where}")
    return bad


def claim_core_is_agnostic(docs: list[Path]) -> list[str]:
    """The daily triage works on a project with no repository.

    The README states it outright: *"everything else works on a thesis, a research
    project or a campaign as readily as on a codebase."* The traffic-light table was
    written end to end in version-control vocabulary, is used every day, and was not
    in the annex -- so the sentence was false about the one instrument people touch
    most. This checks the sentence rather than trusting it.
    """
    repo_only = re.compile(r"\b(commit|branch|merge|rebase|checkout|staged|unstaged|"
                           r"force-push|git)\b", re.I)
    bad = []
    for p in docs:
        if p.name in ANNEXES or p.name == "README.md":
            continue
        t = p.read_text()
        i = t.find("## Part 3")
        if i < 0:
            continue
        section = t[i:t.find("\n## ", i + 1)]
        for n, ln in enumerate(section.splitlines(), t[:i].count("\n") + 1):
            # A line that names the annex is declaring the boundary, not crossing it.
            # That is the one form of repository vocabulary the core is supposed to have.
            if "git-annex.md" in ln:
                continue
            if repo_only.search(ln):
                bad.append(f"{p.name}:{n} the daily triage assumes a repository -- {ln.strip()[:60]}")
    return bad


def claim_queries_declare_scope(docs: list[Path]) -> list[str]:
    """Every shipped executable declares what it examined, and refuses over nothing.

    This claim used to scan DOCUMENTS for a hand-written scope guard, because the channel
    queries lived in prose. They are scripts now, so the claim follows the behaviour: a
    document cannot fail this any more, and checking documents for it would have gone
    quietly vacuous -- a claim that cannot fail is the shape this file exists to catch.

    The tree comes from `docs`, never from ROOT. Reading ROOT here made the claim blind to
    the self-test's mutated copy: it reported on the real repository every time, so the
    mutation "changed nothing" and the claim proved itself untestable. An instrument
    pointed at the wrong object, inside the file that checks for exactly that.
    """
    root = next((d.parent for d in docs if d.name == "SKILL.md"), ROOT)
    bad = []
    shs = sorted((root / "assets").glob("*.sh"))
    if not shs:
        return ["no shipped executables found: this claim examined nothing"]
    for sh in shs:
        t = sh.read_text()
        if "EXAMINED" not in t:
            bad.append(f"{sh.name} never says what it examined")
        if "BLIND" not in t and "not a pass" not in t:
            bad.append(f"{sh.name} has no blind state -- nothing to look at reads as nothing to find")
    return bad


CLAIMS = [
    ("every head: example carries its kind", claim_head_prefix),
    ("every level enumeration lists all four", claim_four_levels),
    ("NOT APPLICABLE always carries its reason", claim_reason_is_part_of_the_value),
    ("a quantity written twice agrees with itself", claim_counts_agree),
    ("the daily triage needs no repository", claim_core_is_agnostic),
    ("channel queries refuse to answer over nothing", claim_queries_declare_scope),
]


def run(docs: list[Path]) -> list[str]:
    out = []
    for name, fn in CLAIMS:
        out += [f"[{name}] {f}" for f in fn(docs)]
    return out


def self_test() -> int:
    """Each claim, broken on purpose against a temporary copy, must be the one that fires."""
    import shutil, tempfile
    breaks = [
        ("every head: example carries its kind",
         "README.md", lambda t: t.replace("head: sha:9f3c1a2", "head: 9f3c1a2", 1)),
        ("every level enumeration lists all four",
         "SKILL.md", lambda t: t.replace("NOT APPLICABLE", "N/A")),
        ("NOT APPLICABLE always carries its reason",
         "reference/approvals.md", lambda t: t.replace("NOT APPLICABLE — `<reason>`",
                                                       "NOT APPLICABLE", 1)),
        ("a quantity written twice agrees with itself",
         "SKILL.md", lambda t: t.replace("five test requests", "four test requests", 1)),
        ("the daily triage needs no repository",
         "reference/approvals.md", lambda t: t.replace("## Part 3 · The daily triage",
             "## Part 3 · The daily triage\n\nSaving a commit on a branch is amber.", 1)),
        ("channel queries refuse to answer over nothing",
         "assets/channel-status.sh", lambda t: t.replace("BLIND", "quiet").replace(
             "not a pass", "fine")),
    ]
    ok = True
    with tempfile.TemporaryDirectory() as tmp:
        for name, target, mutate in breaks:
            copy = Path(tmp) / "c"
            if copy.exists():
                shutil.rmtree(copy)
            shutil.copytree(ROOT, copy, ignore=shutil.ignore_patterns(".git", ".runs"))
            p = copy / target
            before = p.read_text()
            p.write_text(mutate(before))
            if p.read_text() == before:
                print(f"  FAIL the mutation for {name!r} changed nothing -- it is not being tested")
                ok = False
                continue
            docs = [copy / x.relative_to(ROOT) for x in shipped()]
            fired = {f.split("]")[0][1:] for f in run(docs)}
            caught = name in fired
            print(f"  {'ok  ' if caught else 'FAIL'} notices: {name}")
            ok &= caught
        # And the polarity nobody runs.
        clean = not run(shipped())
        print(f"  {'ok  ' if clean else 'FAIL'} accepts: the repository as it stands")
        ok &= clean
    print(f"\nEXAMINED: {len(breaks)} claims, each broken on purpose, over "
          f"{len(shipped())} shipped documents")
    return 0 if ok else 1


def main() -> int:
    if "--self-test" in sys.argv:
        return self_test()
    docs = shipped()
    findings = run(docs)
    for f in findings:
        print(f"  FAIL {f}")
    print(f"\nEXAMINED: {len(CLAIMS)} claims this repository makes about itself, over "
          f"{len(docs)} shipped documents")
    print("OK" if not findings else "THE REPOSITORY DOES NOT DO WHAT IT SAYS IT DOES")
    return 0 if not findings else 1


if __name__ == "__main__":
    sys.exit(main())
