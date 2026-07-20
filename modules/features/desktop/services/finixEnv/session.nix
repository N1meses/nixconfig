_: {
  aspects.session.finix =
    {
      pkgs,
      modules,
      ...
    }:
    {
      imports = [ modules.doas ];
      finit.runlevel = 3;

      services.dbus = {
        enable = true;
        packages = [ pkgs.dconf ];
      };

      xdg.icons.enable = true;
      environment.pathsToLink = [
        "/share/applications"
        "/share/mime"
      ];

      programs.doas = {
        enable = true;
        persist = true;
      };
    };
}
