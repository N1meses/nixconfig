_: {
  aspects.finix.network.iwd = {
    description = "Test Matrix: Selects iwd as the network stack.";
    finix = { modules, ... }: {
      imports = [ modules.iwd ];
      services.iwd.enable = true;
    };
  };
}
