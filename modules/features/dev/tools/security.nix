_: {
  aspects.security.home = {pkgs, ...}: {
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
