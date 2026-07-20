{ config, ... }: {
  aspects.desktop.includes = with config.aspectLib.names; [
    services
    apps
    noctalia
    session
  ];
}
