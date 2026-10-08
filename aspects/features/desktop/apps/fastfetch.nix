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
  colorFlags =
    p:
    lib.concatLists (
      lib.mapAttrsToList (n: c: [
        "--logo-color-${n}"
        c
      ]) p
    );
  logos = {
    nixos = ''
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
    finix = ''
      $1           ▗▄▄▄       $2▗▄▄▄▄    ▄▄▄▖
      $1           ▜███▙       $2▜███▙  ▟███▛
      $1            ▜███▙       $2▜███▙▟███▛    $1   ▗
      $1     ▐▄      ▜███▙       $2▜██████▛   $1 ▄▄▞▀▛
      $1      ▜▀▀▀▄▄  ▜█████████▙ $2▜████▛  $1▄█▛▀  ▗▘
      $1       ▌   ▀█▄▟██████████▙ $2▜███▙$1▟█▛    ▗▞
      $1       ▐  ▙▖▟$2▙▄▄▖           $2▜████$1▙▄▟▘  ▟▘
      $1        ▜▖▝█$2███▛             $2▜██▛$1██▄▄▄▞▘
      $1         ▝$2▟███▛$4▗▄▄▄       ▄▄▄▖$2▜▛ $1▟███▛
      $2 ▟███████████▛     $4▀▘   ▝▀      $1▟██████████▙
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
  };
  logoPath = pkgs: d: pkgs.writeText "fastfetch-${logoFile d}" logos.${d};
in
{
  aspects.desktop.apps.fastfetch = {
    description = "fastfetch system summary, configured for this fleet.";

    wrapper =
      { config, pkgs, ... }:
      let
        files = config.xdg.config.files;
        args =
          d:
          lib.escapeShellArgs (
            [
              "--logo"
              "${logoPath pkgs d}"
            ]
            ++ colorFlags palettes.${d}
          );
        script = pkgs.writeShellApplication {
          name = "fastfetch";
          text =
            if config.art.logo == "auto" then
              ''
                id=
                if [ -r /etc/os-release ]; then
                  while IFS='=' read -r k v; do
                    if [ "$k" = ID ]; then id=''${v//\"/}; fi
                  done </etc/os-release
                fi
                if [ "$id" = finix ]; then
                  set -- ${args "finix"} "$@"
                else
                  set -- ${args "nixos"} "$@"
                fi
                exec ${lib.getExe pkgs.fastfetch} --config ${files."fastfetch/config.jsonc".source} "$@"
              ''
            else
              ''
                exec ${lib.getExe pkgs.fastfetch} --config ${
                  files."fastfetch/config.jsonc".source
                } ${args config.art.logo} "$@"
              '';
        };
      in
      pkgs.symlinkJoin {
        name = "fastfetch-wrapped";
        paths = [
          script
          pkgs.fastfetch
        ];
        meta.mainProgram = "fastfetch";
      };

    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
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
            launch, in the wrapper — no per-host wiring, and correct wherever
            the package runs. "finix"/"nixos" pin the choice at build time.
          '';
        };

        config = {
          rum.programs.fastfetch = {
            enable = true;
            package = null;
            settings = {
              display = {
                disableLinewrap = true;
              };
              logo = {
                source = "${logoPath pkgs fallback}";
                type = "file";
                width = 46;
                height = 20;
                padding = {
                  top = 1;
                  left = 1;
                  right = 1;
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
                  format = "{size-used} / {size-total} ({size-percentage})";
                }
                {
                  type = "battery";
                  key = "Battery";
                  format = "{capacity} ({time-hours}h{time-minutes}m)";
                }
                "break"
                "colors"
              ];
            };
          };
        };
      };
  };
}
