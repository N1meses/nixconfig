{inputs, ...}: {
  flake.modules.nixos.sops = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    environment.systemPackages = [
      pkgs.sops
    ];

    sops = {
      defaultSopsFile = lib.mkDefault (inputs.self + "/secrets/${config.networking.hostName}.yaml");
      age.sshKeyPaths = lib.mkDefault [];
      age.keyFile = lib.mkDefault "/root/.config/sops/age/keys.txt";
    };
  };
}
