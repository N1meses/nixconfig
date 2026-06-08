{...}: {
  flake.modules.nixos.impermanenceHermes = {...}: {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/tailscale"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
      ];
      users.hermes = {
        directories = [
          ".config"
          ".local/share"
          ".ssh"
          "nixconfig"
        ];
      };
    };
  };
}
