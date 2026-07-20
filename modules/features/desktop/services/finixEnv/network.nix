_: {
  aspects.netNM.finix = { modules, ... }: {
    imports = [ modules.networkmanager ];
    services.networkmanager.enable = true;
  };
  aspects.netDhcpcd.finix = { modules, ... }: {
    imports = [ modules.dhcpcd ];
    services.dhcpcd.enable = true;
  };
  aspects.netIwd.finix = { modules, ... }: {
    imports = [ modules.iwd ];
    services.iwd.enable = true;
  };
}
