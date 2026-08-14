{
  lib,
  config,
  ...
}:
let
  t = lib.types;
  aspectNames = config.aspectLib.flatNames;
  userNames = builtins.attrNames config.registry.users;
in
{
  options.registry = {
    users = lib.mkOption {
      default = { };
      description = "Portable first-class user accounts, subscribed by hosts via hosts.<h>.users.";
      type = t.attrsOf (
        t.submodule {
          options = {
            aspects = lib.mkOption {
              type = t.listOf (t.enum aspectNames);
              default = [ ];
              description = ''
                Home-env aspects for this user; .home applies to the user,
                .nixos/.finix ride to any host it is subscribed on.
              '';
            };
            extraGroups = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
              description = "Role/persona groups that follow this account.";
            };
            keys = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
              description = "Authorized ssh public keys for this account. Delivered by users.nix on nixos, and by shell.ssh writing ~/.ssh/authorized_keys on every host that selects it (which is how finix gets them at all - it has no per-user openssh.authorizedKeys).";
            };
            uid = lib.mkOption {
              type = t.nullOr t.int;
              default = null;
              description = "Stable uid; keeps /persist home ownership consistent across hosts and reinstalls.";
            };
            hashedPassword = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = "Hashed password (mkpasswd -m sha-512). Applied as hashedPassword on nixos, password on finix.";
            };
            hashedPasswordFile = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = "Path to a file holding the hashed password (e.g. a sops secret). nixos→hashedPasswordFile, finix→passwordFile.";
            };
            git = {
              name = lib.mkOption {
                type = t.str;
                default = "N1meses";
                description = "Git author name for this user's commits.";
              };
              email = lib.mkOption {
                type = t.str;
                default = "nilshasenthal@gmail.com";
                description = "Git author email for this user's commits.";
              };
            };
            homeModule = lib.mkOption {
              type = t.nullOr t.deferredModule;
              default = null;
            };
          };
        }
      );
    };

    userNames = lib.mkOption {
      type = t.attrsOf t.str;
      readOnly = true;
      default = lib.genAttrs userNames (n: n);
      description = "Identity map of user names for `with config.registry.userNames;`.";
    };

    hosts = lib.mkOption {
      type = t.attrsOf (
        t.submodule (
          { name, ... }: {
            options = {
              users = lib.mkOption {
                type = t.listOf (t.enum userNames);
                default = [ ];
                description = "User accounts subscribed on this host.";
              };

              extraGroups = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Groups added to every user on this host, on top of each user's own extraGroups.";
              };

              aspects = lib.mkOption {
                type = t.listOf (t.enum aspectNames);
                default = [ ];
                description = ''
                  Aspect names enabled on this host. A host selection reaches the
                  *system* layers only - the `nixos` slot on a nixos host, the
                  `finix` slot on a finix one. It does NOT reach the home layer:
                  `mkHomeModules` resolves `registry.users.<u>.aspects` alone, so a
                  home-only name listed here is silently inert. Put it on the user.
                  Names matching no aspect fail the build with the full list.
                '';
              };

              system = lib.mkOption {
                type = t.enum [
                  "x86_64-linux"
                  "aarch64-linux"
                ];
                default = "x86_64-linux";
                description = "system architecture";
              };

              stateVersion = lib.mkOption {
                type = t.str;
                description = "NixOS state version. Home is hjem, which has no state version of its own.";
              };

              hostId = lib.mkOption {
                type = t.str;
                default = "";
                description = "8-digit hex host ID (required for ZFS)";
              };
              domain = lib.mkOption {
                type = t.str;
                default = "";
                description = ''
                  Primary FQDN for this host's services (public or tailnet). Service
                  modules build their vhosts from it (e.g. "matrix.''${domain}").
                  atlas uses a public domain; athena uses its tailnet FQDN.
                '';
              };

              machineModules = lib.mkOption {
                type = t.listOf t.deferredModule;
                default = [ ];
                description = ''
                  What this machine physically is: hardware, disk layout, encryption,
                  persistence. Spliced into whichever eval (nixos or finix) the host
                  builds in, so these modules are class-agnostic.

                  Listed explicitly rather than hidden behind a single machine.nix so
                  a host's physical makeup is readable without opening another file.
                  Builds that are not this machine — VMs, images, containers — omit
                  the list wholesale, which is why these are not aspects.
                '';
              };

              nixosModule = lib.mkOption {
                type = t.nullOr t.deferredModule;
                default = null;
              };
              finixModule = lib.mkOption {
                type = t.nullOr t.deferredModule;
                default = null;
              };
              homeModule = lib.mkOption {
                type = t.nullOr t.deferredModule;
                default = null;
              };
            };
          }
        )
      );
      default = { };
    };
  };
}
