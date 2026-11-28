path="$(git rev-parse --show-toplevel)"
cd "$path" || exit
mkdir -p backup

import_host() {
  local vmId="$1"
  local service="$2"

  echo -e "\033[4m${service}\033[0m"
  ssh -n "elias@192.168.0.${vmId}" 'mkdir -p /home/elias/backup'
  scp -r "./backup/${service}/." "elias@192.168.0.${vmId}:/home/elias/backup/"

  ssh -n "elias@192.168.0.${vmId}" '/home/elias/import.sh'
  echo ""
}

tar -xf backup-server.tar.xz

if [[ $# -eq 0 ]]; then
  # All hosts
  while IFS=$'\t' read -r vmId service; do
    import_host "$vmId" "$service"
  done < <(jq -r 'to_entries[] | [.key, .value] | @tsv' "$HOSTS_FILE")
else
  # Only selected
  for service in "$@"; do
    vmId=$(jq -r --arg service "$service" 'to_entries[] | select(.value == $service) | .key' "$HOSTS_FILE")

    if [[ -z "$vmId" ]]; then
      echo "Unknown service: $service"
      exit 1
    fi

    import_host "$vmId" "$service"
  done
fi

rm -r backup
