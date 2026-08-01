#!/usr/bin/env python3
"""Validate a skill directory against the constraints that reject an upload.

The point of this script is narrow and worth stating: a bundle that installs and then
does nothing is the failure mode this whole repository is about — a check whose failure
mode is to report success. So the release refuses to publish rather than publish
something it has not looked at.

Two habits from `reference/verification.md` are built in:

  - It declares WHAT IT EXAMINED, not just its verdict. "valid" and "valid, 5 rules over
    14 files" are different statements and the first is indistinguishable from not having
    looked.
  - It can be asked to prove itself with --self-test, which mutates a temporary copy in
    every way the rules forbid and fails unless each mutation is rejected. A verifier that
    has never been seen to fail is not evidence.

Usage:
    python scripts/validate_skill.py <skill-directory>
    python scripts/validate_skill.py <skill-directory> --self-test
"""
from __future__ import annotations

import re
import shutil
import sys
import tempfile
from pathlib import Path

try:
    import yaml
except ImportError:                                        # pragma: no cover
    sys.exit("FATAL: pyyaml is required (pip install pyyaml)")

# Straight from the published constraints. Kept as named constants so a change to any of
# them is a visible diff rather than a number buried in a condition.
MAX_NAME = 64
MAX_DESCRIPTION = 1024
MAX_COMPATIBILITY = 500
ALLOWED_KEYS = {"name", "description", "license", "allowed-tools", "metadata", "compatibility"}

# Words the installer refuses inside `name:`. "claude" is OBSERVED -- it is the error that
# rejected v0.1.2. The others are inferred from the same policy and have not been seen to
# fire, which is stated rather than implied: an unverified entry costs a rename, a missing
# one costs a release.
RESERVED_IN_NAME = {"claude", "anthropic"}

# Mirrors what packaging excludes, so a SKILL.md that never ships does not count.
EXCLUDED_ANYWHERE = {"__pycache__", "node_modules"}
EXCLUDED_AT_ROOT = {"evals"}


def _ships(rel: Path) -> bool:
    parts = rel.parts[:-1]
    if any(p in EXCLUDED_ANYWHERE for p in parts):
        return False
    return not (parts and parts[0] in EXCLUDED_AT_ROOT)


def read_manifest(path: Path) -> list[str]:
    return [
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]


# Directories that exist around a skill and are not part of one. Counting them inflates
# the declared scope with objects no rule ever looks at.
NOT_OURS = {".git", ".runs", "__pycache__", "build", "verify"}


