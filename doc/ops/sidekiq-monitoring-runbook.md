# Sidekiq Monitoring Runbook (Production)

## What was added
- Worker service: `hotel-insight-crm-worker-prod` (Cloud Run, `us-central1`)
- Uptime checks:
  - `hatamoto-sidekiq-worker-active`
  - `hatamoto-sidekiq-enqueued-zero`
- Alert policies:
  - `hatamoto sidekiq worker down`
  - `hatamoto sidekiq queue stuck`

## Why
Prevent recurrence of "accepted but not delivered" incidents caused by Sidekiq workers not running.

## Post-deploy mandatory check
Run:

```bash
script/ops/post_deploy_sidekiq_check.sh
```

Expected:
- Sidekiq status `active` or `idle`
- Processes `>= 1`
- Enqueued ideally `0` (or decreasing)

## Manual verification URLs
- Sidekiq dashboard: `https://hatamotohq.com/sidekiq`
- Worker service: `hotel-insight-crm-worker-prod` in Cloud Run (`us-central1`)

## Incident quick response
1. Check Sidekiq dashboard (`Processes`, `Enqueued`, queue latency)
2. Check worker service revision health and logs
3. Confirm `default` queue drains
4. Re-test template/scenario send from a real channel
