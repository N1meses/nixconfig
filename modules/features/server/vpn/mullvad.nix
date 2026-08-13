_: {
  aspects.server.vpn.mullvad = {
    description = "Mullvad VPN client.";
    nixos = _: {
      services.mullvad-vpn.enable = true;
    };
  };
}
