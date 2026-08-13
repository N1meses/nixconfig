{ inputs, ... }:
let
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://niri-nix.cachix.org"
    "https://noctalia.cachix.org"
    "https://hyprland.cachix.org"
    "https://attic.xuyh0120.win/lantian"
    "https://kopuz.cachix.org"
  ];

  substitutersKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
  ];

  nixSettings = {
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
    inherit substituters;
    trusted-public-keys = substitutersKeys;
  };
in
{
  aspects.core.core = {
    nixos =
      {
        pkgs,
        lib,
        ...
      }:
      {
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
          nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

          settings = nixSettings;

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
          tack
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

    home = { pkgs, ... }: {
      packages = [
        pkgs.tack
        (pkgs.callPackage "${inputs.hjem}/cli/package.nix" { })
      ];
    };

    finix =
      {
        pkgs,
        lib,
        modules,
        ...
      }:
      {
        imports = [
          modules.limine
          modules.getty
          modules.polkit
          modules.chronyd
          modules.cron
          modules."nix-daemon"
        ];

        programs.limine.enable = true;

        services.chrony.enable = true;

        services.polkit.enable = true;

        finit.services.syslogd = lib.mkDefault {
          description = "syslog";
          command = "${pkgs.busybox}/bin/syslogd -n";
          runlevels = "2345";
        };

        boot = {
          kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

          loader = {
            efi.canTouchEfiVariables = true;
          };
        };

        services.nix-daemon = {
          enable = true;

          settings = nixSettings;
        };

        services.cron = {
          enable = true;
          systab = [ "0 12 * * * root ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d" ];
        };

        security.pam.environment = {
          NIX_PATH.default = "nixpkgs=flake:nixpkgs";
          XDG_DATA_DIRS.default = [ "/etc/profiles/per-user/@{PAM_USER}/share" ];
          XCURSOR_PATH.default = [ "/etc/profiles/per-user/@{PAM_USER}/share/icons" ];
        };

        environment.etc."nix/registry.json".text = builtins.toJSON {
          version = 2;
          flakes = [
            {
              from = {
                type = "indirect";
                id = "nixpkgs";
              };
              to = {
                type = "path";
                path = inputs.nixpkgs.outPath;
              };
            }
          ];
        };

        environment.systemPackages = with pkgs; [
          git
          helix
          curl
          wget
          tack
          (pkgs.writeShellScriptBin "finix-revision" ''
            echo "${inputs.self.rev or "dirty"}"
          '')
        ];
      };
    description = "Core system settings: nix daemon config, boot defaults and the baseline package set.";
  };
}
