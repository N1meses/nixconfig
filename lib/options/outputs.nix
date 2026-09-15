{ lib, ... }:
let
  raws = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
in
{
  options = {
    nixosConfigurations = raws // {
      description = "Buildable NixOS systems, keyed by hostname.";
    };
    finixConfigurations = raws // {
      description = "Buildable finix systems, keyed by hostname.";
    };
    homeConfigurations = raws // {
      description = "Standalone hjem manifests, keyed by hostname then username.";
    };
    diskoConfigurations = raws // {
      description = "Disk layouts for one-shot partitioning at install time.";
    };
  };
}
