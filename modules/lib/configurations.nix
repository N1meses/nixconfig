{ lib, ... }: {
  options.configurations = {
    nixos = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          module = lib.mkOption {
            type = lib.types.deferredModule;
          };
        };
      });
      default = {};
      description = "Nixos configuration compositions per host";
    };

    homeManager = lib.mkOption {
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
