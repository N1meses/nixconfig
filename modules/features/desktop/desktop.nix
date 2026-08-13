{ config, ... }: {
  aspects.desktop.description = "Graphical desktop bundle: session services, apps, the noctalia shell and session wiring.";
  aspects.desktop.includes = with config.aspectLib.names; [
    services
    apps
    noctalia
    session
  ];
}
