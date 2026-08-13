_: {
  aspects.finix.netNM = {
    description = "Selects NetworkManager as the network stack.";
    finix = { modules, ... }: {
      imports = [ modules.networkmanager ];
      services.networkmanager.enable = true;
    };
  };
  aspects.finix.netDhcpcd = {
    description = "Selects dhcpcd as the network stack.";
    finix = { modules, ... }: {
      imports = [ modules.dhcpcd ];
      services.dhcpcd.enable = true;
    };
  };
  aspects.finix.netIwd = {
    description = "Selects iwd as the network stack.";
    finix = { modules, ... }: {
      imports = [ modules.iwd ];
      services.iwd.enable = true;
    };
  };
}
