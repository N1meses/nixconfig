_: {
  aspects.impermanenceHermes.nixos = _: {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/tailscale"
        "/etc/NetworkManager/system-connections"
        {
          directory = "/home/hermes";
          user = "hermes";
          group = "users";
          mode = "0700";
        }
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
