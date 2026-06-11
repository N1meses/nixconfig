{ config, ... }: {
  registry.hosts.icarus = {
    username = "icarus";
    system = "x86_64-linux";
    stateVersion = "25.11";
    aspects = with config.flake.lib.aspects; [
        hardwareIcarus
        diskoIcarus
        core
        shell
        git
    ];
  };

  configurations.finix.icarus.module = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ git wget ];
  };

  configurations.homeManager.icarus.module = {...}: {
  };
}
