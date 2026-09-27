{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.finix.network.networkmanager = {
    description = "Test Matrix: Selects NetworkManager as the network stack.";
    finix = _: {
      imports = [ modules.networkmanager ];
      services.networkmanager.enable = true;
    };
  };
}
