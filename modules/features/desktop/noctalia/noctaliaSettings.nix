{
  inputs,
  lib,
  ...
}: let
  mkDefaults = val:
    if lib.isAttrs val && !lib.isDerivation val
    then lib.mapAttrs (_: mkDefaults) val
    else lib.mkDefault val;
in {
  aspects.noctaliaSettings.home = {
    config,
    lib,
    ...
  }: let
    flakeRoot = inputs.self;
    tomlSettings = fromTOML (builtins.readFile ./noctalia-config.toml);
  in {
    config = lib.mkMerge [
      {
        programs.noctalia.settings = mkDefaults tomlSettings;
      }
      {
        programs.noctalia.settings = {
          shell.avatar_path = "${flakeRoot}/assets/icons/hunter.jpeg";
          shell.screenshot.directory = "${config.xdg.userDirs.pictures}/Screenshots";
          wallpaper.directory = "${config.xdg.userDirs.pictures}/Wallpapers";

          widget.control-center = {
            custom_image = "${flakeRoot}/assets/icons/nixos.png";
          };
        };
      }
    ];
  };
}
