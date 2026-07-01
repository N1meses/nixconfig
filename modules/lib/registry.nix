{
  lib,
  config,
  ...
}: let
  t = lib.types;
  aspectNames = lib.unique (
    lib.attrNames config.flake.modules.nixos
    ++ lib.attrNames config.flake.modules.homeManager
    ++ lib.attrNames (config.flake.modules.finix or {})
    ++ lib.attrNames (config.flake.aspectInclude or {})
  );
in {
  options = {
    flake = {
      lib = lib.mkOption {
        type = t.lazyAttrsOf t.raw;
        default = {};
      };

      aspectInclude = lib.mkOption {
        type = t.attrsOf (t.listOf (t.enum aspectNames));
        default = {};
      };
    };

    registry.hosts = lib.mkOption {
      type = t.attrsOf (t.submodule ({config, ...}: {
        options = {
          username = lib.mkOption {
            type = t.str;
            description = "primary user for this host";
          };

          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional groups for this user";
          };

          aspects = lib.mkOption {
            type = t.listOf (t.enum aspectNames);
            default = [];
            description = ''
              Module names enabled on this host, resolved against
              flake.modules.{nixos,homeManager}.<name>. Each aspect routes to
              whichever layer(s) define it: nixos-only names apply to the system,
              homeManager-only names apply to home, names in both apply to both.
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

          hostname = lib.mkOption {
            type = t.str;
            default = config.username;
            description = "Network hostname";
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
      }));
      default = {};
    };
  };

  config = {
    flake.lib = {
      aspects = lib.genAttrs aspectNames (n: n);

      aspectsFor = layerModules: aspectNames:
        map (n: layerModules.${n}) (lib.filter (n: layerModules ? ${n}) aspectNames);

      resolveAspects = roots: let
        inc = config.flake.aspectInclude;
      in
        map (e: e.key) (builtins.genericClosure {
          startSet = map (n: {key = n;}) roots;
          operator = {key, ...}: map (dep: {key = dep;}) (inc.${key} or []);
        });
    };
  };
}
