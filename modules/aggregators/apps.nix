{config, ...}: {
  aspects.apps.includes = with config.aspectLib.names; [
    yazi
    browser
    gtk
    nh
    fastfetch
  ];
}
