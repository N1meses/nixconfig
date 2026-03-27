{
  config,
  lib,
  ...
}: let
  cfg = config.features.server;
in {
  options.features.server = {
    forgejo.enable = lib.mkEnableOption "forgejo git forge";
    jellyfin.enable = lib.mkEnableOption "jellyfin media server";
    vaultwarden.enable = lib.mkEnableOption "vaultwarden password manager";
    croc.enable = lib.mkEnableOption "croc relay";
    cloudflared.enable = lib.mkEnableOption "cloudflare tunnel";
  };

  config.flake.modules.nixos.serverProfile = {...}: {
    imports = with config.flake.modules.nixos;
      [server-core nginx]
      ++ lib.optional cfg.forgejo.enable forgejo
      ++ lib.optional cfg.jellyfin.enable jellyfin
      ++ lib.optional cfg.vaultwarden.enable vaultwarden
      ++ lib.optional cfg.croc.enable croc
      ++ lib.optional cfg.cloudflared.enable cloudflared;
  };
}
