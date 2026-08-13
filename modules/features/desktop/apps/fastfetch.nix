{ lib, ... }:
let
  palettes = {
    finix = {
      "1" = "#7D7D7D";
      "2" = "#DE3040";
      "3" = "#E84050";
      "4" = "#606060";
      "5" = "#D31F30";
    };
    nixos = {
      "1" = "#5277C3";
      "2" = "#7EBAE4";
      "3" = "#DF90AF";
      "4" = "#2D789E";
      "5" = "#5F92D3";
    };
  };
  logoFile = distro: if distro == "nixos" then "nixowos.txt" else "finix.txt";
  colorFlags = p: lib.concatStringsSep " " (lib.mapAttrsToList (n: c: "--logo-color-${n} '${c}'") p);
in
{
  aspects.desktop.apps.fastfetch = {
    description = "fastfetch system summary, configured for this fleet.";
    home =
      { config, lib, ... }:
      let
        sel = config.art.logo;
        fallback = if sel == "auto" then "finix" else sel;
      in
      {
        options.art.logo = lib.mkOption {
          type = lib.types.enum [
            "finix"
            "nixos"
            "auto"
          ];
          default = "auto";
          description = ''
            Which distro logo fastfetch displays.
            "auto" (default) detects the running distro from /etc/os-release at
            launch, via a zsh fastfetch wrapper — no per-host wiring, and correct
            wherever hjem is deployed. "finix"/"nixos" pin the choice at build time.
          '';
        };

        config = {
          rum.programs.fastfetch = {
            enable = true;
            settings = {
              display = {
                disableLinewrap = true;
              };
              logo = {
                source = "${config.xdg.config.directory}/fastfetch/${logoFile fallback}";
                type = "file";
                width = 46;
                height = 20;
                padding = {
                  top = 1;
                  left = 2;
                  right = 3;
                };
                color = palettes.${fallback};
              };
              modules = [
                "title"
                "separator"
                "os"
                "kernel"
                {
                  type = "command";
                  key = "Revision";
                  text = "nixos-revision";
                }
                "shell"
                {
                  type = "wm";
                  format = "{2} ({3})";
                }
                "terminal"
                {
                  type = "cpu";
                  format = "{1} ({5})";
                }
                {
                  type = "gpu";
                  format = "{2}";
                }
                "memory"
                {
                  type = "disk";
                  key = "Disk";
                  folders = "/";
                  format = "{size-used} / {size-total} ({size-percentage}%)";
                }
                {
                  type = "battery";
                  key = "Battery";
                  format = "{capacity}% ({time-hours}h{time-minutes}m)";
                }
                "break"
                "colors"
              ];
            };
          };

          rum.programs.zsh.initConfig = lib.mkIf (sel == "auto") (
            lib.mkBefore (
              "\n"
              + ''
                fastfetch() {
                  emulate -L zsh
                  local dir="''${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
                  if grep -q '^ID=finix' /etc/os-release 2>/dev/null; then
                    command fastfetch --logo "$dir/finix.txt" ${colorFlags palettes.finix} "$@"
                  else
                    command fastfetch --logo "$dir/nixowos.txt" ${colorFlags palettes.nixos} "$@"
                  fi
                }
              ''
            )
          );

          xdg.config.files."fastfetch/nixowos.txt".text = ''
            $1           ▗▄▄▄       $2▗▄▄▄▄    ▄▄▄▖
            $1           ▜███▙       $2▜███▙  ▟███▛
            $1            ▜███▙       $2▜███▙▟███▛       $1▗
            $1     ▐▄      ▜███▙       $2▜██████▛    $1▄▄▞▀▛
            $1      ▜▀▀▀▄▄  ▜█████████▙ $2▜████▛  $1▄█▛▀  ▗▘
            $1       ▌   ▀█▄▟██████████▙ $2▜███▙$1▟█▛    ▗▞
            $1       ▐  ▙▖▟$2▙▄▄▖           $2▜████$1▙▄▟▘  ▟▘
            $1        ▜▖▝█$2███▛             $2▜██▛$1██▄▄▄▞▘
            $1         ▝$2▟███▛ $4▀▚▄       ▄▞▀ $2▜▛ $1▟███▛
            $2 ▟███████████▛ $4▗▄▄▞▘     ▝▚▄▄▖  $1▟██████████▙
            $2 ▜██████████▛  $3/// $4▟▘ ▄ ▝▙ $3/// $1▟███████████▛
            $2       ▟███▛ $1▟▙    $4▜▄▟▀▙▄▛    $1▟███▛
            $2      ▟███▛ $1▟██▙             $1▟███▛      $5▄
            $2     ▟███▛  $1▜███▙           $1▝▀▀▀▀  $5▗▄▛▀▀
            $2     ▜██▛  ▗▌$1▜███▙ $2▜██████████████████▛
            $2      ▜▛  ▗▛ $1▟████▙ $2▜████████████████▛
            $2          ▝▌$1▟██████▙     $5▄▄$2▜███▙
            $1           ▟███▛▜███▙$2▄▄▟$5▀▘  $2▜███▙
            $1          ▟███▛$2▄▄$1▜███▙       $2▜███▙
            $1          ▝▀▀▀    ▀▀▀▀▘       $2▀▀▀▘
          '';

          xdg.config.files."fastfetch/finix.txt".text = ''
            $1             ▗▄▄▄       $2▗▄▄▄▄    ▄▄▄▖
            $1             ▜███▙       $2▜███▙  ▟███▛
            $1              ▜███▙       $2▜███▙▟███▛    $1   ▗
            $1       ▐▄      ▜███▙       $2▜██████▛   $1 ▄▄▞▀▛
            $1        ▜▀▀▀▄▄  ▜█████████▙ $2▜████▛  $1▄█▛▀  ▗▘
            $1         ▌   ▀█▄▟██████████▙ $2▜███▙$1▟█▛    ▗▞
            $1         ▐  ▙▖▟$2▙▄▄▖           $2▜████$1▙▄▟▘  ▟▘
            $1          ▜▖▝█$2███▛             $2▜██▛$1██▄▄▄▞▘
            $1           ▝$2▟███▛$4▗▄▄▄       ▄▄▄▖$2▜▛ $1▟███▛
            $2   ▟███████████▛     $4▀▘   ▝▀      $1▟██████████▙
            $2   ▜██████████▛  $3/// $4▟▘ ▄ ▝▙ $3/// $1▟███████████▛
            $2         ▟███▛ $1▟▙    $4▜▄▟▀▙▄▛    $1▟███▛
            $2        ▟███▛ $1▟██▙             $1▟███▛      $5▄
            $2       ▟███▛  $1▜███▙           $1▝▀▀▀▀  $5▗▄▛▀▀
            $2       ▜██▛  ▗▌$1▜███▙ $2▜██████████████████▛
            $2        ▜▛  ▗▛ $1▟████▙ $2▜████████████████▛
            $2            ▝▌$1▟██████▙     $5▄▄$2▜███▙
            $1             ▟███▛▜███▙$2▄▄▟$5▀▘  $2▜███▙
            $1            ▟███▛$2▄▄$1▜███▙       $2▜███▙
            $1            ▝▀▀▀    ▀▀▀▀▘       $2▀▀▀▘
          '';
        };
      };
  };
}
