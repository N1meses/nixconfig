let
  tack = import ./.tack;
  inherit (tack) nixpkgs;
  inherit (nixpkgs) lib;
  inherit (lib) hasPrefix;
  inherit (lib.fileset) toList fileFilter;

  importTree = path: toList (fileFilter (file: file.hasExt "nix" && !(hasPrefix "_" file.name)) path);

  gitRev =
    let
      e = builtins.tryEval (
        let
          head = builtins.readFile ./.git/HEAD;
          m = builtins.match "ref: (.*[^\n])\n?" head;
        in
        if m != null then
          builtins.substring 0 40 (builtins.readFile (./.git + "/${builtins.head m}"))
        else
          builtins.substring 0 40 head
      );
    in
    if e.success then e.value else "dirty";

  inputs = tack // {
    self = {
      outPath = lib.cleanSource ./.;
      rev = gitRev;
    };
  };

  eval = nixpkgs.lib.evalModules {
    specialArgs = {
      inherit inputs;
      self = eval.config;
    };
    modules = importTree ./modules;
  };
in
eval.config
