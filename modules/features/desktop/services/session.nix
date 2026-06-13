{...}: {
  flake.modules.finix.session = {
    pkgs,
    lib,
    ...
  }: {
    services.seatd.enable = true;

    security.pam.services.login.text = lib.mkAfter ''
      session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions
    '';
    security.pam.services.ly.text = lib.mkAfter ''
      session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions
    '';
  };
}
