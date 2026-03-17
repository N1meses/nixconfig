{ lib, ... }: {
  options.configurations = {
    nixos = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
          };
          hardware-configuration = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to hardware-configuration.nix";
          };
        };
      });
      default = {};
    };

    home-manager = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      });
      default = {};
      description = "Home-manager configuration compositions per host";
    };
  };
}
