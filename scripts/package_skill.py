#!/usr/bin/env python3
"""Build the .skill bundle, and refuse to produce one whose SHAPE is wrong.

    python scripts/package_skill.py              build and check
    python scripts/package_skill.py --self-test  prove the shape checks fail when they should

Why this file replaced three shell steps, and it is a defect found by installing:

    The bundle was built with `zip -qr out.skill dir`. Its CONTENT was correct -- the
    official validator said "Skill is valid!" over the staged tree -- and it still failed
    to install. The difference was the archive itself:

        built by zip -r     16 entries, 3 of them DIRECTORY entries, mixed compression
        the reference impl  13 entries, files only, all deflated

    Every check in this repository looked at what the bundle CONTAINED. Nothing looked at
    what the bundle WAS. `verification.md` §9 names this exactly: a check that partitions
    on two conditions has four regions, and the region nobody wrote a test for is the one
    that bites. Here the two conditions were "the right files" and "a well-formed archive",
    and only the first had a check.

    And `zip -r` carried a second defect of the same family: it UPDATES an existing archive
    instead of replacing it, so a stale file from an earlier build survived into a freshly
    staged bundle and passed. Writing the archive from Python removes both at the source --
    there is no pre-existing object to merge into, and no directory entries to emit.

The shape rules below were derived from what the reference packager in `skill-creator`
PRODUCES -- it has no shape checks of its own, it simply writes files only and deflates
them. That is a different act from reading its rules, and the difference matters:
**the reference packager is not the gate.** The installer is, and it enforces at least one
rule the reference validator does not have. Saying "mirrors the reference" is fair; saying
"therefore this will be accepted" is the claim `verification.md` section 11 forbids, and
this docstring made it until round 4 pointed at it.
"""
from __future__ import annotations

import re
import sys
import warnings
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

sys.path.insert(0, str(ROOT / "scripts"))
from validate_skill import read_manifest, validate           # noqa: E402


def skill_name() -> str:
    """The archive root, read from SKILL.md rather than kept as a constant here.

    It used to be `NAME = "gtd-with-agents"`, and `check_shape` validated the archive root
    against it -- so the one property tying the artefact to the skill's identity compared a
    constant against itself. Changing the constant produced a bundle with the wrong root,
    the wrong filename, and every check green.

    The identity has one source now. A rename that misses this file cannot happen, because
    there is nothing here to miss.
    """
    m = re.match(r"^---\n(.*?)\n---", (ROOT / "SKILL.md").read_text(encoding="utf-8"), re.S)
    if not m:
        raise SystemExit("FATAL: SKILL.md has no frontmatter, so the bundle has no name.")
    n = re.search(r"^name:\s*(\S+)\s*$", m.group(1), re.M)
    if not n:
        raise SystemExit("FATAL: SKILL.md frontmatter has no name, so the bundle has no name.")
    return n.group(1)


NAME = skill_name()

# Filled by build(); read by check_shape(). See the comment in build().
WRITER_WARNINGS: list[str] = []


def build(manifest: list[str], out: Path, extra: dict[str, str] | None = None,
          keep_dir_entries: bool = False, stored: bool = False,
          duplicate: str | None = None) -> Path:
    """Write the archive. The last three arguments exist only for the self-test."""
    if out.exists():
        out.unlink()          # never merge into an existing archive
    comp = zipfile.ZIP_STORED if stored else zipfile.ZIP_DEFLATED
    if duplicate:
        manifest = manifest + [duplicate]
    # The writer's own warnings are evidence, not noise. `zipfile` raises a UserWarning on
    # a duplicate entry, and the first version of this file let it print to stderr and
    # reported BUILT anyway -- a library telling the truth into a channel nobody read.
    with warnings.catch_warnings(record=True) as caught:
        warnings.simplefilter("always")
        _write(out, comp, manifest, extra, keep_dir_entries)
    WRITER_WARNINGS[:] = [str(w.message) for w in caught]
    return out


def _write(out: Path, comp: int, manifest: list[str],
           extra: dict[str, str] | None, keep_dir_entries: bool) -> None:
    with zipfile.ZipFile(out, "w", comp) as z:
        if keep_dir_entries:
            z.writestr(f"{NAME}/", b"")
        for rel in manifest:
            src = ROOT / rel
            if not src.is_file():
                raise SystemExit(f"FATAL: manifest lists {rel} and it does not exist")
            z.write(src, f"{NAME}/{rel}")
        for rel, body in (extra or {}).items():
            z.writestr(f"{NAME}/{rel}", body)


