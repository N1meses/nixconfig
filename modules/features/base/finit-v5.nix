{
  aspects.finitV5.finix =
    { pkgs, ... }:
    {
      finit.package =
        let
          libconfuse = pkgs.libconfuse.overrideAttrs (old: {
            version = "3.3-unstable-2025-06-15";
            src = pkgs.fetchFromGitHub {
              owner = "libconfuse";
              repo = "libconfuse";
              rev = "2492725edaf61ace0ab2e555a6e0dde1f01e3c1a";
              hash = "sha256-hjQYzLE2atxSYinelFccv3WW8lc++cHyxpKvVPiO19U=";
            };
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.gettext ];
            patches = [ ];
          });
        in
        pkgs.finit.overrideAttrs (old: {
          version = "5.0-dev";
          src = pkgs.fetchFromGitHub {
            owner = "finit-project";
            repo = "finit";
            rev = "153f719e339b2c7902b927c5789a73247f532ead";
            hash = "sha256-Q991uEqWRcGeL3oWC0obGKsPpShHmaLtKDwUYPyDuvY=";
          };
          buildInputs = (old.buildInputs or [ ]) ++ [ libconfuse ];
        });
    };
}
