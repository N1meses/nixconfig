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
  pins.noctalia = {
    url = "https://github.com/noctalia-dev/noctalia";
    ref = "cachix";
    excludeFollow = [ "nixpkgs" ];
  };

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

  aspectLib.mkNoctaliaUmbriel = cmd: "spawn noctalia msg ${cmd}";

  aspects.desktop.noctalia = {
    description = "The noctalia desktop shell (bar, launcher, control centre).";
    includes = with config.aspectLib.aspectNames; [ desktop.compositors.compositors ];

    wrapper =
      { config, pkgs, ... }:
      {
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        env.NOCTALIA_CONFIG_HOME = "${pkgs.linkFarm "noctalia-config" [
          {
            name = "noctalia/settings.toml";
            path = config.xdg.config.files."noctalia/settings.toml".source;
          }
        ]}";
      };

    home =
      { pkgs, ... }:
      let
        builtinTemplates = "${
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        }/share/noctalia/assets/templates";
      in
      {
        imports = [
          flakeConfig.aspectLib.all."desktop.noctaliaSettings".home
        ];

        rum.programs.foot.settings.main.include = "~/.config/foot/themes/noctalia";

        # 5.4.1's built-in terminal templates pin the ANSI hues, so these replace them
        # (dropped from builtin_ids). Own output names: disabling a built-in runs its
        # undo.sh, which deletes themes/noctalia and themes/noctalia.conf.
        noctalia.settings.theme.templates.user = {
          ghostty-wallpaper = {
            input_path = "${./templates/ghostty}";
            output_path = "$XDG_CONFIG_HOME/ghostty/themes/noctalia-wallpaper";
            post_hook = "bash ${builtinTemplates}/ghostty/reload.sh";
          };
          kitty-wallpaper = {
            input_path = "${./templates/kitty.conf}";
            output_path = "$XDG_CONFIG_HOME/kitty/themes/noctalia-wallpaper.conf";
            post_hook = "pkill -USR1 kitty";
          };
        };

        features.compositors.autoStart = [ "noctalia" ];
      };
  };

}
