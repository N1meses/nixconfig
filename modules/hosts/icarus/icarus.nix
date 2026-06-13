{config, ...}: {
  registry.hosts.icarus = {
    username = "icarus";
    system = "x86_64-linux";
    stateVersion = "25.11";
    aspects = with config.flake.lib.aspects; [
      hardwareIcarus
      diskoIcarus
      local
      core
      shell
      session
      greetd
      niri
      noctalia
      fonts
      apps
    ];
  };

  configurations.finix.icarus.module = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [git wget];

    users.users.icarus = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "seat"];
      password = "$6$If7oQG5J2MpI2v.T$RpwZ8z.uJyvGyky4gKzanEhOUTCzpdSZQC/UuoiRvB.FwH3WPs.fKmbhkRfL8nmhCnn55qZjG8RzFcJbOePKH/";
    };
    users.users.root.password = "$6$If7oQG5J2MpI2v.T$RpwZ8z.uJyvGyky4gKzanEhOUTCzpdSZQC/UuoiRvB.FwH3WPs.fKmbhkRfL8nmhCnn55qZjG8RzFcJbOePKH/";

    hardware.graphics.enable = true;
  };

  configurations.homeManager.icarus.module = {...}: {
  };
}
