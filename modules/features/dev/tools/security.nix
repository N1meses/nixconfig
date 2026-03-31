{...}: {
  flake.modules.homeManager.security = {pkgs, ...}: {
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
