{...}: {
  flake.modules.homeManager.security = {pkgs, config, lib, ...}: {
    options.features.dev.tools.security.enable = lib.mkEnableOption "security tools";

    config = lib.mkIf config.features.dev.tools.security.enable {
      home.packages = with pkgs; [
        nmap
        netcat
        mtr
        tcpdump
        traceroute
      ];
    };
  };
}
