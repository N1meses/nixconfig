_: {
  aspects.session.finix =
    {
      pkgs,
      ...
    }:
    {
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
    };
}
