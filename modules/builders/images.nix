{
  lib,
  config,
  ...
}:
let
  inherit (config.aspectLib) hostModules classes;

  formatDefaults =
    { lib, ... }:
    {
      image.modules.proxmox = {
        proxmox.qemuConf.bios = lib.mkDefault "ovmf";
      };
    };

  imagesFor =
    name: host:
    let
      cls = classes.nixos;
      sys = cls.mkSystem {
        inherit host;
        modules =
          hostModules {
            inherit cls name host;
            machine = false;
          }
          ++ [ formatDefaults ];
      };
    in
    sys.config.system.build.images;

  imageableHosts = lib.filterAttrs (_: host: host.nixosModule != null) config.registry.hosts;
in
{
  images = lib.mapAttrs imagesFor imageableHosts;
}
