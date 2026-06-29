{inputs, ...}: {
  flake.modules = {
    nixos.core = {
      pkgs,
      lib,
      ...
    }: {
      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages;

        plymouth.enable = lib.mkDefault true;

        loader = {
          grub.enable = lib.mkDefault false;
          systemd-boot = {
            enable = lib.mkDefault true;
            editor = lib.mkDefault false;
            configurationLimit = lib.mkDefault 10;
          };
          efi.canTouchEfiVariables = lib.mkDefault true;
        };

        initrd = {
          systemd.enable = lib.mkDefault true;
          verbose = lib.mkDefault false;
        };
      };

      nix = {
        registry.nixpkgs.flake = inputs.nixpkgs;
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          auto-optimise-store = true;

          trusted-users = [
            "@wheel"
            "root"
          ];

          download-buffer-size = 524288000;
          http-connections = 0;
          max-substitution-jobs = 16;

          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://niri-nix.cachix.org"
            "https://noctalia.cachix.org"
            "https://hyprland.cachix.org"
            "https://attic.xuyh0120.win/lantian"
            "https://kopuz.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
          ];
        };

        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };
      };

      networking.networkmanager.enable = lib.mkDefault true;
      networking.firewall.enable = lib.mkDefault true;

      environment.systemPackages = with pkgs; [
        git
        helix
        curl
        wget
        (pkgs.writeShellScriptBin "nixos-revision" ''
          echo "${inputs.self.rev or "dirty"}"
        '')
      ];

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          curl
          stdenv.cc.cc
          zlib
          fuse3
          icu
          nss
          openssl
          expat
        ];
      };
    };

    homeManager.core = _: {
      programs.home-manager.enable = true;
      xdg.enable = true;
    };

    finix.core = {
      pkgs,
      lib,
      modules,
      ...
    }: {
      imports = [
        modules.limine
        modules.getty
        modules.networkmanager
      ];

      programs.limine.enable = true;

      services.udev.enable = true;

      finit.tmpfiles.rules = ["d /tmp 1777 root root -"];

      finit.services.syslogd = lib.mkDefault {
        description = "syslog";
        command = "${pkgs.busybox}/bin/syslogd -n";
        runlevels = "2345";
      };

      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        loader = {
          efi.canTouchEfiVariables = true;
        };
      };

      services.nix-daemon = {
        enable = true;

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          auto-optimise-store = true;

          trusted-users = [
            "@wheel"
            "root"
          ];

          download-buffer-size = 524288000;
          http-connections = 0;
          max-substitution-jobs = 32;

          flake-registry = inputs.self;

          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://niri-nix.cachix.org"
            "https://noctalia.cachix.org"
            "https://hyprland.cachix.org"
            "https://attic.xuyh0120.win/lantian"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          ];
        };
      };

      services.networkmanager.enable = true;

      environment.systemPackages = with pkgs; [
        git
        helix
        curl
        wget
        (pkgs.writeShellScriptBin "finix-revision" ''
          echo "${inputs.self.rev or "dirty"}"
        '')
      ];
    };
  };
}
