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
      options.features.apps.yazi.terminalFilechooser = {
        enable =
          lib.mkEnableOption "yazi as the xdg-desktop-portal file chooser"
          // {default = true;};
        terminal = lib.mkOption {
          type = lib.types.str;
          default = config.features.compositors.terminal.command;
          description = "Terminal emulator to use for the file chooser.";
        };
      };

      config = lib.mkMerge [
        {
          rum.programs.yazi = {
            enable = true;
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

          rum.programs.zsh.initConfig = lib.mkAfter ''
            function yy() {
              local tmp; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
              ${pkgs.yazi}/bin/yazi "$@" --cwd-file="$tmp"
              local cwd
              if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                builtin cd -- "$cwd"
              fi
              rm -f -- "$tmp"
            }
          '';
        }

        (lib.mkIf cfg.terminalFilechooser.enable {
          packages = with pkgs; [xdg-terminal-exec xdg-desktop-portal-termfilechooser];

          xdg.config.files."xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" = {
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

          xdg.config.files."xdg-desktop-portal-termfilechooser/config".text = ''
            [filechooser]
            cmd=${config.directory}/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          '';

          features.portals.commonBackends."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        })
      ];
    };
    aspects.yazi.includes = with config.aspectLib.names; [compositors portalsHjem];
}
