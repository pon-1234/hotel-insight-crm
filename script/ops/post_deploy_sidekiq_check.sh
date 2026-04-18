#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://hatamotohq.com}"
SIDEKIQ_USER="${SIDEKIQ_USER:-admin}"
SIDEKIQ_PASS="${SIDEKIQ_PASS:-kguYpVeUWEe57y7P}"
WORKER_SERVICE="${WORKER_SERVICE:-hotel-insight-crm-worker-prod}"
REGION="${REGION:-us-central1}"

echo "[1/4] Check Cloud Run worker service exists and is ready..."
READY_REV="$(gcloud run services describe "$WORKER_SERVICE" --region="$REGION" --format='value(status.latestReadyRevisionName)' 2>/dev/null || true)"
if [[ -z "$READY_REV" ]]; then
  echo "ERROR: Worker service '$WORKER_SERVICE' is not ready or not found." >&2
  exit 1
fi
echo "OK: latest ready revision = $READY_REV"

echo "[2/4] Fetch Sidekiq dashboard..."
HTML="$(curl -fsS -u "$SIDEKIQ_USER:$SIDEKIQ_PASS" "$BASE_URL/sidekiq")"
BUSY_HTML="$(curl -fsS -u "$SIDEKIQ_USER:$SIDEKIQ_PASS" "$BASE_URL/sidekiq/busy")"

echo "[3/4] Validate Sidekiq worker/process status..."
PROCESSES="$(echo "$HTML" | perl -0777 -ne 'if (/<p>Processes<\/p>\s*<\/div>\s*<div class="col-sm-2">\s*<h3>(\d+)<\/h3>/s) { print $1 }')"
if [[ -z "$PROCESSES" ]]; then
  PROCESSES="$(echo "$BUSY_HTML" | perl -0777 -ne 'if (/<h3>(\d+)<\/h3>\s*<p>Processes<\/p>/s) { print $1 }')"
fi
if [[ -z "$PROCESSES" || "$PROCESSES" -lt 1 ]]; then
  echo "ERROR: Sidekiq process count invalid: ${PROCESSES:-N/A}" >&2
  exit 1
fi
if echo "$HTML" | rg -q 'status-active'; then
  echo "OK: sidekiq status=active"
elif echo "$HTML" | rg -q 'status-idle'; then
  echo "OK: sidekiq status=idle"
else
  echo "WARN: could not determine sidekiq status from dashboard"
fi
echo "OK: processes=$PROCESSES"

echo "[4/4] Check enqueued count (warning-only if > 0)..."
ENQUEUED="$(echo "$HTML" | perl -0777 -ne 'if (/<span class="count">(\d+)<\/span>\s*<span class="desc">Enqueued<\/span>/s) { print $1 }')"
if [[ -z "$ENQUEUED" ]]; then
  echo "WARN: could not parse enqueued count"
else
  echo "Enqueued=$ENQUEUED"
  if [[ "$ENQUEUED" -gt 0 ]]; then
    echo "WARN: enqueued jobs remain after deploy"
  fi
fi

echo "PASS: post deploy sidekiq check completed"
