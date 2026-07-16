{
  description = "Util only flake";

  outputs = _: {
    formatter =
      let
        sources = import ./.tack/default.nix;
        lib = import (sources.nixpkgs + "/lib");

        pkgsFor = system: import sources.nixpkgs { inherit system; };
      in
      lib.genAttrs' [ "aarch64-linux" "x86_64-linux" ] (
        system: lib.nameValuePair system (pkgsFor system).nixfmt-tree
      );
  };
}
