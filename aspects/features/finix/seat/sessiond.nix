{
  aspects.finix.seat.sessiond = {
    finix = { modules, ... }: {
      imports = [
        modules.sessiond-uaccess
      ];

      services = {
        seatd.enable = true;
        sessiond.enable = true;
        sessiond-uaccess.enable = true;
      };
    };

    home = _: {
      features.compositors.autoStart = [ "unset XDG_SESSION_ID" ];
    };
  };
}
