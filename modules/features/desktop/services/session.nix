_: {
  flake.modules.finix.session = {
    pkgs,
    modules,
    ...
  }: {
    imports = [modules.doas];
    services.seatd.enable = true;
    finit.runlevel = 3;

    services.dbus = {
      enable = true;
      packages = [pkgs.dconf];
    };

    xdg.icons.enable = true;
    environment.pathsToLink = ["/share/applications" "/share/mime"];

    programs.doas.enable = true;
  };
}
