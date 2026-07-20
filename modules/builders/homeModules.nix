{ config, lib, ... }:
let
  homeModules = config.aspectLib.homeModules;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
in
{
  aspectLib.mkHomeModules =
    {
      host,
      user,
    }:
    {
      imports =
        lib.optional (user.homeModule != null) user.homeModule
        ++ lib.optional (host.homeModule != null) host.homeModule
        ++ aspectsFor homeModules (resolveAspects user.aspects);

      rum.programs.git = {
        enable = true;
        settings.user = {
          name = host.git.name;
          email = host.git.email;
        };
      };
    };
}
