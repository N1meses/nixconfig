{...}:{
  flake.modules.homeManager.zed = {lib, pkgs, ...}: {
    home.packages = [ pkgs.zed-editor-fhs ];
    home.sessionVariables.EDITOR = lib.mkDefault "zeditor --wait";
  };
}
