#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-$(gcloud config get-value project 2>/dev/null || true)}"
ACTIVE_CERT="hatamotohq-managed-cert-em"
OLD_CERT="hatamotohq-managed-cert"
APPLY="false"

usage() {
  cat <<'USAGE'
Usage:
  gcp_cert_cleanup.sh [options]

Options:
  --project <id>         GCP project id
  --active-cert <name>   Active managed cert to keep (default: hatamotohq-managed-cert-em)
  --old-cert <name>      Cert to detach/delete (default: hatamotohq-managed-cert)
  --apply                Apply changes (default: dry-run)
  -h, --help             Show this help

Behavior:
  1) Find target HTTPS proxies currently using old cert.
  2) Update those proxies to use active cert.
  3) Delete old cert only after it is no longer attached.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --active-cert) ACTIVE_CERT="$2"; shift 2 ;;
    --old-cert) OLD_CERT="$2"; shift 2 ;;
    --apply) APPLY="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$PROJECT" ]]; then
  echo "--project is required" >&2
  exit 1
fi

command -v gcloud >/dev/null 2>&1 || { echo "missing command: gcloud" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "missing command: jq" >&2; exit 1; }

active_status="$(gcloud compute ssl-certificates describe "$ACTIVE_CERT" --global --project="$PROJECT" --format='value(managed.status)' 2>/dev/null || true)"
if [[ "$active_status" != "ACTIVE" ]]; then
  echo "active cert is not ACTIVE: ${ACTIVE_CERT} (status=${active_status:-N/A})" >&2
  exit 1
fi

proxies_str="$(
  gcloud compute target-https-proxies list --project="$PROJECT" --format=json \
    | jq -r --arg old "$OLD_CERT" '.[] | select((.sslCertificates // []) | map(split("/")[-1]) | index($old)) | .name'
)"
proxies=()
while IFS= read -r line; do
  [[ -n "$line" ]] && proxies+=("$line")
done <<<"$proxies_str"

if [[ "${#proxies[@]}" -eq 0 ]]; then
  echo "no target HTTPS proxy uses ${OLD_CERT}"
else
  echo "proxies using ${OLD_CERT}:"
  printf '  %s\n' "${proxies[@]}"
fi

if [[ "$APPLY" == "true" ]]; then
  for p in "${proxies[@]}"; do
    gcloud compute target-https-proxies update "$p" \
      --project="$PROJECT" \
      --ssl-certificates="$ACTIVE_CERT" >/dev/null
    echo "updated proxy ${p} -> ${ACTIVE_CERT}"
  done

  still_used="$(gcloud compute target-https-proxies list --project="$PROJECT" --format=json | jq -r --arg old "$OLD_CERT" '[.[] | select((.sslCertificates // []) | map(split("/")[-1]) | index($old))] | length')"
  if [[ "$still_used" -eq 0 ]]; then
    gcloud compute ssl-certificates delete "$OLD_CERT" --global --project="$PROJECT" --quiet >/dev/null
    echo "deleted cert ${OLD_CERT}"
  else
    echo "skip delete: ${OLD_CERT} is still attached to ${still_used} proxy(s)" >&2
    exit 1
  fi
else
  echo "dry-run only. add --apply to execute."
fi
