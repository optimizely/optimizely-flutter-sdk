---
name: prepare-release
description: Prepare release branch with version updates and create PR for Optimizely Flutter SDK
compatibility: Requires Flutter SDK project
---

# Prepare Release - Step 1 of Release Workflow

Creates prep branch, updates versions, fetches PR summaries, and creates PR.

## Usage

```bash
/prepare-release <version_or_bump> [tickets or PRs...]
```

## Examples

```bash
/prepare-release patch #103 #105
/prepare-release minor FSSDK-12345 FSSDK-12346
/prepare-release 3.5.0 #103
```

## Execution

Runs: `./.claude/skills/prepare-release/skill.sh <version_or_bump> [refs...]`

## Features

- ✅ Fetches PR titles automatically for CHANGELOG
- ✅ Updates 4 files: pubspec.yaml, package_info.dart, README.md, CHANGELOG.md
- ✅ Creates prep branch: `{username}/prep-{version}`
- ✅ Creates PR with proper formatting

