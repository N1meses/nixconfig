{lib, ...}: {
  options.flake = lib.mkOption {
    default = {};
    type = lib.types.submoduleWith {
      modules = [{
        freeformType = lib.types.lazyAttrsOf lib.types.raw;   # any other output, as-is
        options = {
          modules = lib.mkOption {
            type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
            default = {};
            description = "akin to flake-parts' flake.modules";
          };
          nixosConfigurations = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.raw; default = {}; };
          finixConfigurations = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.raw; default = {}; };
          homeConfigurations  = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.raw; default = {}; };
          deploy              = lib.mkOption { type = lib.types.raw; default = {}; };
        };
      }];
    };
  };
}
