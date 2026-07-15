_: {
  aspects.fastfetch.home = {config, ...}: {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "${config.xdg.configHome}/fastfetch/nixowos.txt";
          type = "file";
          padding = {
            top = 1;
            left = 2;
          };
          color = {
            "1" = "#5277C3";
            "2" = "#7EBAE4";
            "3" = "#DF90AF";
            "4" = "#2D789E";
            "5" = "#5F92D3";
          };
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
          "display"
          {
            type = "wm";
            format = "{2} ({3})";
          }
          "terminal"
          "cpu"
          "gpu"
          "memory"
          {
            type = "disk";
            key = "Disk";
            folders = "/";
          }
          "battery"
          "break"
          "colors"
        ];
      };
    };

    xdg.configFile."fastfetch/nixowos.txt".text = ''
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
  };
}
