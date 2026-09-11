{ lib, ... }:
{
  options.pins = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    internal = true;
    description = "Inputs which are read by pnix";
  };
}
