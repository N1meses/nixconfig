{
  inputs,
  config,
  lib,
  pkgsFor,
  ...
}:
let
  shellFor =
    system:
    let
      pkgs = pkgsFor system;
    in
    pkgs.mkShellNoCC {
      name = "nixconfig";

      packages = [
        (pkgs.callPackage "${inputs.pnix}/package.nix" { })

        pkgs.nixfmt-tree

        pkgs.sops
        pkgs.age
        pkgs.ssh-to-age

        inputs.deploy-rs.packages.${system}.deploy-rs
        inputs.disko.packages.${system}.disko

        pkgs.nvd
        pkgs.nix-output-monitor
        pkgs.jq
      ];

      shellHook = ''
        echo "nixconfig — flakeless, built with --file ."
        echo "  nix build --file . checks.nixos-<host>     build a host"
        echo "  nix build --file . packages.<host>-vm      run a host in a VM"
        echo "  nix build --file . packages.docs           regenerate aspects/*.md"
        echo "  nix build --file . checks.aspects          find dead selections"
        echo "  deploy --file . <host>                     push to a remote"
        echo "  pnix update [pin]                          update pins"
      '';
    };
in
{
  devShells = lib.genAttrs config.aspectLib.systems (system: {
    default = shellFor system;
  });
}
