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

      image.modules.kexec.services.openssh.settings.PermitRootLogin = lib.mkForce "no";
      image.modules.iso-installer.services.openssh.settings.PermitRootLogin = lib.mkForce "no";
      image.modules.google-compute = {
        services.openssh.settings.PermitRootLogin = lib.mkForce "no";
        networking.firewall.enable = lib.mkForce true;
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
