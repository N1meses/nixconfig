_: {
  aspects.desktop.services.graphics = {
    description = "GPU drivers and the X server fallback.";
    finix = _: {
      hardware.graphics.enable = true;
    };

    nixos = { lib, ... }: {
      hardware.graphics.enable = true;

      services.xserver = {
        enable = lib.mkDefault false;
        videoDrivers = lib.mkDefault [ "modesetting" ];
        xkb = {
          layout = lib.mkDefault "de";
          variant = lib.mkDefault "";
        };
      };
    };
  };
}
