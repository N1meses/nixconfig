{...}: {
  flake.modules.nixos.ollama = {...}: {
    services.ollama = {
      enable = true;
      host = "127.0.0.1";
      port = 11434;
      acceleration = "rocm";
    };
  };
}
