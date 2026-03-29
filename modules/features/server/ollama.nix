{...}: {
  flake.modules.nixos.ollama = {
    config,
    lib,
    ...
  }: let
    cfg = config.features.server;
  in {
    options.features.server = {
      ollama.enable = lib.mkEnableOption "Ollama server";
    };

    config = lib.mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        host = "127.0.0.1";
        port = 11434;
        acceleration = "rocm";
      };
    };
  };
}
