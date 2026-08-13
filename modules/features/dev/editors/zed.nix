_: {
  aspects.zed.description = "The Zed editor, set as $VISUAL.";
  aspects.zed.home = { pkgs, ... }: {
    packages = [ pkgs.zed-editor-fhs ];
    environment.sessionVariables.VISUAL = "zeditor --wait";
  };
}
