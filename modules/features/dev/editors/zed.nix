_: {
  aspects.dev.editors.zed = {
    description = "The Zed editor, set as $VISUAL.";
    home = { pkgs, ... }: {
      packages = [ pkgs.zed-editor-fhs ];
      environment.sessionVariables.VISUAL = "zeditor --wait";
    };
  };
}
