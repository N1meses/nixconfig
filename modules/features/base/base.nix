{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.base = {...}: {
    imports = with flakeConfig.flake.modules.nixos; [
      cachyosKernel
      local
    ];
  };
}
