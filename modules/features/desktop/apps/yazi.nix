{...}: {
  flake.modules.homeManager.yazi = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.features.apps.yazi;
  in {
    options.features.apps.yazi = {
      enable = lib.mkEnableOption "yazi file manager";
      terminalFilechooser = {
        enable = lib.mkEnableOption "terminal file chooser portal via yazi";
        terminal = lib.mkOption {
          type = lib.types.str;
          default = "ghostty";
          description = "Terminal emulator to use for the file chooser.";
        };
      };
    };

    config = lib.mkIf cfg.enable {
      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        shellWrapperName = "yy";
        settings = {
          mgr = {
            show_hidden = true;
            sort_by = "natural";
          };
          preview = {
            image_quality = 80;
            max_width = 10000;
            max_height = 10000;
          };
          tasks = {
            image_alloc = 536870912;
            image_bound = [65535 65535];
          };
        };
      };

      home.packages = lib.optionals cfg.terminalFilechooser.enable [
        pkgs.xdg-desktop-portal-termfilechooser
        pkgs.xdg-terminal-exec
      ];

      xdg.configFile."xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" =
        lib.mkIf cfg.terminalFilechooser.enable {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash
            set -e
            multiple="$1"
            directory="$2"
            save="$3"
            path="$4"
            out="$5"

            if [ -z "$path" ]; then
              path="."
            fi

            if [ "$save" = "1" ]; then
              exec ${pkgs.${cfg.terminalFilechooser.terminal}}/bin/${cfg.terminalFilechooser.terminal} --title=termfilechooser -e ${pkgs.yazi}/bin/yazi --chooser-file="$out" "$path"
            elif [ "$directory" = "1" ]; then
              exec ${pkgs.${cfg.terminalFilechooser.terminal}}/bin/${cfg.terminalFilechooser.terminal} --title=termfilechooser -e ${pkgs.yazi}/bin/yazi --chooser-file="$out" --cwd-file="$out.1" "$path"
            elif [ "$multiple" = "1" ]; then
              exec ${pkgs.${cfg.terminalFilechooser.terminal}}/bin/${cfg.terminalFilechooser.terminal} --title=termfilechooser -e ${pkgs.yazi}/bin/yazi --chooser-file="$out" "$path"
            else
              exec ${pkgs.${cfg.terminalFilechooser.terminal}}/bin/${cfg.terminalFilechooser.terminal} --title=termfilechooser -e ${pkgs.yazi}/bin/yazi --chooser-file="$out" "$path"
            fi
          '';
        };

      xdg.configFile."xdg-desktop-portal-termfilechooser/config" =
        lib.mkIf cfg.terminalFilechooser.enable {
          text = ''
            [filechooser]
            cmd=${config.home.homeDirectory}/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          '';
        };

      xdg.portal.config = lib.mkIf cfg.terminalFilechooser.enable {
        niri."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
        hyprland."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
      };
    };
  };
}
