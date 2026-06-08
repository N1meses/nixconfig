{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.cachyosKernel = {...}: {
    imports = [flakeConfig.flake.modules.nixos.overlays];

    nix.settings = {
      substituters = ["https://attic.xuyh0120.win/lantian"];
      trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
    };
  };
}
