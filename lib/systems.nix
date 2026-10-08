{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    filter
    optional
    optionals
    ;

  inherit (config.aspectLib)
    all
    aspectsFor
    modulesFor
    resolve
    usersOf
    ;

  fleetFor =
    layer: self:
    filter (m: m != null) (
      map (h: h.fleet.${layer}) (builtins.attrValues (removeAttrs config.hosts [ self ]))
    );

  wrapperKey = n: lib.last (lib.splitString "." n);

  wrapperModule =
    names:
    {
      config,
      lib,
      pkgs,
      osConfig,
      userEntry,
      ...
    }@args:
    let
      withWrapper = filter (n: all.${n}.wrapper or null != null) names;
      byKey = lib.groupBy wrapperKey withWrapper;

      mkWrapped =
        name:
        {
          package,
          flags ? [ ],
          env ? { },
        }:
        pkgs.symlinkJoin {
          name = "${package.name}-wrapped";
          paths = [ package ];
          nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
          postBuild = ''
            wrapProgram $out/bin/${package.meta.mainProgram or name} ${
              lib.escapeShellArgs (
                lib.concatMap (f: [
                  "--add-flag"
                  f
                ]) flags
                ++ lib.concatLists (
                  lib.mapAttrsToList (k: v: [
                    "--set"
                    k
                    v
                  ]) env
                )
              )
            }
          '';
          meta = package.meta or { };
        };

      build =
        n:
        let
          r = all.${n}.wrapper args;
        in
        lib.hiPrio (if lib.isDerivation r then r else mkWrapped (wrapperKey n) r);
    in
    {
      options.wrapped = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        readOnly = true;
        description = "Wrapped packages built from the selected aspects' `wrapper`, keyed by the aspect's last path segment.";
      };

      config = {
        wrapped = lib.mapAttrs (
          key: owners:
          if builtins.length owners > 1 then
            throw "wrapper: aspects ${toString owners} all export wrapped.${key}"
          else
            build (builtins.head owners)
        ) byKey;
        packages = lib.attrValues config.wrapped;
      };
    };

  mkHomeModules =
    hostName: host: userName:
    let
      user = all.${userName};
      names = resolve [ userName ];
    in
    {
      _module.args.userEntry = user;

      imports =
        aspectsFor modulesFor.home names
        ++ [ (wrapperModule names) ]
        ++ optional (host.home != null) host.home
        ++ fleetFor "home" hostName;
    };

  commonModule =
    name: host:
    {
      networking.hostName = name;
      networking.hostId = lib.mkIf (host.hostId != "") host.hostId;

      _module.args.hostName = name;
      _module.args.hostEntry = host;
      _module.args.hostUsers = map (lib.removePrefix "users.") (usersOf "hosts.${name}");

      hjem.extraModules = [ inputs.hjem-rum.hjemModules.default ];
      hjem.clobberByDefault = true;
      hjem.users = builtins.listToAttrs (
        map (u: {
          name = lib.removePrefix "users." u;
          value = {
            enable = true;
            imports = [ (mkHomeModules name host u) ];
          };
        }) (usersOf "hosts.${name}")
      );
    }
    // lib.optionalAttrs (host.domain != "") {
      features.server.domain = host.domain;
    };

  hostModules =
    {
      name,
      host,
      cls,
      machine ? true,
      extra ? [ ],
    }:
    aspectsFor cls.moduleSet (resolve [ "hosts.${name}" ])
    ++ optionals machine host.machineModules
    ++ [
      cls.hmModule
      (commonModule name host)
    ]
    ++ fleetFor cls.layer name
    ++ extra;

  hostsOfClass = class: lib.filterAttrs (_: host: builtins.elem class host.classes) config.hosts;

  commonOverlays = [
    inputs.halley.overlays.default
    inputs.umbriel.overlays.default
  ];

  classes = {
    nixos = {
      layer = "nixos";
      output = "nixosConfigurations";
      moduleSet = modulesFor.nixos;
      hmModule = inputs.hjem.nixosModules.default;
      mkSystem =
        {
          host,
          modules,
        }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = modules ++ [
            {
              nixpkgs = {
                hostPlatform = host.system;
                config.allowUnfree = true;
                config.permittedInsecurePackages = [
                  "pnpm-10.29.2"
                  "electron-40.10.5"
                ];
                overlays = commonOverlays;
              };
              system.stateVersion = host.stateVersion;
            }
          ];
        };
    };

    finix = {
      layer = "finix";
      output = "finixConfigurations";
      moduleSet = modulesFor.finix;
      hmModule = inputs.hjem.finixModules.default;
      mkSystem =
        {
          host,
          modules,
        }:
        let
          eval = inputs.nixpkgs.lib.evalModules {
            class = "nixos";
            specialArgs = {
              inherit inputs;
              modules = inputs.finix.nixosModules;
            };
            modules = [
              inputs.finix.nixosModules.default
            ]
            ++ modules
            ++ [
              {
                nixpkgs.pkgs = import inputs.nixpkgs {
                  inherit (host) system;
                  config.allowUnfree = true;
                  config.permittedInsecurePackages = [
                    "pnpm-10.29.2"
                    "minio-2025-10-15T17-29-55Z"
                  ];
                  overlays = commonOverlays;
                };
              }
            ];
          };
        in
        eval // { inherit (eval._module.args) pkgs; };
    };
  };
in
{
  aspectLib = {
    inherit
      classes
      commonOverlays
      fleetFor
      wrapperKey
      wrapperModule
      mkHomeModules
      commonModule
      hostModules
      hostsOfClass
      ;
  };
}
