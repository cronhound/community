#!/usr/bin/env bash
# One-shot seeder for Cronhound Roadmap project (v2).
# Adds draft items with Status set to Ideas/Planned/Building/Shipped.
# Safe to re-run? NO — re-running creates duplicates. Run once.
set -euo pipefail

OWNER="cronhound"
PROJECT_NUM=1
PROJECT_ID="PVT_kwDOEHbFP84BU4tl"
STATUS_FIELD="PVTSSF_lADOEHbFP84BU4tlzhImwF0"
OPT_IDEAS="cfba8eac"
OPT_PLANNED="676e27a4"
OPT_BUILDING="3a9e74ea"
OPT_SHIPPED="de705539"

add_item() {
  local status_opt="$1" title="$2" body="$3"
  echo "→ [$4] $title"
  local item_id
  item_id=$(gh project item-create "$PROJECT_NUM" --owner "$OWNER" \
    --title "$title" --body "$body" --format json | jq -r .id)
  gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
    --field-id "$STATUS_FIELD" --single-select-option-id "$status_opt" > /dev/null
}

# ─── SHIPPED (bundled from commit history into customer-facing features) ────
add_item "$OPT_SHIPPED" "Public status pages" \
"Share a public, unauthenticated status page at \`/status/{your-slug}\`. Pick which monitors to show — the rest stay private. Includes 30-day uptime stats per monitor." "shipped"

add_item "$OPT_SHIPPED" "Monitor history — 24h heatmap + drill-down" \
"Expand any monitor to see a sparkline, 24-hour hourly heatmap, and click-through to the raw check results. Data kept for 48 hours." "shipped"

add_item "$OPT_SHIPPED" "Mobile-friendly dashboard" \
"Monitor list redesigned for small screens: status dots wrap instead of scrolling, tap targets sized for fingers, URLs and timestamps stay readable. Delete moved behind confirmation." "shipped"

add_item "$OPT_SHIPPED" "Sign in with Google or magic link" \
"Sign in with Google OAuth or a one-tap magic link sent to your email. Same account works across both — no duplicate profiles." "shipped"

add_item "$OPT_SHIPPED" "Stripe billing with EARLYBIRD discount" \
"Full subscription lifecycle through Stripe: upgrade, payment failures, cancellation, downgrade. EARLYBIRD coupon for the first 50 sign-ups." "shipped"

add_item "$OPT_SHIPPED" "Webhook alerts (Slack, Discord, PagerDuty compatible)" \
"Generic webhook alerts on DOWN and recovery events. Works with any service that accepts an incoming webhook — Slack, Discord, PagerDuty, your own endpoint. Idempotent delivery with rollback on failure." "shipped"

add_item "$OPT_SHIPPED" "Security hardening — SSRF blocklist + safe retries" \
"Monitors can't be used to probe internal networks (SSRF protection). Failed jobs recover cleanly from worker restarts. Free tier enforcement hardened." "shipped"

# ─── BUILDING ──────────────────────────────────────────────────────────────
add_item "$OPT_BUILDING" "Uptime badge (embeddable SVG)" \
"Shields.io-compatible uptime badge per monitor at \`/badge/{monitor-id}.svg\`. Drop it in your README. Gray 'unknown' if the monitor is private so your README image never 404s. Design shipped, building now." "building"

# ─── PLANNED ───────────────────────────────────────────────────────────────
add_item "$OPT_PLANNED" "Dead man's switch — cron ping endpoint" \
"Every cron job gets a unique \`/ping/{job-id}\` URL. Your server \`curl\`s it after each run; we alert if the ping doesn't arrive in time. Makes Cronhound a superset of WatchCron for cron monitoring." "planned"

add_item "$OPT_PLANNED" "Edit / pause / resume monitors" \
"Change a monitor's URL, interval, or alert settings without deleting and recreating. Pause noisy monitors during maintenance windows instead of silencing them permanently." "planned"

add_item "$OPT_PLANNED" "30-day uptime % in monitor row" \
"Show the rolling 30-day uptime percentage right next to each monitor in the dashboard. One glance tells you which monitors are flaky." "planned"

add_item "$OPT_PLANNED" "Incident timeline with live banners" \
"Open incidents show as a banner at the top of the dashboard. Click through to a timeline view: when it started, when it recovered, which alerts fired." "planned"

add_item "$OPT_PLANNED" "Weekly reliability digest email" \
"Sunday-night email summarizing the week: uptime per monitor, incident count, average response time. Opt-out anytime. 'All quiet, nothing to report' when nothing broke." "planned"

add_item "$OPT_PLANNED" "Live demo on landing page" \
"Paste a URL on cronhound.com, see a real check result in under 5 seconds. Rate-limited, no sign-up required." "planned"

add_item "$OPT_PLANNED" "Latency histogram per monitor" \
"Distribution of response times over the last 24h / 7d / 30d. Spot slowdowns before they become outages. Data is already captured — this is the visualization." "planned"

add_item "$OPT_PLANNED" "Configurable alert thresholds" \
"Right now free tier alerts after 2 failed checks, recovers after 2 successful. Pro tier gets to tune these (1-5 / 1-3) for noisier endpoints." "planned"

# ─── IDEAS ─────────────────────────────────────────────────────────────────
add_item "$OPT_IDEAS" "Custom request headers on monitors" \
"Monitor auth-gated endpoints like \`/health\` behind \`Authorization: Bearer ...\`. Pro tier. Add ideas and use cases in the discussion." "ideas"

add_item "$OPT_IDEAS" "SMS alerts (Twilio)" \
"Text message alerts for critical incidents. Comment with your use case — volume expectations shape pricing." "ideas"

add_item "$OPT_IDEAS" "Native Discord integration" \
"Discord works today via generic webhooks. A native app gets you better formatting, slash commands, and per-channel routing." "ideas"

add_item "$OPT_IDEAS" "Light mode / theme toggle" \
"App is dark-mode-only today. Light mode + system-preference toggle if there's demand." "ideas"

add_item "$OPT_IDEAS" "Status pages with custom domains" \
"Host your public status page at \`status.yourcompany.com\` instead of \`cronhound.com/status/your-slug\`." "ideas"

add_item "$OPT_IDEAS" "Public post-mortems on incident pages" \
"After resolving an incident, attach a post-mortem writeup. Shows your customers how you handle failure." "ideas"

echo ""
echo "✅ Roadmap seeded: https://github.com/orgs/$OWNER/projects/$PROJECT_NUM"
