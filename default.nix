{
  rev ? null,
}:
let
  sources = import ./.pnix {
    allFollow = {
      nixpkgs = "nixpkgs";
      hjem = "hjem";
    };
  };

  inherit (sources.nixpkgs) lib;

  inherit (import ./lib/importTree.nix { inherit lib; }) listNix;

  readRev =
    path: default:
    if builtins.pathExists path then builtins.substring 0 40 (builtins.readFile path) else default;

  gitRev =
    if rev != null then
      rev
    else if builtins.pathExists ./.git/HEAD then
      let
        head = builtins.readFile ./.git/HEAD;
        m = builtins.match "ref: (.*[^\n])\n?" head;
      in
      if m == null then builtins.substring 0 40 head else readRev (./.git + "/${builtins.head m}") "dirty"
    else
      "dirty";

  inputs = sources // {
    self = {
      outPath = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./assets
          ./secrets
        ];
      };
      rev = gitRev;
    };
  };

  eval = lib.evalModules {
    specialArgs = {
      inherit inputs;
      self = eval.config;
    };
    modules = [
      ./lib/options/aspects.nix
      ./lib/options/outputs.nix
      ./lib/options/pins.nix
      ./lib/aspects.nix
      ./lib/systems.nix
      ./lib/outputs.nix
      ./lib/pkgs.nix
      ./lib/docs.nix
      ./lib/checks.nix
      ./lib/images.nix
      ./lib/vm.nix
      ./lib/deploy.nix
      ./lib/devshell.nix
      ./pins.nix
    ]
    ++ listNix ./aspects;
  };
in
eval.config
