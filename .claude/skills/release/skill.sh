#!/bin/bash
set -euo pipefail
set +H  # Disable history expansion to prevent '!' in content from being expanded

# Optimizely Flutter SDK - Release (Step 2)
# Publishes to pub.dev and creates GitHub release

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}✗ Error: $1${NC}" >&2; exit 1; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${YELLOW}ℹ $1${NC}"; }

VERSION="${1:-}"
PRERELEASE=""
[[ "${2:-}" == "--prerelease" ]] && PRERELEASE="--prerelease"

[[ -z "$VERSION" ]] && error "Usage: /release <version> [--prerelease]"
[[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9]+)?$ ]] && error "Invalid version: $VERSION"

# Pre-flight checks
info "Running pre-flight checks..."
[[ "$(git branch --show-current)" != "master" ]] && error "Must be on master branch"
git diff-index --quiet HEAD -- || error "Working tree has uncommitted changes"

PUBSPEC_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
[[ "$PUBSPEC_VERSION" != "$VERSION" ]] && error "Version mismatch! pubspec.yaml: $PUBSPEC_VERSION, requested: $VERSION"

# Verify authentication (note: gh auth status only checks authentication, not that the
# token has the required 'repo' scope needed to create releases)
gh auth status &>/dev/null || error "GitHub CLI not authenticated. Run: gh auth login"

success "Pre-flight checks passed"

# Create temporary file for dry-run output (prevents symlink attacks)
DRY_RUN_LOG=$(mktemp)
trap "rm -f \"${DRY_RUN_LOG}\"" EXIT

# Dry run
info "Running pub publish dry-run..."
flutter packages pub publish --dry-run 2>&1 | tee "$DRY_RUN_LOG"
FLUTTER_EXIT="${PIPESTATUS[0]}"
if [[ "$FLUTTER_EXIT" != "0" ]]; then
    echo ""
    if [[ ! -t 0 ]]; then
        error "Dry-run found warnings. Cannot prompt in non-interactive mode. Fix warnings or run interactively."
    fi
    read -p "Dry-run found warnings. Continue? (y/N) " -r -n 1
    echo
    [[ ! "$REPLY" =~ ^[Yy]$ ]] && error "Aborted by user"
fi

# Publish
info "Publishing to pub.dev..."
flutter packages pub publish || error "Publishing failed"
success "Published to pub.dev!"

# Extract CHANGELOG
# Escape VERSION for use in sed regex (prevent regex metacharacter interpretation).
# VERSION is already validated against ^[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9]+)?$ above,
# so it cannot contain '|' (the alternate sed delimiter used below); escaping here
# is an additional safety measure for other metacharacters.
ESCAPED_VERSION=$(printf '%s\n' "$VERSION" | sed 's/[.[\*^$()+?{|]/\\&/g')
CHANGELOG_CONTENT=$(sed -n "\|^## ${ESCAPED_VERSION}\$|,\|^## [0-9]|p" CHANGELOG.md | sed '1d;$d')
[[ -z "$CHANGELOG_CONTENT" ]] && CHANGELOG_CONTENT=$(printf 'Release %s\n\nSee CHANGELOG.md for details.' "$VERSION")

RELEASE_NOTES="## $VERSION

$CHANGELOG_CONTENT"

# Create GitHub release
info "Creating GitHub draft release..."
if [[ -n "$PRERELEASE" ]]; then
    GH_RELEASE_URL=$(gh release create "v${VERSION}" \
        --title "Release v${VERSION}" \
        --notes "$RELEASE_NOTES" \
        --target master \
        --draft \
        "$PRERELEASE")
else
    GH_RELEASE_URL=$(gh release create "v${VERSION}" \
        --title "Release v${VERSION}" \
        --notes "$RELEASE_NOTES" \
        --target master \
        --draft)
fi

success "GitHub draft release created!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Release complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Version: $VERSION"
echo "Pub.dev: https://pub.dev/packages/optimizely_flutter_sdk/versions/$VERSION"
echo "GitHub Release: $GH_RELEASE_URL"
echo ""
echo "Next Steps:"
echo "1. 🔍 Verify package on pub.dev (may take 1-10 minutes to appear)"
echo "2. ✏️  Review the draft release at: $GH_RELEASE_URL"
echo "3. ✅ Make the draft release public once verified"
echo ""
