#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-lucky-display-390005}"
DATASET_ID="${DATASET_ID:-billing_export}"
LOCATION="${LOCATION:-US}"
TZ="${TZ:-Asia/Tokyo}"

usage() {
  cat <<USAGE
Usage:
  gcp_billing_cost_report.sh [options]

Options:
  --project <id>     GCP project id that contains billing export dataset (default: ${PROJECT_ID})
  --dataset <id>     BigQuery dataset id for billing export (default: ${DATASET_ID})
  --location <loc>   BigQuery location (default: ${LOCATION})
  --tz <timezone>    Timezone used for month/day boundaries (default: ${TZ})
  -h, --help         Show this help

Examples:
  script/ops/gcp_billing_cost_report.sh
  script/ops/gcp_billing_cost_report.sh --project lucky-display-390005 --dataset billing_export
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_ID="$2"
      shift 2
      ;;
    --dataset)
      DATASET_ID="$2"
      shift 2
      ;;
    --location)
      LOCATION="$2"
      shift 2
      ;;
    --tz)
      TZ="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

TABLE_NAME="$(bq query --location="${LOCATION}" --use_legacy_sql=false --format=csv --quiet \
  "SELECT table_name
   FROM \`${PROJECT_ID}.${DATASET_ID}.INFORMATION_SCHEMA.TABLES\`
   WHERE table_name LIKE 'gcp_billing_export_v1_%'
   ORDER BY creation_time DESC
   LIMIT 1" | tail -n +2 | tr -d '\r')"

if [[ -z "${TABLE_NAME}" ]]; then
  echo "No billing export table found in ${PROJECT_ID}.${DATASET_ID}." >&2
  echo "Expected a table like gcp_billing_export_v1_*." >&2
  echo "Enable Cloud Billing export to BigQuery in Billing Console first." >&2
  exit 2
fi

FULL_TABLE="${PROJECT_ID}.${DATASET_ID}.${TABLE_NAME}"

QUERY="
WITH params AS (
  SELECT
    CURRENT_DATE('${TZ}') AS today,
    DATE_TRUNC(CURRENT_DATE('${TZ}'), MONTH) AS this_month_start,
    DATE_TRUNC(DATE_SUB(CURRENT_DATE('${TZ}'), INTERVAL 1 MONTH), MONTH) AS prev_month_start
),
agg AS (
  SELECT
    DATE(usage_start_time, '${TZ}') AS usage_date,
    SUM(cost) AS gross_cost,
    SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits) c), 0)) AS credits,
    SUM(cost) + SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits) c), 0)) AS net_cost
  FROM \`${FULL_TABLE}\`
  WHERE cost_type != 'tax'
  GROUP BY usage_date
),
ranges AS (
  SELECT
    p.*,
    DATE_DIFF(today, this_month_start, DAY) + 1 AS elapsed_days,
    DATE_SUB(DATE_ADD(prev_month_start, INTERVAL 1 MONTH), INTERVAL 1 DAY) AS prev_month_end,
    DATE_SUB(DATE_ADD(this_month_start, INTERVAL 1 MONTH), INTERVAL 1 DAY) AS this_month_end
  FROM params p
),
calc AS (
  SELECT
    r.today,
    r.this_month_start,
    r.prev_month_start,
    r.prev_month_end,
    r.this_month_end,
    r.elapsed_days,

    IFNULL((SELECT SUM(net_cost) FROM agg WHERE usage_date BETWEEN r.this_month_start AND r.today), 0) AS this_month_mtd_net,
    IFNULL((SELECT SUM(net_cost) FROM agg WHERE usage_date BETWEEN r.prev_month_start AND DATE_ADD(r.prev_month_start, INTERVAL r.elapsed_days - 1 DAY)), 0) AS prev_month_same_days_net,
    IFNULL((SELECT SUM(net_cost) FROM agg WHERE usage_date BETWEEN r.prev_month_start AND r.prev_month_end), 0) AS prev_month_full_net,

    IFNULL((SELECT SUM(gross_cost) FROM agg WHERE usage_date BETWEEN r.this_month_start AND r.today), 0) AS this_month_mtd_gross,
    IFNULL((SELECT SUM(credits) FROM agg WHERE usage_date BETWEEN r.this_month_start AND r.today), 0) AS this_month_mtd_credits
  FROM ranges r
)
SELECT
  today,
  this_month_start,
  prev_month_start,
  elapsed_days,
  ROUND(this_month_mtd_gross, 2) AS this_month_mtd_gross,
  ROUND(this_month_mtd_credits, 2) AS this_month_mtd_credits,
  ROUND(this_month_mtd_net, 2) AS this_month_mtd_net,
  ROUND(prev_month_same_days_net, 2) AS prev_month_same_days_net,
  ROUND(prev_month_full_net, 2) AS prev_month_full_net,
  ROUND(SAFE_DIVIDE(this_month_mtd_net, elapsed_days), 2) AS this_month_daily_avg,
  ROUND(SAFE_DIVIDE(prev_month_same_days_net, elapsed_days), 2) AS prev_month_daily_avg_same_window,
  ROUND(SAFE_DIVIDE(this_month_mtd_net, NULLIF(prev_month_same_days_net, 0)) * 100 - 100, 2) AS mtd_vs_prev_same_days_pct,
  ROUND(SAFE_DIVIDE(this_month_mtd_net, elapsed_days) * EXTRACT(DAY FROM this_month_end), 2) AS this_month_forecast_net
FROM calc
"

echo "Billing export table: ${FULL_TABLE}"
echo

bq query --location="${LOCATION}" --use_legacy_sql=false --format=pretty "${QUERY}"
