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
    services.greetd.settings.terminal.vt = 1;   # greeter owns tty1
    services.getty.ttys = ["tty2"];

    programs.doas.enable = true;

    security.pam.services.greetd.text = lib.mkAfter ''
      session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions
    '';
  };
}
