_: {
  aspects.finix.doas = {
    description = "doas privilege escalation for the wheel group.";
    finix =
      { modules, ... }:
      {
        imports = [ modules.doas ];
        programs.doas = {
          enable = true;
          persist = true;
        };
      };
  };
}