def validate(root: Path, manifest: list[str] | None = None,
             exact: bool = False) -> tuple[bool, str, dict]:
    """Return (ok, message, what_was_examined)."""
    seen = {"files": 0, "rules": 0, "skill_md": 0, "manifest": len(manifest or [])}

    # R3-16: `.git` used to be counted, so validating the repository root declared
    # "12 rules over 86 files" while examining the same 14 it always had. A declared
    # scope whose number is dominated by objects nobody validates has stopped meaning
    # what it says, which is the defect this whole file is written against.
    #
    # `.runs` is excluded for a second and stronger reason: it is raw, unsanitised
    # output by design, and the rule about it is that nothing scans it.
    files = [p for p in root.rglob("*")
             if p.is_file() and not (NOT_OURS & set(p.relative_to(root).parts))]
    seen["files"] = len(files)

    # An empty scope is not a pass. If the directory is empty something went wrong
    # upstream, and reporting "valid" would be the exact defect this guards against.
    if not files:
        return False, f"BLIND: {root} contains no files. This is not a pass.", seen

    # Nor is a scope that is technically non-empty but obviously too small. Without this,
    # a bundle containing SKILL.md and nothing else passed every frontmatter rule and
    # returned VALID -- a skill that installs and can do nothing, published under a green
    # check. Measured, not hypothetical. The declared scope was printed and never judged,
    # which is the same defect one level up: declaring what you examined is worthless if
    # nothing looks at the declaration.
    if manifest:
        missing = [m for m in manifest if not (root / m).is_file()]
        if missing:
            return (
                False,
                f"BLIND: {len(missing)} of {len(manifest)} manifest paths are absent from {root}.\n"
                "  This is not a frontmatter problem and not a pass -- the bundle is incomplete:\n"
                + "\n".join(f"     missing  {m}" for m in missing),
                seen,
            )

        # And the other direction, which was missing and cost a real defect.
        #
        # MANIFEST is checked both ways against the TREE, by the pipeline. Against the
        # BUNDLE it was checked one way only: everything listed is present. Nothing asked
        # whether anything present was unlisted -- so a bundle with an extra file passed.
        #
        # Found by executing the release steps rather than reading them: `zip -qr out.skill
        # dir` UPDATES an existing archive instead of replacing it, so a stale README.md
        # from an earlier build survived into a freshly staged bundle and this validator
        # said VALID over 14 files against 13 manifest paths. It printed both numbers.
        # Nothing compared them, which is this file's own §1 defect committed by this file.
        # Only for a bundle (--exact). The source tree legitimately holds README.md,
        # scripts/, workflows and review artefacts, none of which ship.
        listed = set(manifest)
        extra = sorted(str(p.relative_to(root)) for p in files
                       if str(p.relative_to(root)) not in listed) if exact else []
        if extra:
            return (
                False,
                f"BLIND: {len(extra)} file(s) in {root} are not in the manifest.\n"
                "  A bundle is exactly what the manifest says or the manifest is not the\n"
                "  single source of truth. Add them, or find out what put them there:\n"
                + "\n".join(f"     unlisted  {m}" for m in extra),
                seen,
            )

    skill_md = root / "SKILL.md"
    nested = [p for p in root.rglob("SKILL.md") if _ships(p.relative_to(root))]
    seen["skill_md"] = len(nested)

    checks: list[tuple[str, bool, str]] = []

    def check(rule: str, ok: bool, detail: str = "") -> None:
        seen["rules"] += 1
        checks.append((rule, ok, detail))

    check("SKILL.md exists at the root", skill_md.exists())
    if not skill_md.exists():
        return False, _report(checks), seen

    check(
        "exactly one shipping SKILL.md",
        len(nested) == 1,
        f"found {len(nested)}: " + ", ".join(str(p.relative_to(root)) for p in nested),
    )

    text = skill_md.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
    check("YAML frontmatter present and delimited", bool(m))
    if not m:
        return False, _report(checks), seen

    try:
        fm = yaml.safe_load(m.group(1))
        parsed = isinstance(fm, dict)
    except yaml.YAMLError as exc:
        fm, parsed = None, False
        check("frontmatter parses as YAML", False, str(exc))
    if fm is None or not parsed:
        check("frontmatter is a YAML mapping", False)
        return False, _report(checks), seen
    check("frontmatter parses as a YAML mapping", True)

    unexpected = set(fm) - ALLOWED_KEYS
    check("no unexpected frontmatter keys", not unexpected, ", ".join(sorted(unexpected)))

    name = fm.get("name")
    check("name present and a string", isinstance(name, str) and bool(name.strip()))
    if isinstance(name, str):
        name = name.strip()
        check("name is kebab-case", bool(re.match(r"^[a-z0-9-]+$", name)), name)
        check(
            "name has no leading, trailing or doubled hyphen",
            not (name.startswith("-") or name.endswith("-") or "--" in name),
            name,
        )
        check(f"name at most {MAX_NAME} characters", len(name) <= MAX_NAME, f"{len(name)}")
        # Not in the reference validator. Learned by installing: a bundle named
        # `gtd-with-claude` passed every local check, passed the reference validator, and
        # was refused at install with "Skill name in SKILL.md cannot contain the reserved
        # word 'claude'". The rule lives in the installer, and the validator this file's
        # rules were read from does not have it -- so "we mirror the official validator"
        # was never the same claim as "this will install".
        hit = sorted(w for w in RESERVED_IN_NAME if w in name)
        check("name contains no reserved word", not hit,
              f"{hit} in {name!r}" if hit else "")

    desc = fm.get("description")
    check("description present and a string", isinstance(desc, str) and bool(desc.strip()))
    if isinstance(desc, str):
        desc = desc.strip()
        # This one is easy to trip and gives a confusing failure at load time, which is
        # exactly why it is checked here instead of being discovered by a user.
        check("description has no angle brackets", "<" not in desc and ">" not in desc)
        check(
            f"description at most {MAX_DESCRIPTION} characters",
            len(desc) <= MAX_DESCRIPTION,
            f"{len(desc)} used, {MAX_DESCRIPTION - len(desc)} left",
        )

    compat = fm.get("compatibility")
    if compat is not None:
        check("compatibility is a string", isinstance(compat, str))
        if isinstance(compat, str):
            check(
                f"compatibility at most {MAX_COMPATIBILITY} characters",
                len(compat) <= MAX_COMPATIBILITY,
                f"{len(compat)}",
            )

    ok = all(passed for _, passed, _ in checks)
    return ok, _report(checks), seen


