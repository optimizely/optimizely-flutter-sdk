---
name: release
description: Publish to pub.dev and create GitHub release (Step 2 of release workflow)
compatibility: Requires Flutter SDK and merged prepare-release PR
---

# Release - Step 2 of Release Workflow

Publishes package to pub.dev and creates draft GitHub release.

## Usage

```bash
/release <version> [--prerelease]
```

## Prerequisites

- `/prepare-release` PR merged into master
- On master branch with clean working tree

## Execution

Runs: `./.claude/skills/release/skill.sh <version> [--prerelease]`

## What It Does

1. ✅ Validates version matches pubspec.yaml
2. ✅ Runs `flutter packages pub publish --dry-run`
3. ✅ Publishes to pub.dev
4. ✅ Extracts CHANGELOG for this version
5. ✅ Creates draft GitHub release with tag `vX.Y.Z`

