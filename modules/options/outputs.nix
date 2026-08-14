{ lib, ... }:
let
  t = lib.types;
  raws = t.lazyAttrsOf t.raw;
in
{
  options = {
    nixosConfigurations = lib.mkOption {
      type = raws;
      default = { };
      description = "nixosConfigurations.<host> - a NixOS system, as `nixos-rebuild --file . --attr` and deploy-rs expect it.";
    };
    finixConfigurations = lib.mkOption {
      type = raws;
      default = { };
      description = "finixConfigurations.<host> - the same, for a finix system (finit as pid 1). Built the same way; not a deploy-rs target.";
    };
    homeConfigurations = lib.mkOption {
      type = raws;
      default = { };
      description = "homeConfigurations.<host>.<user> - that user's hjem file manifest and package list on their own, without the system around them.";
    };
    containers = lib.mkOption {
      type = raws;
      default = { };
      description = "containers.<name> - OCI application images; run the result and pipe into docker/podman load.";
    };
    images = lib.mkOption {
      type = raws;
      default = { };
      description = "images.<host>.<format> - the host, built for a target other than its own machine.";
    };
    resolved = lib.mkOption {
      type = raws;
      default = { };
      description = "Per-host answer to 'what did this host's aspect list actually resolve to'.";
    };
    diskoConfigurations = lib.mkOption {
      type = raws;
      default = { };
      description = "diskoConfigurations.<host> - the disk layout in the shape disko's CLI wants, for one-shot partitioning at install time. Reads the same `_devices.nix` the host's `_disko.nix` derives its `fileSystems` from, so the two cannot drift.";
    };
    checks = lib.mkOption {
      type = raws;
      default = { };
      description = "checks.<name> - everything CI builds: `nixos-<host>`, `finix-<host>`, `hjem-<host>` (each generated dotfile fed to its own parser) and `docs` (MODULES.md is current).";
    };
    devShells = lib.mkOption {
      type = raws;
      default = { };
      description = "devShells.<system>.default - the maintenance shell; entered with `nix develop` or `nix-shell`.";
    };
    packages = lib.mkOption {
      type = raws;
      default = { };
      description = "packages.<name> - build artifacts that are not a host: the generated `docs`, and `vm-<host>` interactive test VMs.";
    };
    deploy = lib.mkOption {
      type = t.raw;
      default = { };
      description = "deploy.nodes.<host> - the node set deploy-rs reads, one per NixOS host. Not keyed like the rest because deploy-rs wants the whole tree.";
    };
  };
}
