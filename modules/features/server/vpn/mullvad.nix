_: {
  aspects.mullvad.description = "Mullvad VPN client.";
  aspects.mullvad.nixos = _: {
    services.mullvad-vpn.enable = true;
  };
}
