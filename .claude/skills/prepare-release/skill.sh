#!/bin/bash
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}✗ Error: $1${NC}" >&2; exit 1; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# Parse arguments
VERSION_OR_BUMP="${1:-}"
shift || true

# Collect references (tickets or PRs)
REFERENCES=()
REF_TYPE=""

for arg in "$@"; do
    arg=$(echo "$arg" | xargs)
    if [[ "$arg" =~ ^#?[0-9]+$ ]]; then
        REFERENCES+=("${arg#\#}")
        REF_TYPE="pr"
    elif [[ "$arg" =~ ^[A-Z]+-[0-9]+$ ]]; then
        REFERENCES+=("$arg")
        REF_TYPE="ticket"
    fi
done

[[ -z "$VERSION_OR_BUMP" ]] && error "Usage: /prepare-release <version_or_bump> [tickets or PRs...]"

# Get current version and calculate new version
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
info "Current version: $CURRENT_VERSION"

if [[ "$VERSION_OR_BUMP" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    NEW_VERSION="$VERSION_OR_BUMP"
else
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    case "$VERSION_OR_BUMP" in
        major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
        minor) NEW_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
        patch) NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
        *) error "Invalid version: $VERSION_OR_BUMP" ;;
    esac
fi

info "New version: $NEW_VERSION"

# Pre-flight checks
info "Running pre-flight checks..."
[[ "$(git branch --show-current)" != "master" ]] && error "Must be on master branch"
git diff-index --quiet HEAD -- || error "Working tree has uncommitted changes. Please commit or stash first."
success "Git status clean"

# Create prep branch
GIT_USERNAME=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
PREP_BRANCH="${GIT_USERNAME}/prep-${NEW_VERSION}"
git show-ref --verify --quiet "refs/heads/$PREP_BRANCH" && error "Branch $PREP_BRANCH already exists"
git checkout -b "$PREP_BRANCH"
success "Branch created: $PREP_BRANCH"

# Update version files
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml && rm pubspec.yaml.bak
sed -i.bak "s/static const String version = '.*';/static const String version = '$NEW_VERSION';/" lib/package_info.dart && rm lib/package_info.dart.bak
sed -i.bak "s/optimizely_flutter_sdk: \^.*/optimizely_flutter_sdk: ^$NEW_VERSION/" README.md && rm README.md.bak

# Update CHANGELOG
CURRENT_DATE=$(date "+%B %d, %Y")

# Build CHANGELOG entries from PRs
CHANGELOG_ENTRIES=""
if [[ ${#REFERENCES[@]} -gt 0 && "$REF_TYPE" == "pr" ]]; then
    info "Fetching PR details for CHANGELOG..."
    for pr in "${REFERENCES[@]}"; do
        PR_TITLE=$(gh pr view "$pr" --json title --jq '.title' 2>/dev/null || echo "")
        if [[ -n "$PR_TITLE" ]]; then
            # Remove ticket prefix from title if present (e.g., [FSSDK-12503])
            PR_TITLE=$(echo "$PR_TITLE" | sed 's/^\[[A-Z]*-[0-9]*\] //')
            # Capitalize first letter
            PR_TITLE="$(echo ${PR_TITLE:0:1} | tr '[:lower:]' '[:upper:]')${PR_TITLE:1}"
            CHANGELOG_ENTRIES="${CHANGELOG_ENTRIES}* ${PR_TITLE} ([#${pr}](https://github.com/optimizely/optimizely-flutter-sdk/pull/${pr}))
"
        fi
    done
fi

# If no PRs or PR fetch failed, use placeholder
if [[ -z "$CHANGELOG_ENTRIES" ]]; then
    CHANGELOG_ENTRIES="* Update with actual release notes
"
fi

# Detect section header (Bug Fixes, New Features, etc.) from PR titles
SECTION_HEADER="### Bug Fixes"
if echo "$CHANGELOG_ENTRIES" | grep -qi "feat:"; then
    SECTION_HEADER="### New Features"
elif echo "$CHANGELOG_ENTRIES" | grep -qi "enhancement"; then
    SECTION_HEADER="### Enhancements"
fi

cat > /tmp/changelog_new.md << EOF
# Optimizely Flutter SDK Changelog

## ${NEW_VERSION}
${CURRENT_DATE}

${SECTION_HEADER}
${CHANGELOG_ENTRIES}
EOF
tail -n +2 CHANGELOG.md >> /tmp/changelog_new.md
mv /tmp/changelog_new.md CHANGELOG.md

success "Updated all version files with CHANGELOG"

# Commit and push
git add pubspec.yaml lib/package_info.dart README.md CHANGELOG.md
git commit -m "chore: prep for release ${NEW_VERSION}

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
git push -u origin "$PREP_BRANCH"
success "Pushed to origin/$PREP_BRANCH"

# Create PR
PR_TITLE="prep for release ${NEW_VERSION}"
[[ ${#REFERENCES[@]} -gt 0 && "$REF_TYPE" == "ticket" ]] && PR_TITLE="[$(IFS=,; echo "${REFERENCES[*]}")] $PR_TITLE"

PR_BODY="## Summary

Prepare for release ${NEW_VERSION}

**Version Updates:**
- ✅ pubspec.yaml
- ✅ package_info.dart
- ✅ README.md
- ✅ CHANGELOG.md

⚠️ Please update CHANGELOG.md with actual release notes before merging.

## Test Plan
- All CI checks must pass (4 workflows)
- Verify version numbers match across all files"

if [[ ${#REFERENCES[@]} -gt 0 ]]; then
    if [[ "$REF_TYPE" == "ticket" ]]; then
        PR_BODY="${PR_BODY}

## Issues"
        for ref in "${REFERENCES[@]}"; do PR_BODY="${PR_BODY}
- ${ref}"; done
    else
        PR_BODY="${PR_BODY}

## Related PRs"
        for ref in "${REFERENCES[@]}"; do PR_BODY="${PR_BODY}
- #${ref}"; done
    fi
fi

PR_URL=$(gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base master --head "$PREP_BRANCH")
success "Pull request created: $PR_URL"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Release preparation complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Version: $CURRENT_VERSION → $NEW_VERSION"
echo "Branch: $PREP_BRANCH"
[[ ${#REFERENCES[@]} -gt 0 ]] && echo "References: ${REFERENCES[*]}"
echo "PR: $PR_URL"
echo ""
