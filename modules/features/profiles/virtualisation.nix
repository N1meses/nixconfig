_: {
  aspects.virtualisation = {
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
      { modules, ... }:
      {
        imports = [
          modules.incus
          modules.sysklogd
        ];

        services.sysklogd.enable = true;
        services.incus.enable = true;
      };
  };
}
