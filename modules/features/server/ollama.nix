{
  config,
  lib,
  ...
}: let
  cfg = config.features.server.ollama;
in {
  options.features.server.ollama = {
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address to bind Ollama to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port to bind Ollama to.";
    };

    acceleration = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["rocm" "cuda"]);
      default = null;
      description = "Hardware acceleration backend.";
    };
  };

  config.flake.modules.nixos.ollama = {...}: {
    services.ollama = {
      enable = true;
      host = cfg.host;
      port = cfg.port;
      acceleration = cfg.acceleration;
    };
  };
}
