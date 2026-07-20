{ inputs, ... }:
{
  aspects.impermanence.finix = _: {
    imports = [ inputs.community-modules.nixosModules.preservation ];

    preservation = {
      enable = true;
      preserveAt."/persist".directories = [
        "/home"
        "/var/lib/sshd"
        "/var/lib/NetworkManager"
        "/etc/NetworkManager/system-connections"
        "/var/lib/dbus"
        "/var/lib/tailscale"
      ];
    };
  };
}
