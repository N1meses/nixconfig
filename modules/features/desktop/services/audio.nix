{...}: {
  flake.modules.nixos.audio = {config, lib, ...}: {
    options.features.services.audio.enable = lib.mkEnableOption "pipewire audio";

    config = lib.mkIf config.features.services.audio.enable {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      security.rtkit.enable = true;
    };
  };
}
