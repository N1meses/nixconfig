{ inputs, lib, ... }:
let
  devices = import ./_devices.nix;

  fileSystems =
    (inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        { disko.devices = devices; }
      ];
    }).config.disko.devices._config.fileSystems;
in
{
  fileSystems = lib.mkMerge [
    fileSystems
    {
      "/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "nosuid"
          "nodev"
          "mode=1777"
        ];
      };
    }
  ];
}
