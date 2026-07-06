_: {
  flake.modules.finix.session = {
    pkgs,
    lib,
    modules,
    ...
  }: {
    imports = [modules.doas];
    services.seatd.enable = true;
    finit.runlevel = 3;

    xdg.icons.enable = true;
    environment.pathsToLink = ["/share/applications" "/share/mime"];

    programs.doas.enable = true;
  };
}
