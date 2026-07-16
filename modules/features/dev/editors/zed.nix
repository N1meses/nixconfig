_: {
  aspects.zed.home = { pkgs, ... }: {
    packages = [ pkgs.zed-editor-fhs ];
    environment.sessionVariables.VISUAL = "zeditor --wait";
  };
}
