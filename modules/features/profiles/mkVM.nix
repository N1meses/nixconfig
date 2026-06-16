{...}: {
  flake.modules = {
    nixos.mkVM = {lib, ...}: {
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize   = lib.mkDefault 4096;
          cores        = lib.mkDefault 4;
          graphics     = true;
          resolution   = { x = 1920; y = 1080; };
          msize        = 262144;
          diskImage    = lib.mkDefault null;
          forwardPorts = [{ from = "host"; host.port = 2222; guest.port = 22; }];
          qemu.options = [ "-vga none" "-device virtio-vga-gl" "-display gtk,gl=on,grab-on-hover=off" ];
        };
        services.openssh.enable = true;
        services.getty.autologinUser = lib.mkDefault "icarus";
      };
    };

    finix.mkVM = {pkgs, lib, ...}: {
      virtualisation = {
        memorySize     = lib.mkDefault 4096;
        cores          = lib.mkDefault 4;
        qemu.package   = lib.mkForce pkgs.qemu;
        qemu.extraArgs = [ "-vga" "none" "-device" "virtio-vga-gl" "-display" "gtk,gl=on" "-usb" "-device" "usb-tablet" ];
      };
      testing.graphics.enable = true;
      services.mdevd.enable   = true;
    };
  };
}
