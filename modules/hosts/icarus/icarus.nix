{
  config,
  inputs,
  ...
}: let
  mkNoctaliaNiri = config.flake.lib.mkNoctaliaNiri;
in {
  registry.hosts.icarus = {
    username = "icarus";
    system = "x86_64-linux";
    stateVersion = "25.11";
    aspects = with config.flake.lib.aspects; [
      hardwareIcarus
      diskoIcarus
      sshd
      base
      niri
      ly
      session
      desktop
      foot
      laptop
    ];

    finixModule = _: {
      users.users.icarus = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "seat" "video" "input" "audio"];
        password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      };
      users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      services.openssh.settings.PasswordAuthentication = true;
    };

    homeModule = {
      pkgs,
      lib,
      ...
    }: let
      flakeRoot = inputs.self;
    in {
      dconf.enable = false;

      programs.noctalia.settings.wallpaper = {
        directory = lib.mkForce "${flakeRoot}/assets/icons";
        default.path = lib.mkForce "${flakeRoot}/assets/icons/wallpaper.jpg";
        last.path = lib.mkForce "${flakeRoot}/assets/icons/wallpaper.jpg";
        monitors = lib.mkForce {};
      };

      features.compositors.niri.extraBinds = {
        "Mod+Shift+q" = {spawn = mkNoctaliaNiri "session lock";};
        "Mod+n" = {spawn = mkNoctaliaNiri "panel-toggle launcher";};
        "Mod+b" = {spawn = mkNoctaliaNiri "bar-toggle";};
      };

      home.pointerCursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-cursors";
        size = 24;
        gtk.enable = true;
      };

      home.packages = with pkgs; [
        btop
      ];
    };
  };
}
