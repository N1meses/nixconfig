{
  inputs,
  config,
  lib,
  ...
}: let
  capitalize = s:
    (lib.toUpper (builtins.substring 0 1 s))
    + (builtins.substring 1 (builtins.stringLength s - 1) s);

  mkMinimal = name: let
    host = config.registry.hosts.${name};
    hardwareKey = "hardware${capitalize name}";
    diskoKey = "disko${capitalize name}";
    hasDisko = builtins.hasAttr diskoKey config.flake.modules.nixos;
  in
    inputs.nixpkgs.lib.nixosSystem {
      modules =
        [config.flake.modules.nixos.${hardwareKey}]
        ++ lib.optionals hasDisko [
          inputs.disko.nixosModules.disko
          config.flake.modules.nixos.${diskoKey}
        ]
        ++ [
          {
            networking.hostName = name;
            nixpkgs.hostPlatform = host.system;
            nixpkgs.config.allowUnfree = true;
            system.stateVersion = host.stateVersion;

            boot.loader.systemd-boot = {
              enable = lib.mkDefault true;
              editor = false;
            };
            boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };

            nix.settings.experimental-features = ["nix-command" "flakes"];

            users.users.root.initialPassword = "nixos";
          }
        ];
    };
in {
  flake.nixosConfigurations =
    lib.mapAttrs'
    (name: _: lib.nameValuePair "${name}Minimal" (mkMinimal name))
    (lib.filterAttrs (_: h: h.nixosModule != null) config.registry.hosts);
}
