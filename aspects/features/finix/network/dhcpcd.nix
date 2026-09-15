_: {
  aspects.finix.network.dhcpcd = {
    description = "Test Matrix: Selects dhcpcd as the network stack.";
    finix = { modules, ... }: {
      imports = [ modules.dhcpcd ];
      services.dhcpcd.enable = true;
    };
  };
}
