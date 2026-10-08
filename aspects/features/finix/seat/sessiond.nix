{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.finix.seat.sessiond = {
    finix =
      { lib, ... }:
      {
        imports = [
          modules.sessiond-uaccess
        ];

        services = {
          seatd.enable = true;
          sessiond.enable = true;
          sessiond-uaccess.enable = true;
        };

        hjem.extraModules = [
          (
            { options, ... }:
            {
              config = lib.optionalAttrs (options ? features.compositors) {
                features.compositors.environment.XDG_SESSION_ID = "";
              };
            }
          )
        ];
      };
  };
}
