{...}: {
  flake.modules.nixos.mullvad = {config, ...}: {
    sops.secrets.mullvad-private-key = {};

    networking.wg-quick.interfaces.mullvad0 = {
      privateKeyFile = config.sops.secrets.mullvad-private-key.path;

      address = [
        "10.74.127.2/32"
        "fc00:bbbb:bbbb:bb01::b:7f01/128"
      ];

      dns = ["100.64.0.23"];

      peers = [
        {
          publicKey = "HQHCrq4J6bSpdW1fI5hR/bvcrYa6HgGgwaa5ZY749ik=";
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = "185.213.155.73:51820";
          persistentKeepalive = 25;
        }
      ];
    };

    networking.firewall.extraCommands = ''
      iptables -I OUTPUT ! -o mullvad0 -m mark ! --mark 0xca6c \
        -m addrtype ! --dst-type LOCAL -j REJECT
      ip6tables -I OUTPUT ! -o mullvad0 -m mark ! --mark 0xca6c \
        -m addrtype ! --dst-type LOCAL -j REJECT
    '';
    networking.firewall.extraStopCommands = ''
      iptables -D OUTPUT ! -o mullvad0 -m mark ! --mark 0xca6c \
        -m addrtype ! --dst-type LOCAL -j REJECT || true
      ip6tables -D OUTPUT ! -o mullvad0 -m mark ! --mark 0xca6c \
        -m addrtype ! --dst-type LOCAL -j REJECT || true
    '';
  };
}
