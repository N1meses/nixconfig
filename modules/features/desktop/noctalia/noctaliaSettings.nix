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
  flake.modules.homeManager.noctaliaSettings = {
    config,
    lib,
    ...
  }: let
    flakeRoot = inputs.self;
    jsonSettings = builtins.fromJSON (builtins.readFile ./noctaliaSettings.json);
  in {
    config = lib.mkMerge [
      {
        programs.noctalia-shell.settings = mkDefaults jsonSettings;
      }
      {
        programs.noctalia-shell.settings = {
          general.avatarImage = "${flakeRoot}/assets/icons/hunter.jpeg";

          bar.widgets.left = [
            {
              customIconPath = "${flakeRoot}/assets/icons/nixos.png";
              icon = "NixOS";
              id = "ControlCenter";
              useDistroLogo = false;
            }
            {id = "Tray";}
            {id = "plugin:simple-notes";}
            {id = "plugin:todo";}
            {id = "TaskbarGrouped";}
          ];

          screenRecorder.directory = config.xdg.userDirs.videos;
          wallpaper.defaultWallpaper = "${config.xdg.userDirs.pictures}/Wallpapers/wallhaven_6oeexx.jpg";
          wallpaper.directory = "${config.xdg.userDirs.pictures}/Wallpapers";
        };
      }
    ];
  };
}
