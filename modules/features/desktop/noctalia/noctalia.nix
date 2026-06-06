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

        features.compositors.autoStart = ["noctalia"];

        wayland.windowManager.niri.settings.layer-rule = [
          {
            match._props.namespace._raw = ''r#"^noctalia-wallpaper.*"#'';
            place-within-backdrop = true;
          }
        ];

        programs.noctalia.enable = true;
      };
    };
  };
}
