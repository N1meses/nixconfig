_: {
  flake.modules.homeManager.zed = {pkgs, ...}: {
    home.packages = [pkgs.zed-editor-fhs];
    home.sessionVariables.VISUAL = "zeditor --wait";
  };
}
