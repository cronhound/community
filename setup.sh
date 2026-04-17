#!/usr/bin/env bash
# Cronhound community repo setup — run once after committing files.
# Requires: gh CLI authenticated with write:discussion and project scopes.
#   gh auth refresh -s write:discussion,project
set -euo pipefail

REPO="cronhound/community"
OWNER="cronhound"

echo "Setting up $REPO..."

# ─── 1. Repo metadata ───────────────────────────────────────────────────────
echo "→ Setting repo description and topics..."
gh repo edit "$REPO" \
  --description "Public community hub for cronhound — bugs, feature requests, roadmap, discussions" \
  --add-topic monitoring \
  --add-topic uptime \
  --add-topic cronhound \
  --add-topic community

# ─── 2. Enable Discussions ──────────────────────────────────────────────────
echo "→ Enabling Discussions..."
gh repo edit "$REPO" --enable-discussions

# ─── 3. Labels ──────────────────────────────────────────────────────────────
echo "→ Clearing default labels..."
gh label list --repo "$REPO" --json name -q '.[].name' \
  | while read -r label; do
      gh label delete "$label" --repo "$REPO" --yes 2>/dev/null || true
    done

echo "→ Creating community labels..."
gh label create "bug"             --repo "$REPO" \
  --color "D73A4A" --description "Something isn't working"
gh label create "feature-request" --repo "$REPO" \
  --color "0075CA" --description "New capability users want"
gh label create "question"        --repo "$REPO" \
  --color "D876E3" --description "Usage or clarification question"
gh label create "good-first-issue" --repo "$REPO" \
  --color "7057FF" --description "Welcoming label for new contributors"
gh label create "shipped"          --repo "$REPO" \
  --color "0E8A16" --description "Delivered in a release"

# ─── 4. Discussion categories ───────────────────────────────────────────────
# NOTE: GitHub does NOT expose a programmatic way to create, rename, or delete
# discussion categories via API. When Discussions are enabled, GitHub creates
# default categories automatically: Announcements, General, Ideas, Polls, Q&A,
# Show and tell.
#
# Manual action required:
#   → Visit https://github.com/$REPO/discussions/categories
#   → Delete unwanted categories: General, Polls
#   → Optionally customize descriptions for the 4 keepers:
#       Announcements, Q&A, Ideas, Show and tell
echo "→ Listing current discussion categories (manual cleanup needed)..."
gh api graphql -f query='
  query { repository(owner:"'"$OWNER"'", name:"community") {
    discussionCategories(first:20) { nodes { name } }
  }}' --jq '.data.repository.discussionCategories.nodes[].name' \
  | sed 's/^/    • /'

# ─── 5. Public Roadmap project ──────────────────────────────────────────────
echo "→ Creating public roadmap project..."
PROJ_NUM=$(gh project create --owner "$OWNER" --title "Cronhound Roadmap" \
  --format json 2>/dev/null | jq -r .number || echo "")
if [ -n "$PROJ_NUM" ]; then
  echo "  ✓ Roadmap: https://github.com/orgs/$OWNER/projects/$PROJ_NUM"
  echo "  → Manually add columns: Ideas, Planned, Building, Shipped"
  echo "  → Manually seed with 3–5 real roadmap items"
else
  echo "  (project creation skipped — may need: gh auth refresh -s project)"
fi

# ─── 6. Branch protection ───────────────────────────────────────────────────
echo "→ Setting branch protection on main..."
gh api -X PUT "repos/$REPO/branches/main/protection" \
  --input - <<EOF 2>/dev/null || echo "  (branch protection skipped — may need repo admin scope)"
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 1 },
  "restrictions": null
}
EOF

echo ""
echo "✅ Community repo configured."
echo ""
echo "Still manual (≈10 min):"
echo "  1. Delete unwanted discussion categories (General, Polls) via:"
echo "       https://github.com/$REPO/discussions/categories"
echo "  2. Add 4 columns to the Roadmap project: Ideas → Planned → Building → Shipped"
echo "  3. Seed the Roadmap with 3–5 real near-term items"
echo "  4. Pin a welcome post in Announcements"
echo "  5. Upload a social preview image (Settings → Options)"
