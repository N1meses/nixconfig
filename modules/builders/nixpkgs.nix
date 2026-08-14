{ inputs, ... }:
let
  nixpkgsConfig = {
    allowUnfree = true;
    permittedInsecurePackages = [ "minio-2025-10-15T17-29-55Z" ];
  };

  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = nixpkgsConfig;
    };
in
{
  _module.args.pkgsFor = pkgsFor;

  _module.args.pkgs = pkgsFor "x86_64-linux";
}
