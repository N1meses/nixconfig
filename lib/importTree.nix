{ lib }:
let
  inherit (lib)
    concatLists
    hasPrefix
    hasSuffix
    mapAttrsToList
    ;

  listNix =
    root:
    let
      go =
        dir:
        concatLists (
          mapAttrsToList (
            name: entry:
            if hasPrefix "_" name then
              [ ]
            else if entry == "directory" then
              go (dir + "/${name}")
            else if entry == "regular" && hasSuffix ".nix" name then
              [ (dir + "/${name}") ]
            else
              [ ]
          ) (builtins.readDir dir)
        );
    in
    if !builtins.pathExists root then throw "importTree: ${toString root} does not exist" else go root;
in
{
  inherit listNix;
}
