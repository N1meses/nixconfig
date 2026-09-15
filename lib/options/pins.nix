{ lib, ... }: {
  options.pins = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "pins which are read by pnix";
  };
}
