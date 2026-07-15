_: {
  aspects.security.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      nmap
      netcat
      mtr
      tcpdump
      traceroute
      autopsy
    ];
  };
}
