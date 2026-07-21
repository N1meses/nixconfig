_: {
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
