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

    security.pam.services = let
      xdg = lib.mkAfter ''
        session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions
      '';
    in {
      greetd.text = xdg;
      login.text = xdg;
    };
  };
}