def _report(checks) -> str:
    lines = []
    for rule, passed, detail in checks:
        mark = "ok  " if passed else "FAIL"
        lines.append(f"  {mark} {rule}" + (f"   [{detail}]" if detail else ""))
    return "\n".join(lines)


# --------------------------------------------------------------------------------------
# Proving the validator, which is the part that makes its green meaningful.

MUTATIONS = {
    "description over the limit": lambda d: _sub(d, "description", "x" * (MAX_DESCRIPTION + 1)),
    "description with angle brackets": lambda d: _sub(d, "description", "does a thing for <you>"),
    "name in the wrong case": lambda d: _sub(d, "name", "Gtd_With_Agents"),
    # The literal name v0.1.2 was published with. It passed every check here and every
    # check in the reference validator, and the installer refused it.
    "a reserved word in the name": lambda d: _sub(d, "name", "gtd-with-claude"),
    "unexpected frontmatter key": lambda d: _add_key(d, "author: someone"),
    "a second shipping SKILL.md": lambda d: _extra_skill_md(d),
    "no SKILL.md at all": lambda d: (d / "SKILL.md").unlink(),
    "a bundle missing everything but SKILL.md": lambda d: _strip_to_skill_md(d),
}

# The one mutation whose own rule IS the manifest gate, so it cannot be caught without it.
# Everything else must be caught by a frontmatter rule, with or without a manifest --
# otherwise the gate is silently standing in for the rule the mutation claims to prove.
MANIFEST_ONLY = {"a bundle missing everything but SKILL.md"}


def _strip_to_skill_md(root: Path) -> None:
    for p in list(root.rglob("*")):
        if p.is_file() and p.name != "SKILL.md":
            p.unlink()


def _rewrite_frontmatter(root: Path, fn) -> None:
    p = root / "SKILL.md"
    t = p.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---", t, re.DOTALL)
    p.write_text("---\n" + fn(m.group(1)) + "\n---" + t[m.end():], encoding="utf-8")


def _sub(root: Path, key: str, value: str) -> None:
    _rewrite_frontmatter(
        root,
        lambda fm: re.sub(rf"^{key}:.*?(?=\n[a-z-]+:|\Z)", f"{key}: {value}", fm, flags=re.S | re.M),
    )


def _add_key(root: Path, line: str) -> None:
    _rewrite_frontmatter(root, lambda fm: fm + "\n" + line)


def _extra_skill_md(root: Path) -> None:
    (root / "reference").mkdir(exist_ok=True)
    (root / "reference" / "SKILL.md").write_text("---\nname: x\ndescription: y\n---\n", encoding="utf-8")


