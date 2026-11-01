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
        (pkgs.callPackage "${inputs.hjem}/cli/package.nix" { })

        pkgs.nixfmt-tree
        pkgs.nixdoc
        pkgs.nixd

        pkgs.sops
        pkgs.age
        pkgs.ssh-to-age

        inputs.deploy-rs.packages.${system}.deploy-rs
        inputs.disko.packages.${system}.disko

        pkgs.nvd
        pkgs.nix-output-monitor
        pkgs.jq
      ];
    };
in
{
  devShells = lib.genAttrs config.aspectLib.systems (system: {
    default = shellFor system;
  });
}
