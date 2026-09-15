_: {
  aspects.finix.network.networkmanager = {
    description = "Test Matrix: Selects NetworkManager as the network stack.";
    finix = { modules, ... }: {
      imports = [ modules.networkmanager ];
      services.networkmanager.enable = true;
    };
  };
}
