# FAQ

Living answers to questions cronhound users ask most often. This grows from real
conversations in [Q&A](https://github.com/cronhound/community/discussions/categories/q-a) —
if a question comes up twice, it belongs here.

## General

### What does cronhound do?

Cronhound is uptime monitoring that actually works. It checks your endpoints on a
schedule, alerts you when things break, and gives you a public status page and badge
so your users know too.

### How is cronhound different from other uptime monitors?

Faster to set up, cleaner alerts, honest about failures. See
[cronhound.com](https://cronhound.com) for the current product pitch.

### Is there a free tier?

Yes. Free tier includes a limited number of monitors with reasonable check intervals.
See [cronhound.com/pricing](https://cronhound.com/pricing) for current limits.

## Using cronhound

### How often does cronhound check my monitors?

Depends on your plan. Free tier checks at longer intervals; paid tiers check more
frequently. See your plan details in your account.

### Can I run checks from multiple regions?

Check the current plan features at [cronhound.com/pricing](https://cronhound.com/pricing).
If it's not available and you need it, [file a feature request](https://github.com/cronhound/community/issues/new?template=feature_request.yml).

### What happens if cronhound itself goes down?

We publish our own uptime publicly. If there's an incident, you'll see it on our
status page (linked from [cronhound.com](https://cronhound.com)).

## Alerts & integrations

### How do I get alerts in Slack?

See the [Slack integration example](../examples/slack-integration.md).

### Does cronhound integrate with PagerDuty / Opsgenie / [X]?

Webhook-based integrations work with most services. Native integrations are added
based on user demand — [request one here](https://github.com/cronhound/community/issues/new?template=feature_request.yml).

### Can I customize alert messages?

Yes, via the webhook payload template. See the
[Slack example](../examples/slack-integration.md) for how template variables work.

## Billing & accounts

### How do I change my plan?

From your account settings page in the cronhound dashboard. Billing issues go to
**billing@cronhound.com**.

### How do I delete my account?

Email **support@cronhound.com**. We'll confirm and fully remove your data.

### Where do I see my invoices?

In your account settings → Billing. Email support if you need something older.

## Something missing?

- [Ask in Q&A](https://github.com/cronhound/community/discussions/categories/q-a) — we answer publicly so others benefit
- [Open a PR](https://github.com/cronhound/community/pulls) to add an answer you've figured out yourself
