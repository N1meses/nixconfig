_: {
  aspects.security.description = "Security and secret-handling tooling.";
  aspects.security.home = { pkgs, ... }: {
    packages = with pkgs; [
      nmap
      netcat
      mtr
      tcpdump
      traceroute
      autopsy
    ];
  };
}
