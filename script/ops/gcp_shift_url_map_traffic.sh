#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-$(gcloud config get-value project 2>/dev/null || true)}"
URL_MAP="hatamoto-em-url-map"
VM_BACKEND="hatamoto-em-vm-bs"
CR_BACKEND="hatamoto-em-cr-bs"
TARGET=""
APPLY="false"

usage() {
  cat <<'USAGE'
Usage:
  gcp_shift_url_map_traffic.sh [options]

Options:
  --project <id>        GCP project id
  --url-map <name>      URL map name (default: hatamoto-em-url-map)
  --vm-backend <name>   Backend service name for VM (default: hatamoto-em-vm-bs)
  --cr-backend <name>   Backend service name for Cloud Run (default: hatamoto-em-cr-bs)
  --to <vm|cloud-run>   Traffic target
  --apply               Apply changes (default: dry-run)
  -h, --help            Show this help

Examples:
  # Dry run
  gcp_shift_url_map_traffic.sh --project lucky-display-390005 --to vm

  # Apply rollback (VM 100%)
  gcp_shift_url_map_traffic.sh --project lucky-display-390005 --to vm --apply

  # Apply forward (Cloud Run 100%)
  gcp_shift_url_map_traffic.sh --project lucky-display-390005 --to cloud-run --apply
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --url-map) URL_MAP="$2"; shift 2 ;;
    --vm-backend) VM_BACKEND="$2"; shift 2 ;;
    --cr-backend) CR_BACKEND="$2"; shift 2 ;;
    --to) TARGET="$2"; shift 2 ;;
    --apply) APPLY="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$PROJECT" || -z "$TARGET" ]]; then
  echo "--project and --to are required" >&2
  usage
  exit 1
fi

if [[ "$TARGET" != "vm" && "$TARGET" != "cloud-run" ]]; then
  echo "--to must be vm or cloud-run" >&2
  exit 1
fi

command -v gcloud >/dev/null 2>&1 || { echo "missing command: gcloud" >&2; exit 1; }
command -v ruby >/dev/null 2>&1 || { echo "missing command: ruby" >&2; exit 1; }

TMP_FILE="$(mktemp /tmp/${URL_MAP}.XXXXXX.yaml)"
trap 'rm -f "$TMP_FILE"' EXIT

gcloud compute url-maps export "$URL_MAP" \
  --global \
  --project="$PROJECT" \
  --destination="$TMP_FILE" >/dev/null

ruby - "$TMP_FILE" "$TARGET" "$VM_BACKEND" "$CR_BACKEND" <<'RUBY'
require "yaml"

path, target, vm_backend, cr_backend = ARGV
data = YAML.load_file(path)
wbs = data.dig("defaultRouteAction", "weightedBackendServices")
raise "defaultRouteAction.weightedBackendServices is missing" if wbs.nil? || wbs.empty?

vm_weight = (target == "vm" ? 100 : 0)
cr_weight = (target == "cloud-run" ? 100 : 0)
found_vm = false
found_cr = false

wbs.each do |entry|
  name = entry.fetch("backendService").split("/").last
  if name == vm_backend
    entry["weight"] = vm_weight
    found_vm = true
  elsif name == cr_backend
    entry["weight"] = cr_weight
    found_cr = true
  end
end

raise "VM backend not found: #{vm_backend}" unless found_vm
raise "Cloud Run backend not found: #{cr_backend}" unless found_cr

File.write(path, YAML.dump(data))
RUBY

echo "planned backend weights:"
ruby - "$TMP_FILE" <<'RUBY'
require "yaml"
data = YAML.load_file(ARGV[0])
wbs = data.dig("defaultRouteAction", "weightedBackendServices") || []
wbs.each do |entry|
  name = entry.fetch("backendService").split("/").last
  puts "  #{name}=#{entry.fetch("weight")}"
end
RUBY

if [[ "$APPLY" == "true" ]]; then
  gcloud compute url-maps import "$URL_MAP" \
    --global \
    --project="$PROJECT" \
    --source="$TMP_FILE" >/dev/null
  echo "applied: ${URL_MAP} switched to ${TARGET}"
else
  echo "dry-run only. add --apply to execute."
fi

