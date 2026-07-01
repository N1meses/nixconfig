{config, ...}: {
  flake.aspectInclude.desktop = with config.flake.lib.aspects; [
    services
    apps
    noctalia
  ];
}
