{ config, ... }:
let
  homeModules = config.aspectLib.homeModules;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
in
{
  aspectLib.mkHomeModules =
    {
      host,
      homeModule,
    }:
    {
      imports = [
        homeModule
      ]
      ++ (aspectsFor homeModules (resolveAspects host.aspects));

      rum.programs.git = {
        enable = true;
        settings.user = {
          name = host.git.name;
          email = host.git.email;
        };
      };
    };
}
