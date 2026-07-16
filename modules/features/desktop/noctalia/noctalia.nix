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

  aspects.noctalia.includes = with config.aspectLib.names; [ compositors ];

  aspects.noctalia.home = { pkgs, ... }: {
    imports = [
      flakeConfig.aspects.noctaliaSettings.home
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
}
