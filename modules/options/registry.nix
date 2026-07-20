{
  lib,
  config,
  ...
}:
let
  t = lib.types;
  aspectNames = builtins.attrNames config.aspects;
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
              description = "Authorized ssh public keys for this account.";
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
          { config, ... }: {
            options = {
              username = lib.mkOption {
                type = t.str;
                description = "primary user for this host";
              };

              users = lib.mkOption {
                type = t.listOf (t.enum userNames);
                default = [ ];
                description = "User accounts subscribed on this host.";
              };

              extraGroups = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Additional groups for this user";
              };

              aspects = lib.mkOption {
                type = t.listOf (t.enum aspectNames);
                default = [ ];
                description = ''
                  Module names enabled on this host, resolved against
                  aspectLib.{nixos,home}.<name>. Each aspect routes to
                  whichever layer(s) define it: nixos-only names apply to the system,
                  home-only names apply to home, names in both apply to both.
                  Names defined in neither layer fail the build.
                '';
              };

              system = lib.mkOption {
                type = t.enum [
                  "x86_64-linux"
                  "aarch64-linux"
                  "x86_64-darwin"
                  "aarch64-darwin"
                ];
                default = "x86_64-linux";
                description = "system architecture";
              };

              stateVersion = lib.mkOption {
                type = t.str;
                description = "NixOS/Home Manager state version";
              };

              homeDirectory = lib.mkOption {
                type = t.str;
                default = "/home/${config.username}";
                description = "path to home directory";
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
                  athena uses a public domain; hephaistos uses its tailnet FQDN.
                '';
              };

              git = {
                name = lib.mkOption {
                  type = t.str;
                  default = "N1meses";
                };
                email = lib.mkOption {
                  type = t.str;
                  default = "nilshasenthal@gmail.com";
                };
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
