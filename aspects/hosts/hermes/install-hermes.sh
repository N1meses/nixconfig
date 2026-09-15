#!/usr/bin/env bash
set -euo pipefail

DISK=${1:-/dev/sda}
MNT=/mnt

die() { echo "error: $*" >&2; exit 1; }

[[ -b "$DISK" ]] || die "$DISK is not a block device"

PART_ESP="${DISK}2"
PART_NIX="${DISK}3"
PART_PERSIST="${DISK}4"

echo "==> Tearing down any existing mounts on $MNT"
umount -R "$MNT" 2>/dev/null || true
cryptsetup close persist 2>/dev/null || true

echo "==> Mounting filesystems"
mount -t tmpfs -o size=50%,mode=755 none "$MNT"
mkdir -p "$MNT"/{boot,nix,persist}
mount "$PART_NIX" "$MNT/nix"
if [[ ! -b /dev/mapper/persist ]]; then
    cryptsetup open "$PART_PERSIST" persist
else
    echo "    /dev/mapper/persist already open, skipping"
fi
mount /dev/mapper/persist "$MNT/persist"
mount "$PART_ESP" "$MNT/boot"

echo "==> Current mounts under $MNT"
mount | grep "$MNT"

echo "==> Running nixos-install"
nixos-install --flake .#hermes --no-root-passwd

echo "==> Done. Unmount with:"
echo "    sudo umount -R $MNT && sudo cryptsetup close persist"
