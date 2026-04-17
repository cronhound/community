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
echo "→ Fetching repo node ID..."
REPO_NODE=$(gh api graphql -f query='
  query($owner:String!, $name:String!) {
    repository(owner:$owner, name:$name) { id }
  }' -f owner="$OWNER" -f name="community" -q .data.repository.id)

echo "→ Creating discussion categories..."
# NOTE: GitHub auto-creates default categories on enable. If creation fails
# because a category already exists, that's fine — move on.
for cat in \
  "Announcements|ANNOUNCEMENT|📣|Releases and roadmap updates" \
  "Q&A|QUESTION|❓|Ask a question, get an answer" \
  "Ideas|DISCUSSION|💡|Feature brainstorming" \
  "Show and tell|DISCUSSION|✨|User projects and integrations"
do
  IFS='|' read -r cat_name cat_format cat_emoji cat_desc <<< "$cat"
  echo "  • $cat_name"
  gh api graphql -f query='
    mutation($repo:ID!, $name:String!, $emoji:String!, $desc:String!, $format:DiscussionCategoryFormat!) {
      createDiscussionCategory(input:{
        repositoryId:$repo, name:$name, emoji:$emoji, description:$desc, format:$format
      }) { category { id name } }
    }' -f repo="$REPO_NODE" -f name="$cat_name" -f emoji="$cat_emoji" \
       -f desc="$cat_desc" -f format="$cat_format" 2>/dev/null \
    || echo "    (skipped — likely already exists)"
done

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
echo "  1. Add 4 columns to the Roadmap project: Ideas → Planned → Building → Shipped"
echo "  2. Seed the Roadmap with 3–5 real near-term items"
echo "  3. Pin a welcome post in Announcements"
echo "  4. Upload a social preview image (Settings → Options)"
