_: {
  aspects.desktop.services.audio = {
    nixos = _: {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      security.rtkit.enable = true;
    };

    finix =
      {
        lib,
        config,
        modules,
        ...
      }:
      {
        imports = [
          modules.pipewire
          modules.wireplumber
          modules.rtkit
        ];
        programs.pipewire.enable = true;
        programs.pipewire.alsa.enable = true;
        programs.pipewire.alsa.support32Bit = true;
        programs.wireplumber.enable = true;
        services.rtkit.enable = true;
        services.rtkit.extraGroups = lib.optionals (!config.services.elogind.enable) [
          config.services.seatd.group
        ];
      };
    description = "PipeWire audio with ALSA and 32-bit support.";
  };
}
