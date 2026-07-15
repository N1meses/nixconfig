_: {
  aspects.zed.home = {pkgs, ...}: {
    home.packages = [pkgs.zed-editor-fhs];
    home.sessionVariables.VISUAL = "zeditor --wait";
  };
}
