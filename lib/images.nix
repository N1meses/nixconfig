{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    concatMapAttrs
    elem
    filterAttrs
    mapAttrs'
    nameValuePair
    ;

  inherit (config.aspectLib) classes hostModules;

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
    (classes.nixos.mkSystem {
      inherit host;
      modules = hostModules {
        inherit name host;
        cls = classes.nixos;
        machine = false;
        extra = [ formatDefaults ];
      };
    }).config.system.build.images;

  imageable = filterAttrs (_: host: elem "nixos" host.classes && host.images != [ ]) config.hosts;
in
{
  packages = concatMapAttrs (
    name: host:
    mapAttrs' (format: drv: nameValuePair "${name}-${format}" drv) (
      lib.filterAttrs (format: _: elem format host.images) (imagesFor name host)
    )
  ) imageable;
}
