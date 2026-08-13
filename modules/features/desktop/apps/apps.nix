{ config, ... }: {
  aspects.apps.description = "Everyday graphical apps: file manager, browser, GTK theming, nh and fastfetch.";
  aspects.apps.includes = with config.aspectLib.names; [
    yazi
    browser
    gtk
    nh
    fastfetch
  ];
}
