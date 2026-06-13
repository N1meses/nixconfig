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
    ];
  };

  configurations.finix.icarus.module = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [git wget];

    # hashed password for "icarus" (test host) — finix uses users.users.<n>.password
    users.users.icarus = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
      password = "$6$If7oQG5J2MpI2v.T$RpwZ8z.uJyvGyky4gKzanEhOUTCzpdSZQC/UuoiRvB.FwH3WPs.fKmbhkRfL8nmhCnn55qZjG8RzFcJbOePKH/";
    };
    users.users.root.password = "$6$If7oQG5J2MpI2v.T$RpwZ8z.uJyvGyky4gKzanEhOUTCzpdSZQC/UuoiRvB.FwH3WPs.fKmbhkRfL8nmhCnn55qZjG8RzFcJbOePKH/";
  };

  configurations.homeManager.icarus.module = {...}: {
  };
}
