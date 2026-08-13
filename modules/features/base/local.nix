_:
let
  localSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
in
{
  aspects.local.description = "Locale, timezone, console keymap and i18n settings.";
  aspects.local = {
    nixos =
      {
        lib,
        ...
      }:
      {
        time.timeZone = lib.mkDefault "Europe/Berlin";
        console.keyMap = lib.mkDefault "de";

        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
        i18n.extraLocaleSettings = lib.mkDefault localSettings;
      };

    finix =
      {
        lib,
        ...
      }:
      {
        time.timeZone = lib.mkDefault "Europe/Berlin";
        hardware.console = {
          enable = true;
          keyMap = lib.mkDefault "de";
        };

        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
        i18n.extraLocaleSettings = lib.mkDefault localSettings;
      };
  };
}
