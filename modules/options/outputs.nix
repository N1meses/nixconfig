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
