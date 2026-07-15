{
  inputs,
  config,
  lib,
  ...
}: let
  flakeConfig = config;
in {
    aspectLib.mkNoctaliaNiri = cmd:
      ["noctalia" "msg"] ++ (lib.splitString " " cmd);

    aspectLib.mkNoctaliaHypr = cmd: "exec, noctalia msg ${cmd}";

    aspectLib.mkNoctaliaMango = cmd: "spawn, noctalia msg ${cmd}";

    aspects.noctalia.includes = with config.aspectLib.names; [compositors];

    aspects.noctalia = {
      home = {pkgs, ...}: {
        imports = [
          inputs.noctalia.homeModules.default
          flakeConfig.aspects.noctaliaSettings.home
        ];

        home.packages = [
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        programs.foot.settings.main.include = "~/.config/foot/themes/noctalia";

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
}