def self_test(root: Path, manifest: list[str] | None = None) -> bool:
    """Break it on purpose, once per rule, and require every mutation to be rejected."""
    print(f"SELF-TEST: {len(MUTATIONS)} deliberate mutations of {root}\n")
    all_ok = True
    for label, mutate in MUTATIONS.items():
        with tempfile.TemporaryDirectory() as tmp:
            copy = Path(tmp) / root.name
            shutil.copytree(root, copy)
            mutate(copy)
            # Twice: with the manifest and without it. The manifest gate runs first and
            # would catch several of these for the wrong reason -- a mutation that deletes
            # SKILL.md is rejected as a missing manifest path, and the rule it was written
            # to prove is never exercised. Proven by deleting that rule: the self-test
            # still printed "ok rejects". A self-test that passes with a rule removed is a
            # check whose failure mode is to report success, in the script whose docstring
            # says a verifier never seen to fail is not evidence.
            with_m, _, _ = validate(copy, manifest)
            without_m, _, _ = validate(copy, None)
            if label in MANIFEST_ONLY:
                caught = not with_m
                detail = "  (manifest rule)"
            else:
                caught = (not with_m) and (not without_m)
                detail = "" if caught else (
                    "  <- caught only by the manifest gate, not by its own rule"
                    if not with_m else "  <- not caught at all")
            print(f"  {'ok  ' if caught else 'FAIL'} rejects: {label}{detail}")
            all_ok &= caught

    # The --exact rule needs a bundle-shaped tree, so it cannot be one of the mutations
    # above, which copy the source tree. Both polarities, because this rule was added
    # after a stale file survived into a bundle under a fully green pipeline.
    if manifest:
        with tempfile.TemporaryDirectory() as tmp:
            bundle = Path(tmp) / "bundle"
            for m in manifest:
                (bundle / m).parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(root / m, bundle / m)
            clean, _, _ = validate(bundle, manifest, exact=True)
            print(f"  {'ok  ' if clean else 'FAIL'} accepts: a bundle of exactly the manifest")
            (bundle / "stale.md").write_text("left over from an earlier build\n", encoding="utf-8")
            dirty, _, _ = validate(bundle, manifest, exact=True)
            print(f"  {'ok  ' if not dirty else 'FAIL'} rejects: a bundle carrying a file "
                  f"the manifest does not list")
            all_ok &= clean and not dirty

    # And the polarity nobody runs: the untouched skill must still pass. A checker only
    # ever tested on broken input has not been shown to accept anything.
    ok, _, _ = validate(root, manifest)
    print(f"  {'ok  ' if ok else 'FAIL'} accepts: the unmodified skill")
    return all_ok and ok


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    # Resolved, not taken as given: a relative "." has an empty .name, and the self-test
    # builds its copy destination from it. Found by the self-test failing on itself.
    root = Path(sys.argv[1]).resolve()
    if not root.is_dir():
        print(f"BLIND: {root} is not a directory. This is not a pass.")
        return 2

    # R2-05: the documented invocation had no --manifest, so a one-file bundle printed
    # "no manifest given" and then VALID and exit 0 -- the declared scope was printed and
    # never judged, which is the defect this file's own comment names. Now the manifest is
    # found by default, and its absence is BLIND rather than a pass.
    manifest = None
    if "--no-manifest" not in sys.argv and "--manifest" not in sys.argv:
        # R3-14: the search used to include Path.cwd() and root.parent, so the same bundle
        # got a different verdict depending on where the shell was standing -- a manifest
        # planted in an unrelated directory was adopted as the contract for a target that
        # had none. A bundle's contract belongs beside the bundle. The one convenience
        # worth keeping is running this from the repository root, and that is resolved
        # from THIS FILE's location, which does not move when the user does.
        home = Path(__file__).resolve().parent.parent
        cands = [root / "MANIFEST"]
        if root.resolve().is_relative_to(home):      # only for a target inside this repo
            cands.append(home / "MANIFEST")
        for cand in cands:
            if cand.is_file():
                manifest = read_manifest(cand)
                print(f"(manifest found at {cand})")
                break
        else:
            print("BLIND: no MANIFEST found and --no-manifest not given.\n"
                  "  Frontmatter alone cannot tell a complete bundle from a one-file one.\n"
                  "  This is not a pass.")
            return 2
    if "--manifest" in sys.argv:
        mpath = Path(sys.argv[sys.argv.index("--manifest") + 1])
        if not mpath.is_file():
            print(f"BLIND: manifest {mpath} not found. This is not a pass.")
            return 2
        manifest = read_manifest(mpath)

    if "--self-test" in sys.argv:
        return 0 if self_test(root, manifest) else 1

    # --exact: the bundle must be EXACTLY the manifest, nothing more. Only meaningful on
    # an extracted bundle; a source tree legitimately holds files that do not ship.
    exact = "--exact" in sys.argv
    ok, report, seen = validate(root, manifest, exact=exact)
    print(report)
    print(
        f"\nEXAMINED: {seen['rules']} rules over {seen['files']} files "
        f"({seen['skill_md']} shipping SKILL.md"
        + (f", {seen['manifest']} manifest paths" if manifest else ", no manifest given")
        + (", exact" if exact else ", extra files not judged")
        + ")"
    )
    print("VALID" if ok else "INVALID")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
