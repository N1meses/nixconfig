#!/usr/bin/env bash
# new-host.sh <hostname> [nixos|finix]
# Run from anywhere in the repo to scaffold a new host.
# If run on the target machine, hardware config is generated automatically.
# Otherwise a placeholder is created - fill it in manually.

set -euo pipefail

HOSTNAME="${1:-}"
CLASS="${2:-nixos}"
if [[ -z "$HOSTNAME" ]]; then
  echo "Usage: $0 <hostname> [nixos|finix]"
  exit 1
fi
if [[ "$CLASS" != nixos && "$CLASS" != finix ]]; then
  echo "Error: class must be 'nixos' or 'finix', got '$CLASS'"
  exit 1
fi

NIXCONFIG_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
HOST_DIR="$NIXCONFIG_DIR/modules/hosts/$HOSTNAME"

if [[ -d "$HOST_DIR" ]]; then
  echo "Error: $HOST_DIR already exists"
  exit 1
fi

mkdir -p "$HOST_DIR"

# Machine modules are `_`-prefixed so the top-level eval skips them; they are
# reached only through machineModules, which is what lets machine-less builds
# (VMs, images) drop them wholesale.

if command -v nixos-generate-config &>/dev/null && [[ -d /sys/firmware/efi ]]; then
  echo "Generating hardware config from this machine..."
  nixos-generate-config --show-hardware-config >"$HOST_DIR/_hardware.nix"
else
  cat >"$HOST_DIR/_hardware.nix" <<'EOF'
# TODO: replace with the output of:
#   nixos-generate-config --show-hardware-config
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/TODO";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/TODO";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
}
EOF
fi

cat >"$HOST_DIR/$HOSTNAME.nix" <<EOF
{ config, ... }:
{
  registry.hosts.$HOSTNAME = {
    machineModules = [
      ./_hardware.nix
      ../_uefi-systemd-boot.nix
      # ./_disko.nix          # if this host partitions its own disks
    ];
    users = with config.registry.userNames; [ $HOSTNAME ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    # extraGroups = [ ];
    # domain = "";            # primary FQDN if it serves anything
    # hostId = "";            # for ZFS: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '

    # Reaches the system layer only - the .$CLASS slot of each aspect.
    # Home slots come from registry.users.$HOSTNAME.aspects instead.
    aspects = with config.aspectLib.names; [
      bundle.base
      # bundle.server / bundle.workstation, then extras
    ];

    ${CLASS}Module =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ ];
      };
  };
}
EOF

cat >"$NIXCONFIG_DIR/modules/users/$HOSTNAME.nix" <<EOF
{ config, ... }:
{
  registry.users.$HOSTNAME = {
    # keys = [ ];             # authorized ssh keys
    aspects = with config.aspectLib.names; [
      bundle.cliEnv
    ];

    homeModule =
      { pkgs, ... }:
      {
        packages = with pkgs; [ ];
      };
  };
}
EOF

cat <<EOF

Scaffolded:
  modules/hosts/$HOSTNAME/_hardware.nix   raw hardware config (edit if placeholder)
  modules/hosts/$HOSTNAME/$HOSTNAME.nix   registry host entry + $CLASS slot
  modules/users/$HOSTNAME.nix             registry user entry + home slot

Next:
  1. Edit $HOSTNAME.nix   - aspects, machineModules, stateVersion
  2. Add _disko.nix       - if this host partitions its own disks
  3. Add the $HOSTNAME age key to .sops.yaml, create secrets/$HOSTNAME.yaml (nixos only)
  4. nix eval --file . --json resolved.$HOSTNAME   - check what it resolved to
  5. nix-build . --attr checks.$CLASS-$HOSTNAME --no-out-link
EOF
