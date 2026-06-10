{...}: {
  flake.modules.nixos.ly = {...}: {
    services.displayManager.ly = {
      enable = true;
      settings = {
        clock = "%c";
      };
    };

    # HM owns gnome-keyring (not the system service), so the module's
    # default (system gnome-keyring) is false here — force the PAM unlock on.
    security.pam.services.ly.enableGnomeKeyring = true;
  };
}
