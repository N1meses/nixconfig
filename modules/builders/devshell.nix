{
  inputs,
  config,
  lib,
  pkgsFor,
  ...
}:
let
  systems = lib.unique (lib.mapAttrsToList (_: host: host.system) config.registry.hosts);

  shellFor =
    system:
    let
      pkgs = pkgsFor system;
    in
    pkgs.mkShellNoCC {
      name = "nixconfig";

      packages = [
        pkgs.tack

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
        echo "  nix-build . --attr checks.nixos-<host>     build a host"
        echo "  ./scripts/drvdiff.sh [ref]                 what moved since <ref>"
        echo "  deploy --file . <host>                     push to a remote"
        echo "  tack update [input]                        update pins"
      '';
    };
in
{
  devShells = lib.genAttrs systems (system: {
    default = shellFor system;
  });
}
