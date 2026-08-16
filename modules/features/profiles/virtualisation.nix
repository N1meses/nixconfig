_: {
  aspects.profile.virtualisation = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        assertions = [
          {
            assertion = lib.all (
              user:
              !user.isNormalUser
              || (lib.elem "libvirtd" (user.extraGroups or [ ]) && lib.elem "kvm" (user.extraGroups or [ ]))
            ) (lib.attrValues config.users.users);
            message = ''
              Virtualisation profile requires normal users to be in 'libvirtd' and 'kvm' groups.
              Add to your host config:
                users.users.<username>.extraGroups = [ "libvirtd" "kvm" ... ];
            '';
          }
        ];

        virtualisation.libvirtd = {
          enable = lib.mkDefault true;
          qemu = {
            package = lib.mkDefault pkgs.qemu_kvm;
            runAsRoot = lib.mkDefault true;
            swtpm.enable = lib.mkDefault true;
          };
        };

        programs.virt-manager.enable = lib.mkDefault true;

        systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = [
          ""
          "/run/current-system/sw/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
        ];

        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };

        hardware.ksm = {
          enable = lib.mkDefault true;
          sleep = lib.mkDefault 50;
        };

        boot.kernelParams = [
          "hugepages=2048"
          "transparent_hugepage=madvise"
        ];
      };

    finix =
      { modules, pkgs, ... }:
      {
        imports = [
          modules.incus
          modules.sysklogd
        ];

        services.sysklogd.enable = true;
        services.incus.enable = true;

        # libvirt is built with sysconfdir=/var/lib, so /var/lib/qemu/firmware is
        # where it looks for QEMU's firmware descriptors. Without them the qemu
        # driver offers no `efi` firmware at all and only BIOS guests can boot.
        # qemu's own JSONs already carry absolute store paths, so linking the
        # directory is enough - nothing needs rewriting.
        finit.tmpfiles.rules = [
          "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
        ];

        environment.systemPackages = with pkgs; [
          qemu
          # No daemon: the client library spawns `virtqemud --timeout` under the
          # calling user, so virt-manager talks to qemu:///session and VM state
          # lives in ~/.config/libvirt. Nothing to wire into finit.
          libvirt
          virt-manager
          virt-viewer
          passt # interface backend='passt' - user-mode networking without slirp
          swtpm # TPM emulation; without it libvirt only offers tpm passthrough
          virtiofsd # host<->guest shared directories
        ];
      };
    description = "Virtualisation host support: libvirtd + virt-manager on nixos; incus plus per-user session libvirt (qemu:///session, no daemon) on finix.";
  };
}
