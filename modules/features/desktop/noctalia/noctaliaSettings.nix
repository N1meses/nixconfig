{
  inputs,
  lib,
  ...
}:
let
  mkDefaults =
    val:
    if lib.isAttrs val && !lib.isDerivation val then
      lib.mapAttrs (_: mkDefaults) val
    else
      lib.mkDefault val;
in
{
  aspects.desktop.noctaliaSettings = {
    description = "Declarative noctalia settings, generated per host.";
    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        tomlSettings = fromTOML (builtins.readFile ./noctalia-config.toml);
      in
      {
        options.noctalia.settings = lib.mkOption {
          type = (pkgs.formats.toml { }).type;
          default = { };
          description = "noctalia settings, serialized to ~/.config/noctalia/settings.toml";
        };

        config = {
          noctalia.settings = lib.mkMerge [
            (mkDefaults tomlSettings)
            {
              shell.avatar_path = "${inputs.self}/assets/icons/hunter.jpeg";
              shell.screenshot.directory = "${config.directory}/Pictures/Screenshots";
              wallpaper.directory = "${config.directory}/Pictures/Wallpapers";
              widget.control-center.custom_image = "${inputs.self}/assets/icons/nixos.png";
            }
          ];

          xdg.config.files."noctalia/settings.toml".source =
            (pkgs.formats.toml { }).generate "noctalia-settings"
              config.noctalia.settings;
        };
      };
  };
}
