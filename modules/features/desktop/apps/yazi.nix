{config, ...}: {
    aspects.yazi.home = {
      pkgs,
      config,
      lib,
      ...
    }: let
      cfg = config.features.apps.yazi;
      term = config.features.compositors.terminal;
      termBin = "${pkgs.${cfg.terminalFilechooser.terminal}}/bin/${cfg.terminalFilechooser.terminal}";
      execFlag = lib.optionalString (term.execFlag != "") "${term.execFlag} ";
    in {
      options.features.apps.yazi.terminalFilechooser.terminal = lib.mkOption {
        type = lib.types.str;
        default = config.features.compositors.terminal.command;
        description = "Terminal emulator to use for the file chooser.";
      };

      config = {
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
            opener = {
              edit = [
                {
                  run = ''hx "$@"'';
                  block = true;
                }
              ];
            };
          };
        };

        home.packages = with pkgs; [xdg-terminal-exec xdg-desktop-portal-termfilechooser];

        xdg.configFile."xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" = {
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
              exec ${termBin} --title=termfilechooser ${execFlag}${pkgs.yazi}/bin/yazi --chooser-file="$out" "$path"
            elif [ "$directory" = "1" ]; then
              exec ${termBin} --title=termfilechooser ${execFlag}${pkgs.yazi}/bin/yazi --chooser-file="$out" --cwd-file="$out.1" "$path"
            elif [ "$multiple" = "1" ]; then
              exec ${termBin} --title=termfilechooser ${execFlag}${pkgs.yazi}/bin/yazi --chooser-file="$out" "$path"
            else
              exec ${termBin} --title=termfilechooser ${execFlag}${pkgs.yazi}/bin/yazi --chooser-file="$out" "$path"
            fi
          '';
        };

        xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${config.home.homeDirectory}/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        '';

        xdg.portal.config = {
          niri."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
          hyprland."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
          mango."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
        };
      };
    };
    aspects.yazi.includes = with config.aspectLib.names; [compositors];
}
