{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.finix.network.iwd = {
    description = "Test Matrix: Selects iwd as the network stack.";
    finix = _: {
      imports = [ modules.iwd ];
      services.iwd.enable = true;
    };
  };
}