def check_shape(archive: Path, manifest: list[str]) -> list[str]:
    """What the bundle IS, as opposed to what it contains."""
    problems = list(f"the zip writer warned and it was not read: {w}"
                    for w in WRITER_WARNINGS)
    with zipfile.ZipFile(archive) as z:
        infos = z.infolist()

        dirs = [i.filename for i in infos if i.filename.endswith("/")]
        if dirs:
            problems.append(
                f"{len(dirs)} directory entries: {dirs}. The reference packager writes "
                f"files only, and an installer walking entries reads these as files")

        undeflated = sorted({i.filename for i in infos
                             if i.compress_type != zipfile.ZIP_DEFLATED})
        if undeflated:
            problems.append(f"{len(undeflated)} entries not deflated: {undeflated[:3]}")

        # Duplicates first, and BEFORE any set is built. The previous version compared
        # `{i.filename for i in infos}` against a set of wanted names, so two entries with
        # the same name collapsed into one and the comparison could not see them -- while
        # `zipfile` itself raised a UserWarning about it that nobody read. A duplicate
        # manifest line produced a 14-entry archive and a green report.
        seen: dict[str, int] = {}
        for i in infos:
            seen[i.filename] = seen.get(i.filename, 0) + 1
        dupes = sorted(n for n, c in seen.items() if c > 1)
        if dupes:
            problems.append(f"{len(dupes)} name(s) appear more than once in the archive: "
                            f"{dupes}. A zip can hold two entries with one name; an "
                            f"installer reads one of them and nobody knows which")

        names = set(seen)
        want = {f"{NAME}/{m}" for m in manifest}
        if names != want:
            missing, extra = sorted(want - names), sorted(names - want)
            problems.append(f"entries are not exactly the manifest -- "
                            f"missing {missing}, unexpected {extra}")

        roots = {n.split("/")[0] for n in names}
        if roots != {NAME}:
            problems.append(f"archive root is {sorted(roots)}, expected ['{NAME}']")
    return problems


def check_content(archive: Path, manifest: list[str]) -> list[str]:
    """What the bundle contains, through the same validator the tree goes through."""
    with tempfile.TemporaryDirectory() as t:
        with zipfile.ZipFile(archive) as z:
            z.extractall(t)
        ok, report, seen = validate(Path(t) / NAME, manifest, exact=True)
        return [] if ok else [report]


def main() -> int:
    manifest = read_manifest(ROOT / "MANIFEST")

    if "--self-test" in sys.argv:
        # Every shape rule, seen to fail on the thing it names. The first of these is the
        # defect that shipped: it was built, validated, published and it did not install.
        cases = [
            ("a bundle carrying directory entries", dict(keep_dir_entries=True)),
            ("a bundle whose entries are stored, not deflated", dict(stored=True)),
            ("a bundle carrying a file the manifest does not list",
             dict(extra={"stale.md": "left over from an earlier build\n"})),
            ("a bundle with the same name twice", dict(duplicate="SKILL.md")),
        ]
        ok = True
        with tempfile.TemporaryDirectory() as t:
            for label, kw in cases:
                a = build(manifest, Path(t) / "m.skill", **kw)
                caught = bool(check_shape(a, manifest))
                print(f"  {'ok  ' if caught else 'FAIL'} rejects: {label}")
                ok &= caught
            a = build(manifest, Path(t) / "clean.skill")
            clean = not (check_shape(a, manifest) or check_content(a, manifest))
            print(f"  {'ok  ' if clean else 'FAIL'} accepts: a correctly shaped bundle")
            ok &= clean
        print(f"\nEXAMINED: {len(cases)} deliberate shape defects and one clean build, "
              f"over {len(manifest)} manifest paths")
        return 0 if ok else 1

    out = build(manifest, ROOT / f"{NAME}.skill")
    problems = check_shape(out, manifest) + check_content(out, manifest)
    for p in problems:
        print(f"  FAIL {p}")

    with zipfile.ZipFile(out) as z:
        n = len(z.infolist())
    print(f"\nEXAMINED: {n} archive entries against {len(manifest)} manifest paths, "
          f"for shape (files only, deflated, exact) and for content (the validator, "
          f"--exact) -- {out.stat().st_size // 1024}K")
    print(f"BUILT {out.name}" if not problems else "THE BUNDLE IS THE WRONG SHAPE")
    return 0 if not problems else 1


if __name__ == "__main__":
    sys.exit(main())
