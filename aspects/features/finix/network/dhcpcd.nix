{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.finix.network.dhcpcd = {
    description = "Test Matrix: Selects dhcpcd as the network stack.";
    finix = _: {
      imports = [ modules.dhcpcd ];
      services.dhcpcd.enable = true;
    };
  };
}
