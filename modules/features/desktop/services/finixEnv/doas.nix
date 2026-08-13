_: {
  aspects.doas.description = "doas privilege escalation for the wheel group.";
  aspects.doas.finix =
    { modules, ... }:
    {
      imports = [ modules.doas ];
      programs.doas = {
        enable = true;
        persist = true;
      };
    };
}
