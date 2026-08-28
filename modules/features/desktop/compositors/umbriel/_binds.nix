{
  config,
  lib,
  ...
}:
let
  c = config.features.compositors;
  cfg = c.umbriel;

  termSpawn = lib.escapeShellArgs ([ c.terminal.command ] ++ c.terminal.args);
  termExec =
    cmd:
    lib.escapeShellArgs (
      [ c.terminal.command ]
      ++ c.terminal.args
      ++ lib.optional (c.terminal.execFlag != "") c.terminal.execFlag
      ++ [ cmd ]
    );

  mouseBinds = {
    "Mod+WheelUp" = "window-focus-left";
    "Mod+WheelDown" = "window-focus-right";
    "Mod+Ctrl+WheelUp" = "workspace-previous";
    "Mod+Ctrl+WheelDown" = "workspace-next";
    "Mod+Shift+WheelUp" = "column-move-left";
    "Mod+Shift+WheelDown" = "column-move-right";
    "Mod+MouseMiddle" = "overview-toggle";
  };

  workspaceBinds = lib.listToAttrs (
    lib.concatMap (n: [
      (lib.nameValuePair "Mod+${toString n}" "workspace-switch:${toString n}")
      (lib.nameValuePair "Mod+Shift+${toString n}" "window-move-to-workspace:${toString n}")
    ]) (lib.range 1 9)
  );

  staticBinds = {
    "Mod+o" = "overview-toggle";
    "Mod+q" = "window-close";
    "Mod+v" = "window-toggle-floating";

    "Mod+h" = "window-focus-left";
    "Mod+l" = "window-focus-right";
    "Mod+j" = "window-focus-down";
    "Mod+k" = "window-focus-up";

    "Mod+Shift+h" = "window-move-or-output-left";
    "Mod+Shift+l" = "window-move-or-output-right";
    "Mod+Shift+j" = "window-move-down";
    "Mod+Shift+k" = "window-move-up";

    "Mod+Comma" = "window-consume-left";
    "Mod+Period" = "window-expel-right";

    "Mod+Ctrl+l" = "window-modify-width:0.1";
    "Mod+Ctrl+h" = "window-modify-width:-0.1";

    "Mod+f" = "window-toggle-maximize";
    "Mod+Shift+f" = "window-toggle-fullscreen";
    "Mod+m" = "window-toggle-maximize-to-edges";
    "Mod+c" = "column-center";
    "Mod+Escape" = "session-quit";

    "Mod+p" = "window-toggle-pinned";
    "Mod+Shift+v" = "window-focus-switch-floating";
    "Mod+Space" = "scratchpad-toggle";
    "Mod+Ctrl+Space" = "window-restore-from-scratchpad";
    "Mod+Shift+Space" = "window-move-to-scratchpad";
    "Mod+Tab" = "scratchpad-focus-next";
    "Mod+Shift+c" = "cheatsheet-toggle";

    "Mod+r" = "window-cycle-width";
    "Mod+Shift+r" = "window-cycle-width-back";
    "Mod+Ctrl+r" = "config-reload";
  }
  // workspaceBinds;
in
{
  _class = "hjem";

  umbriel.settings.keybinds =
    staticBinds
    // mouseBinds
    // {
      "Mod+Return" = "spawn:${termSpawn}";
      "Mod+e" = "spawn:${termExec "yazi"}";
    }
    // cfg.extraBinds;
}
