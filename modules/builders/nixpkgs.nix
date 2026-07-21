{ inputs, ... }: {
  _module.args.pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.permittedInsecurePackages = [ "minio-2025-10-15T17-29-55Z" ];
  };
}
