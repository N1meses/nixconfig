{
  inputs,
  config,
  lib,
  ...
}: let
  flakeConfig = config;
in {
  flake = {
    lib.mkNoctaliaNiri = cmd:
      ["noctalia" "msg"] ++ (lib.splitString " " cmd);

    lib.mkNoctaliaHypr = cmd: "exec, noctalia msg ${cmd}";

    lib.mkNoctaliaMango = cmd: "spawn, noctalia msg ${cmd}";

    modules = {
      nixos.noctalia = {pkgs, ...}: {
        nix.settings = {
          substituters = ["https://noctalia.cachix.org"];
          trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
        };

        environment.systemPackages = [
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };

      homeManager.noctalia = {...}: {
        imports = [
          inputs.noctalia.homeModules.default
          flakeConfig.flake.modules.homeManager.noctaliaSettings
        ];

        programs.niri.settings = {
          spawn-at-startup = [{argv = ["noctalia"];}];
          layer-rules = [
            {
              matches = [{namespace = "^noctalia-wallpaper.*";}];
              place-within-backdrop = true;
            }
          ];
        };
        wayland.windowManager.hyprland.settings.exec-once = ["noctalia"];

        features.compositors.mango.autoStart = ''
          noctalia
        '';

        programs.noctalia.enable = true;
      };
    };
  };
}
