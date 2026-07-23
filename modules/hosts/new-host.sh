#!/usr/bin/env bash
# new-host.sh <hostname>
# Run from the nixconfig root to scaffold a new host.
# If run on the target machine (NixOS installer), hardware config is generated automatically.
# Otherwise a placeholder is created — fill it in manually.

set -euo pipefail

HOSTNAME="${1:-}"
if [[ -z "$HOSTNAME" ]]; then
  echo "Usage: $0 <hostname>"
  exit 1
fi

NIXCONFIG_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
HOST_DIR="$NIXCONFIG_DIR/modules/hosts/$HOSTNAME"
CAP="$(echo "${HOSTNAME:0:1}" | tr '[:lower:]' '[:upper:]')${HOSTNAME:1}"

if [[ -d "$HOST_DIR" ]]; then
  echo "Error: $HOST_DIR already exists"
  exit 1
fi

mkdir -p "$HOST_DIR"

# --- hardware-configuration.nix ---
if command -v nixos-generate-config &>/dev/null && [[ -d /sys/firmware/efi ]]; then
  echo "Generating hardware config from this machine..."
  nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware-configuration.nix"
else
  cat > "$HOST_DIR/hardware-configuration.nix" << 'EOF'
# TODO: replace with output of:
#   nixos-generate-config --show-hardware-config
{ lib, ... }: {
  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  fileSystems."/" = { device = "/dev/disk/by-uuid/TODO"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/TODO"; fsType = "vfat"; options = [ "fmask=0077" "dmask=0077" ]; };
  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
}
EOF
fi

# --- hardware<Hostname>.nix (flake module wrapper) ---
cat > "$HOST_DIR/hardware${CAP}.nix" << EOF
{...}: {
  aspects.hardware.nixos${CAP} = import ./hardware-configuration.nix;
}
EOF

# --- disko<Hostname>.nix ---
cat > "$HOST_DIR/disko${CAP}.nix" << EOF
{...}: {
  aspects.disko.nixos${CAP} = {...}: {
    # TODO: configure disk layout
    # Examples: https://github.com/nix-community/disko/tree/master/example
    disko.devices = {
      disk.main = {
        device = "/dev/sda";  # TODO: set your disk (lsblk to find it)
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
EOF

# --- <hostname>.nix ---
cat > "$HOST_DIR/$HOSTNAME.nix" << EOF
{ config, inputs, ... }: {
  registry.hosts.$HOSTNAME = {
    username = "$HOSTNAME";
    system = "x86_64-linux";
    stateVersion = "25.11";
    # extraGroups = [];
    # hostId = "";  # for ZFS: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
    aspects = with config.aspectLib.names; [
      core
      shell
      users
      local
      git
      hardware${CAP}
      disko${CAP}
      # sops  # uncomment when using secrets (create secrets/$HOSTNAME.yaml; the sops aspect wires defaultSopsFile + keyFile)
      # TODO: add features
    ];

    nixosModule = { pkgs, ... }: {
      imports = [ inputs.disko.nixosModules.disko ];

      boot.kernelPackages = pkgs.linuxPackages_latest;
      environment.systemPackages = with pkgs; [ git wget ];
    };

    homeModule = { pkgs, ... }: {
      home.packages = with pkgs; [ ];
    };
  };
}
EOF

echo ""
echo "Scaffolded $HOST_DIR:"
echo "  hardware-configuration.nix  raw hardware config (edit if placeholder)"
echo "  hardware${CAP}.nix         flake module wrapper"
echo "  disko${CAP}.nix            disk layout (set device + layout)"
echo "  $HOSTNAME.nix              registry + NixOS + HM config"
echo ""
echo "Before installing:"
echo "  1. Edit disko${CAP}.nix    — set disk device"
echo "  2. Edit $HOSTNAME.nix      — fill registry, add features"
echo "  3. Add $HOSTNAME age key to .sops.yaml"
echo "  4. Create secrets/$HOSTNAME.yaml"
echo "  5. Commit and push"
echo ""
echo "Install (run on target from NixOS installer ISO):"
echo ""
echo "  # Clone config (needs network + git)"
echo "  nix --experimental-features 'nix-command flakes' shell nixpkgs#git -c \\"
echo "    git clone <your-nixconfig-url> /tmp/nixconfig"
echo ""
echo "  # Partition disks"
echo "  nix --experimental-features 'nix-command flakes' \\"
echo "    run github:nix-community/disko/latest -- --mode disko \\"
echo "    /tmp/nixconfig/modules/hosts/$HOSTNAME/disko${CAP}.nix"
echo ""
echo "  # Build the system closure (repo is flakeless)"
echo "  nix --experimental-features 'nix-command flakes' build \\"
echo "    -f /tmp/nixconfig nixosConfigurations.$HOSTNAME.config.system.build.toplevel"
echo ""
echo "  # Install"
echo "  nixos-install --system ./result"
