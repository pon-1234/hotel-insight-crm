# GCP Cutover Runbook (Cost Reduction)

Last verified: 2026-03-01 (UTC)

## 0. Current state snapshot

- Public domain `https://hatamotohq.com` is serving through URL map `hatamoto-em-url-map`.
- Current URL map weight is Cloud Run 100% (`hatamoto-em-cr-bs=100`, `hatamoto-em-vm-bs=0`).
- Cloud Run service is `hotel-insight-crm-prod`.
- Cloud Run env currently points to private IPs for:
  - MySQL (`DATABASE_HOST`: Cloud SQL private IP)
  - Redis (`REDIS_URL`: Memorystore private IP)
- `hotel-crm` VM is `TERMINATED` and still present in unmanaged instance group `hatamoto-prod-umig`.

## 1. Rollback and forward commands

Rollback to VM 100%:

```bash
script/ops/gcp_shift_url_map_traffic.sh \
  --project lucky-display-390005 \
  --url-map hatamoto-em-url-map \
  --to vm \
  --apply
```

Forward to Cloud Run 100%:

```bash
script/ops/gcp_shift_url_map_traffic.sh \
  --project lucky-display-390005 \
  --url-map hatamoto-em-url-map \
  --to cloud-run \
  --apply
```

Dry-run mode (safe preview) is default if `--apply` is omitted.

Note:

- 24-48h monitoring phase is already completed and the dedicated monitoring script was removed to avoid extra operational overhead.

## 2. VM dependency removal plan

### 2.1 Confirm no runtime dependency remains

Check app connection targets and traffic state:

```bash
gcloud run services describe hotel-insight-crm-prod \
  --region us-central1 \
  --project lucky-display-390005 \
  --format='yaml(spec.template.spec.containers[0].env)'

gcloud compute instance-groups unmanaged list-instances hatamoto-prod-umig \
  --zone us-central1-a \
  --project lucky-display-390005
```

Interpretation:

- If DB/Redis targets are Cloud SQL + Memorystore private IPs and stable for 48h,
  VM data dependency is effectively removed.
- If VM backend remains 0% and healthy operation continues, VM/LB cleanup can proceed.

### 2.2 Cleanup sequence after confirmation

1. Keep rollback window closed (traffic stable in Cloud Run for 48h).
2. Remove VM backend path from LB (or delete unused legacy LB stack).
3. Delete `hotel-crm` VM and unused unmanaged instance group.
4. Delete unused static external IP(s) and backend services tied to VM.
5. Re-check monthly run-rate from Billing.

## 3. Certificate cleanup

Status:

- Certificate unification already completed on 2026-03-01.
- Active cert: `hatamotohq-managed-cert-em`
- Legacy cert `hatamotohq-managed-cert` is already deleted.

If another legacy cert appears in the future, use:

```bash
script/ops/gcp_cert_cleanup.sh --help
```
