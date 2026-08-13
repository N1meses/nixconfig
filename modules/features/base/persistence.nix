_: {
  aspects.persistence.description = "Declarative /persist bind-mount handling for impermanent finix roots.";
  aspects.persistence.finix =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.environment.persistence;

      initrdForcedPaths = [
        "/"
        "/etc"
        "/nix"
        "/nix/store"
        "/usr"
        "/var"
        "/var/lib"
        "/var/log"
      ];

      normalize =
        d:
        if builtins.isString d then
          {
            path = d;
            user = "root";
            group = "root";
            mode = "0755";
          }
        else
          d;

      entries = lib.concatMap (
        root: map (d: (normalize d) // { inherit root; }) cfg.${root}.directories
      ) (builtins.attrNames cfg);
    in
    {
      options.environment.persistence = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.directories = lib.mkOption {
              type =
                with lib.types;
                listOf (
                  either str (submodule {
                    options = {
                      path = lib.mkOption {
                        type = str;
                        description = "Absolute path to persist.";
                      };
                      user = lib.mkOption {
                        type = str;
                        default = "root";
                      };
                      group = lib.mkOption {
                        type = str;
                        default = "root";
                      };
                      mode = lib.mkOption {
                        type = str;
                        default = "0755";
                      };
                    };
                  })
                );
              default = [ ];
              description = ''
                Directories bind-mounted from the persistence root over the
                ephemeral root. Source directories are created by activation
                before finit mounts the fstab.
              '';
            };
          }
        );
        default = { };
        description = ''
          Persistent storage configuration, keyed by persistence root
          (e.g. "/persist"). The root itself must be a fileSystems entry
          with neededForBoot = true.
        '';
      };

      config = {
        assertions =
          map (root: {
            assertion = (config.fileSystems ? ${root}) && config.fileSystems.${root}.neededForBoot;
            message = ''
              environment.persistence."${root}": the persistence root must be a
              fileSystems entry with neededForBoot = true — activation creates
              source directories on it before finit mounts the fstab binds.
            '';
          }) (builtins.attrNames cfg)
          ++ map (e: {
            assertion = !(lib.elem e.path initrdForcedPaths);
            message = ''
              environment.persistence."${e.root}": "${e.path}" is force-mounted
              in the initrd (finix pathsNeededForBoot), before activation can
              create its source directory. Persist a subpath instead, or seed
              "${e.root}${e.path}" manually at install time and declare the
              bind as a plain fileSystems entry.
            '';
          }) entries;

        fileSystems = lib.listToAttrs (
          map (e: {
            name = e.path;
            value = {
              device = "${e.root}${e.path}";
              fsType = "none";
              options = [ "bind" ];
            };
          }) entries
        );

        system.activation.scripts.persistence = {
          deps = [ "users" ];
          text = lib.concatMapStrings (e: ''
            mkdir -p ${lib.escapeShellArg "${e.root}${e.path}"} ${lib.escapeShellArg e.path}
            chmod ${e.mode} ${lib.escapeShellArg "${e.root}${e.path}"}
            chown ${e.user}:${e.group} ${lib.escapeShellArg "${e.root}${e.path}"}
          '') entries;
        };
      };
    };
}
