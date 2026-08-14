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
      _module.args.userEntry = user;

      imports =
        lib.optional (user.homeModule != null) user.homeModule
        ++ lib.optional (host.homeModule != null) host.homeModule
        ++ aspectsFor homeModules (resolveAspects user.aspects);

      rum.programs.git = {
        enable = true;
        settings.user = {
          name = user.git.name;
          email = user.git.email;
        };
      };
    };
}
