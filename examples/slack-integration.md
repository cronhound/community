# Slack Integration

Route cronhound alerts into a Slack channel so your team sees downtime the moment
it happens, without watching a dashboard.

## The problem

You want your team to know immediately when a monitor goes down. Email alerts get
buried. You already live in Slack. Cronhound fires a webhook on state changes —
point that webhook at Slack and you're done.

## The setup

**1. Create a Slack incoming webhook**

In Slack:
- Go to `api.slack.com/apps` → Create New App → From scratch
- Give it a name (e.g., "Cronhound Alerts") and pick your workspace
- In the sidebar, click **Incoming Webhooks** and toggle it on
- Click **Add New Webhook to Workspace**, pick the channel, authorize
- Copy the webhook URL (starts with `https://hooks.slack.com/services/...`)

**2. Add the webhook to your cronhound monitor**

In cronhound:
- Open the monitor you want alerts for (or create one)
- Go to **Notifications** → **Add webhook**
- Paste the Slack webhook URL
- Set payload format to Slack-compatible (example below)
- Save

**3. Test it**

Pause the monitored service briefly (or pick a URL you know returns a 500).
Within the check interval, you should see a Slack message like:

> 🔴 **cronhound alert:** `api.example.com` is DOWN
> Status: 503 Service Unavailable
> [View in dashboard](https://cronhound.com/m/abc123)

## Payload format

Cronhound sends a JSON webhook. For Slack's incoming webhook format, your cronhound
notification config should shape the payload like:

```json
{
  "text": ":red_circle: *cronhound alert:* `{{monitor.name}}` is {{status}}",
  "attachments": [
    {
      "color": "{{#if isDown}}danger{{else}}good{{/if}}",
      "fields": [
        { "title": "Status", "value": "{{statusCode}} {{statusText}}", "short": true },
        { "title": "Checked", "value": "{{timestamp}}", "short": true }
      ],
      "actions": [
        { "type": "button", "text": "View in dashboard", "url": "{{dashboardUrl}}" }
      ]
    }
  ]
}
```

Replace the template variables with whatever cronhound exposes in your webhook
template system.

## Gotchas

- **Rate limits.** Slack throttles incoming webhooks at ~1 message/second per workspace.
  If you have many monitors flapping at once, alerts can get queued or dropped. Solution:
  only alert on state *changes* (down → up, up → down), not on every failed check.
- **Channel noise.** Route non-critical monitors to a low-priority channel so important
  alerts don't get buried. Cronhound supports multiple webhooks per monitor.
- **Off-hours.** Slack doesn't suppress notifications based on your schedule. If you
  don't want a 3am Slack ping, use cronhound's notification schedule (if available) or
  route alerts through PagerDuty for proper on-call rotation.

## Going further

- Pipe critical alerts through PagerDuty before Slack for on-call rotation
- Use Slack threads to group alerts for the same service
- Add a `/cronhound` slash command (via a separate Slack app) to query monitor status
  from any channel

---

Contributed by the cronhound team. Found a better way? Open a PR.
