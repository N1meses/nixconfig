{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.finix.doas = {
    description = "doas privilege escalation for the wheel group.";
    finix = _: {
      imports = [ modules.doas ];
      programs.doas = {
        enable = true;
        persist = true;
      };
    };
  };
}
