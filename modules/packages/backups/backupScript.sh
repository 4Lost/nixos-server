path="$(git rev-parse --show-toplevel)"
cd "$path" || exit
mkdir -p backup

cat "$HOSTS_FILE"

backup_host() {
  local vmId="$1"
  local service="$2"

  echo -e "\033[4m${service}\033[0m"
  ssh -n "elias@192.168.0.${vmId}" '/home/elias/backup.sh'

  mkdir "backup/${service}"
  scp -r "elias@192.168.0.${vmId}:/home/elias/backup/*" "./backup/${service}/"

  ssh -n "elias@192.168.0.${vmId}" 'rm -r /home/elias/backup'
}

while IFS=$'\t' read -r vmId service; do
  backup_host "$vmId" "$service"
done < <(jq -r 'to_entries[] | [.key, .value] | @tsv' "$HOSTS_FILE")

tar -cJf "backup-server-$(date +%F).tar.xz" ./backup

rm -r backup
