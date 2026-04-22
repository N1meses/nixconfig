{
  inputs,
  config,
  lib,
  ...
}: let
  flakeConfig = config;
in {
  flake.lib.mkNoctaliaNiri = cmd:
    ["noctalia-shell" "ipc" "call"] ++ (lib.splitString " " cmd);

  flake.lib.mkNoctaliaHypr = cmd: "exec, noctalia-shell ipc call ${cmd}";

  flake.modules = {
    nixos.noctalia = {...}: {
      nix.settings = {
        substituters = ["https://noctalia.cachix.org"];
        trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager.noctalia = {...}: {
      imports = [
        inputs.noctalia.homeModules.default
        flakeConfig.flake.modules.homeManager.noctaliaSettings
      ];

      programs.niri.settings = {
        spawn-at-startup = [{argv = ["noctalia-shell"];}];
        layer-rules = [
          {
            matches = [{namespace = "^noctalia-wallpaper.*";}];
            place-within-backdrop = true;
          }
        ];
      };
      wayland.windowManager.hyprland.settings.exec-once = ["noctalia-shell"];

      features.compositors.mango.autoStart = ''
        noctalia-shell &
      '';

      programs.noctalia-shell.enable = true;
    };
  };
}
