{lib, ...}: {
  options.fleet = lib.mkOption {
    default = {};
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        nixos = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = "Fragment spliced into every other NixOS host.";
        };
        finix = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = "Fragment spliced into every other finix host.";
        };
        home = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
          description = "Fragment spliced into every other host's home config.";
        };
      };
    });
  };
}
