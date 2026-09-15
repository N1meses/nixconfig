_: {
  aspects.dev.tools.security = {
    description = "Security and secret-handling tooling.";
    home = { pkgs, ... }: {
      packages = with pkgs; [
        nmap
        netcat
        mtr
        tcpdump
        traceroute
        autopsy
      ];
    };
  };
}
