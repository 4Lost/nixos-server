set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/build"

mkdir -p "$OUTPUT_DIR"
rm -f "${OUTPUT_DIR}/nixos-custom-lxc.tar.xz"

cd "$SCRIPT_DIR"

NIX_PATH="nixpkgs=$(nix-instantiate --find-file nixpkgs)" \
NIXOS_CONFIG="$SCRIPT_DIR/lxc-configuration.nix" \
  nixos-rebuild --no-flake build-image \
  --image-variant proxmox-lxc

IMAGE="$(find -L result -name '*.tar.xz' -type f -print -quit)"

if [[ -z "$IMAGE" ]]; then
  echo "No NixOS image found"
  exit 1
fi

cp "$IMAGE" "$OUTPUT_DIR/nixos-custom-lxc.tar.xz"

rm -f result
