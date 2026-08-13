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
    };
    finixConfigurations = lib.mkOption {
      type = raws;
      default = { };
    };
    homeConfigurations = lib.mkOption {
      type = raws;
      default = { };
    };
    containers = lib.mkOption {
      type = raws;
      default = { };
      description = "containers.<name> — OCI application images; run the result and pipe into docker/podman load.";
    };
    images = lib.mkOption {
      type = raws;
      default = { };
      description = "images.<host>.<format> — the host, built for a target other than its own machine.";
    };
    resolved = lib.mkOption {
      type = raws;
      default = { };
      description = "Per-host answer to 'what did this host's aspect list actually resolve to'.";
    };
    diskoConfigurations = lib.mkOption {
      type = raws;
      default = { };
    };
    checks = lib.mkOption {
      type = raws;
      default = { };
    };
    packages = lib.mkOption {
      type = raws;
      default = { };
    };
    deploy = lib.mkOption {
      type = t.raw;
      default = { };
    };
  };
}
