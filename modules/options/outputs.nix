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
