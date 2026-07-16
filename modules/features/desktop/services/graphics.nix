_: {
  aspects.graphics.nixos = { lib, ... }: {
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
}
