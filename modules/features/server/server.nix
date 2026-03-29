{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.server = {inputs, ...}: {
    imports =
      [
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (with flakeConfig.flake.modules.nixos; [
        serverCore
        ssh
        nginx
        forgejo
        jellyfin
        vaultwarden
        tailscale
        croc
        cloudflared
        ollama
      ]);
  };
}
