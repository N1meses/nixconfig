{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  boot.initrd.network.enable = true;
  boot.initrd.network.flushBeforeStage2 = true;
  boot.initrd.systemd.network.networks."10-enp3s0" = {
    matchConfig.MACAddress = "b0:82:e2:41:dd:8e";
    address = [ "192.168.68.50/22" ];
    routes = [ { Gateway = "192.168.68.1"; } ];
  };
  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    authorizedKeys =
      let
        askPass = ''command="systemd-tty-ask-password-agent --query",no-port-forwarding,no-x11-forwarding,no-agent-forwarding'';
      in
      [
        "${askPass} sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsZTxB0wavr8QZeOiFi+5jC2HhzHnJPfB38KFXrhwGWAAAABHNzaDo= yubikey-bio"
        "${askPass} sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAdtAWjHHeservujsnyP8YtRwdhn+Dx4P4gaf5t0hqC/AAAABHNzaDo= yubikey-nfc"
      ];
  };
  boot.initrd.network.ssh.extraConfig = ''
    PubkeyAcceptedAlgorithms +sk-ssh-ed25519@openssh.com
  '';
}
