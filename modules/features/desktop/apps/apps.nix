{ config, ... }: {
  aspects.bundle.apps = {
    description = "Everyday graphical apps: file manager, browser, GTK theming, nh and fastfetch.";
    includes = with config.aspectLib.names; [
      desktop.apps.yazi
      desktop.apps.browser
      desktop.apps.gtk
      desktop.apps.nh
      desktop.apps.fastfetch
    ];
  };
}
