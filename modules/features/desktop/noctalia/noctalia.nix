{
  inputs,
  config,
  lib,
  ...
}:
let
  flakeConfig = config;
in
{
  aspectLib.mkNoctaliaNiri =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (lib.splitString " " cmd);

  aspectLib.mkNoctaliaHypr =
    keys: cmd: ''hl.bind("${keys}", hl.dsp.exec_cmd("noctalia msg ${cmd}"))'';

  aspectLib.mkNoctaliaMango = cmd: "spawn, noctalia msg ${cmd}";

  aspectLib.mkNoctaliaHalley = cmd: "noctalia msg ${cmd}";

  aspects.desktop.noctalia = {
    description = "The noctalia desktop shell (bar, launcher, control centre).";
    includes = with config.aspectLib.names; [ desktop.compositors.compositors ];
    home = { pkgs, ... }: {
      imports = [
        flakeConfig.aspectLib.all."desktop.noctaliaSettings".home
      ];

      packages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      rum.programs.foot.settings.main.include = "~/.config/foot/themes/noctalia";

      features.compositors.autoStart = [ "noctalia" ];

      features.compositors.niri.extraConfig = [
        ''
          layer-rule {
            match namespace=r#"^noctalia-wallpaper.*"#
            place-within-backdrop true
          }
        ''
      ];
    };
  };

}
