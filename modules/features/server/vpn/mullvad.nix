{...}: {
  flake.modules.nixos.mullvad = {config, ...}: {
    sops.secrets.mullvad-private-key = {};

    networking.wg-quick.interfaces.mullvad0 = {
      privateKeyFile = config.sops.secrets.mullvad-private-key.path;

      address = [
        "10.74.127.2/32"
        "fc00:bbbb:bbbb:bb01::b:7f01/128"
      ];

      dns = ["10.64.0.1"];

      postUp = ''
        ip rule add to 100.64.0.0/10 priority 100 table main
        ip -6 rule add to fd7a:115c:a1e0::/48 priority 100 table main
        ip route replace 100.64.0.0/10 dev tailscale0
        ip -6 route replace fd7a:115c:a1e0::/48 dev tailscale0
      '';
      preDown = ''
        ip rule del to 100.64.0.0/10 priority 100 table main 2>/dev/null || true
        ip -6 rule del to fd7a:115c:a1e0::/48 priority 100 table main 2>/dev/null || true
        ip route del 100.64.0.0/10 dev tailscale0 2>/dev/null || true
        ip -6 route del fd7a:115c:a1e0::/48 dev tailscale0 2>/dev/null || true
      '';

      peers = [
        {
          publicKey = "HQHCrq4J6bSpdW1fI5hR/bvcrYa6HgGgwaa5ZY749ik=";
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = "185.213.155.73:51820";
          persistentKeepalive = 25;
        }
      ];
    };

    systemd.services.tailscaled = {
      before = ["wg-quick-mullvad0.service"];
      wants = ["wg-quick-mullvad0.service"];
    };

    networking.firewall.extraCommands = ''
      iptables -N KILLSWITCH 2>/dev/null || iptables -F KILLSWITCH
      iptables -A KILLSWITCH -o mullvad0 -j RETURN
      iptables -A KILLSWITCH -o tailscale0 -j RETURN
      iptables -A KILLSWITCH -m mark --mark 0xca6c -j RETURN
      iptables -A KILLSWITCH -m addrtype --dst-type LOCAL -j RETURN
      iptables -A KILLSWITCH -d 192.168.68.0/24 -j RETURN
      iptables -A KILLSWITCH -j REJECT
      iptables -C OUTPUT -j KILLSWITCH 2>/dev/null || iptables -I OUTPUT -j KILLSWITCH
      iptables -I INPUT -i tailscale0 -j ACCEPT

      ip6tables -N KILLSWITCH 2>/dev/null || ip6tables -F KILLSWITCH
      ip6tables -A KILLSWITCH -o mullvad0 -j RETURN
      ip6tables -A KILLSWITCH -o tailscale0 -j RETURN
      ip6tables -A KILLSWITCH -m mark --mark 0xca6c -j RETURN
      ip6tables -A KILLSWITCH -m addrtype --dst-type LOCAL -j RETURN
      ip6tables -A KILLSWITCH -j REJECT
      ip6tables -C OUTPUT -j KILLSWITCH 2>/dev/null || ip6tables -I OUTPUT -j KILLSWITCH
      ip6tables -I INPUT -i tailscale0 -j ACCEPT
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D OUTPUT -j KILLSWITCH 2>/dev/null || true
      iptables -D INPUT -i tailscale0 -j ACCEPT 2>/dev/null || true
      iptables -F KILLSWITCH 2>/dev/null || true
      iptables -X KILLSWITCH 2>/dev/null || true

      ip6tables -D OUTPUT -j KILLSWITCH 2>/dev/null || true
      ip6tables -D INPUT -i tailscale0 -j ACCEPT 2>/dev/null || true
      ip6tables -F KILLSWITCH 2>/dev/null || true
      ip6tables -X KILLSWITCH 2>/dev/null || true
    '';
  };
}
