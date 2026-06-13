{...}: {
  flake.modules.finix.session = {
    pkgs,
    lib,
    modules,
    ...
  }: {
    imports = [modules.doas];
    services.seatd.enable = true;

    programs.doas.enable = true;

    security.pam.services.greetd.text = lib.mkAfter ''
      session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions
    '';
  };
}
