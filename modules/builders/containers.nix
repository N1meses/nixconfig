{
  inputs,
  lib,
  config,
  ...
}:
let
  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkContainer =
    _: c:
    let
      pkgs = pkgsFor c.system;
    in
    pkgs.dockerTools.streamLayeredImage {
      name = c.imageName;
      inherit (c) tag;
      contents = c.packages;
      config = {
        Env = lib.mapAttrsToList (k: v: "${k}=${v}") c.env;
        ExposedPorts = lib.genAttrs c.ports (_: { });
      }
      // lib.optionalAttrs (c.cmd != [ ]) { Cmd = c.cmd; }
      // lib.optionalAttrs (c.entrypoint != [ ]) { Entrypoint = c.entrypoint; }
      // lib.optionalAttrs (c.volumes != [ ]) { Volumes = lib.genAttrs c.volumes (_: { }); }
      // lib.optionalAttrs (c.workdir != null) { WorkingDir = c.workdir; }
      // lib.optionalAttrs (c.user != null) { User = c.user; }
      // c.extraConfig;
    };
in
{
  containers = lib.mapAttrs mkContainer config.registry.containers;
}
