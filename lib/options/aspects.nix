{ lib, ... }:
let
  t = lib.types;

  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  layerOptions = {
    nixos = lib.mkOption {
      type = t.nullOr t.deferredModule;
      default = null;
      description = "Fragment applied on a NixOS host.";
    };

    finix = lib.mkOption {
      type = t.nullOr t.deferredModule;
      default = null;
      description = "Fragment applied on a finix host.";
    };

    home = lib.mkOption {
      type = t.nullOr t.deferredModule;
      default = null;
      description = "Fragment applied to a user's home environment.";
    };
  };

  common = layerOptions // {
    description = lib.mkOption {
      type = t.nullOr t.str;
      default = null;
      description = "What selecting this gets you. In the feature tree it also marks a node as selectable rather than a namespace.";
    };

    includes = lib.mkOption {
      type = t.listOf t.str;
      default = [ ];
      description = "Names this pulls in, transitively. Features may include features, users may include users and features, hosts may include anything.";
    };
  };

  extraGroups =
    meaning:
    lib.mkOption {
      type = t.listOf t.str;
      default = [ ];
      description = meaning;
    };

  aspectType = t.submodule {
    freeformType = t.lazyAttrsOf aspectType;
    options = common;
  };

  hostType = t.submodule {
    options = common // {
      classes = lib.mkOption {
        type = t.listOf (
          t.enum [
            "nixos"
            "finix"
          ]
        );
        default = [ ];
        description = "What this host is built as. A list, so one host can produce both a finix and a NixOS system.";
      };

      system = lib.mkOption {
        type = t.enum supportedSystems;
        default = "x86_64-linux";
        description = "CPU architecture.";
      };

      stateVersion = lib.mkOption {
        type = t.nullOr t.str;
        default = null;
        description = "NixOS release this machine was installed with. Required when classes contains \"nixos\", meaningless otherwise.";
      };

      machineModules = lib.mkOption {
        type = t.listOf t.deferredModule;
        default = [ ];
        description = "Modules describing this physical machine. Spliced in only for the real machine, never an image or VM.";
      };

      fleet = lib.mkOption {
        type = t.submodule {
          options = layerOptions;
        };
        default = { };
        description = "What this host publishes to every other host. For facts only this machine knows, such as its own address.";
      };

      images = lib.mkOption {
        type = t.listOf (
          t.enum [
            "proxmox"
            "proxmox-lxc"
            "kexec"
            "iso-installer"
            "google-compute"
          ]
        );
        default = [ ];
        description = "Image formats to build for this host, as packages.<host>-<format>.";
      };

      hostId = lib.mkOption {
        type = t.str;
        default = "";
        description = "Machine identifier, required for ZFS. Applied on the real machine and in images alike.";
      };

      domain = lib.mkOption {
        type = t.str;
        default = "";
        description = "Primary FQDN, if this host serves anything.";
      };

      disko = lib.mkOption {
        type = t.nullOr t.raw;
        default = null;
        description = "Disk layout in the shape disko's CLI wants.";
      };

      extraGroups = extraGroups "Groups added to every account on this host.";
    };
  };

  userType = t.submodule {
    options = common // {
      keys = lib.mkOption {
        type = t.listOf t.str;
        default = [ ];
        description = "Authorized ssh public keys.";
      };

      uid = lib.mkOption {
        type = t.nullOr t.int;
        default = null;
        description = "Stable uid, keeping /persist ownership consistent across hosts.";
      };

      hashedPassword = lib.mkOption {
        type = t.nullOr t.str;
        default = null;
        description = "Hashed password (mkpasswd -m sha-512).";
      };

      hashedPasswordFile = lib.mkOption {
        type = t.nullOr t.str;
        default = null;
        description = "Path to a file holding the hashed password.";
      };

      extraGroups = extraGroups "Groups that follow this account onto every host.";
    };
  };
in
{
  options = {
    aspects = lib.mkOption {
      type = t.lazyAttrsOf aspectType;
      default = { };
      description = "The feature tree. Nests freely; nodes with a description are selectable.";
    };

    hosts = lib.mkOption {
      type = t.attrsOf hostType;
      default = { };
      description = "Machines, keyed by hostname.";
    };

    users = lib.mkOption {
      type = t.attrsOf userType;
      default = { };
      description = "Accounts, keyed by username.";
    };
  };

  config.aspectLib.systems = supportedSystems;
}
