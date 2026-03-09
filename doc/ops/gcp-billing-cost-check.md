# GCP Billing Cost Check

## Purpose
Measure whether GCP cost has been reduced by comparing current month-to-date (MTD) against previous month.

## 1) One-time setup (Billing Export)
Cloud Billing export to BigQuery must be enabled once in Google Cloud Console.

1. Open Billing Console and select billing account `011631-5BE168-D79C40`.
2. Go to `Billing export`.
3. Enable `Detailed usage cost` (or at least `Standard usage cost`).
4. Export destination:
   - Project: `lucky-display-390005`
   - Dataset: `billing_export` (US)

After enabling export, table(s) like `gcp_billing_export_v1_*` will appear in BigQuery.

## 2) Run report

```bash
script/ops/gcp_billing_cost_report.sh
```

Optional flags:

```bash
script/ops/gcp_billing_cost_report.sh \
  --project lucky-display-390005 \
  --dataset billing_export \
  --location US \
  --tz Asia/Tokyo
```

## 3) Read output
Main fields:
- `this_month_mtd_net`: Current month net cost (gross + credits)
- `prev_month_same_days_net`: Previous month net cost for the same elapsed day window
- `mtd_vs_prev_same_days_pct`: Reduction/increase vs previous month same window
- `this_month_forecast_net`: End-of-month forecast based on current daily average

Interpretation:
- Negative `mtd_vs_prev_same_days_pct` means cost is reduced.
- Positive value means cost is increased.
