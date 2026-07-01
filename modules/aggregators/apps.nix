{config, ...}: {
  flake.aspectInclude.apps = with config.flake.lib.aspects; [
    yazi
    browser
    gtk
    nh
    fastfetch
  ];
}
