{...}: {
  flake.modules.homeManager.zed = {config, lib, pkgs, ...}: {
    options.features.dev.editors.zed.enable = lib.mkEnableOption "zed editor";

    config = lib.mkIf config.features.dev.editors.zed.enable {
      home.packages = [pkgs.zed-editor-fhs];
    };
  };
}
