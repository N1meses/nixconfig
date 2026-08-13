_: {
  aspects.netNM.description = "Selects NetworkManager as the network stack.";
  aspects.netNM.finix = { modules, ... }: {
    imports = [ modules.networkmanager ];
    services.networkmanager.enable = true;
  };
  aspects.netDhcpcd.description = "Selects dhcpcd as the network stack.";
  aspects.netDhcpcd.finix = { modules, ... }: {
    imports = [ modules.dhcpcd ];
    services.dhcpcd.enable = true;
  };
  aspects.netIwd.description = "Selects iwd as the network stack.";
  aspects.netIwd.finix = { modules, ... }: {
    imports = [ modules.iwd ];
    services.iwd.enable = true;
  };
}
