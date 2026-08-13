{ inputs, ... }: {
  aspects.sops.nixos =
    {
      hostName,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      environment.systemPackages = [
        pkgs.sops
      ];

      sops = {
        defaultSopsFile = lib.mkDefault (inputs.self + "/secrets/${hostName}.yaml");
        age.sshKeyPaths = lib.mkDefault [ ];
        age.keyFile = lib.mkDefault "/root/.config/sops/age/keys.txt";
      };
    };
}
