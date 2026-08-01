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

The shape rules below mirror the reference packager in `skill-creator`, which is the thing
that has to accept this file. They are not invented here; they were read from it.
"""
from __future__ import annotations

import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAME = "gtd-with-agents"

sys.path.insert(0, str(ROOT / "scripts"))
from validate_skill import read_manifest, validate           # noqa: E402


def build(manifest: list[str], out: Path, extra: dict[str, str] | None = None,
          keep_dir_entries: bool = False, stored: bool = False) -> Path:
    """Write the archive. `extra`, `keep_dir_entries` and `stored` exist for the self-test."""
    if out.exists():
        out.unlink()          # never merge into an existing archive
    comp = zipfile.ZIP_STORED if stored else zipfile.ZIP_DEFLATED
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
    return out


def check_shape(archive: Path, manifest: list[str]) -> list[str]:
    """What the bundle IS, as opposed to what it contains."""
    problems = []
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

        names = {i.filename for i in infos}
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
