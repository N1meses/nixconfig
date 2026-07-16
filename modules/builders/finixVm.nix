{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  finixModules = config.aspectLib.finixModules;

  aspectsFor = aspects: map (n: finixModules.${n}) (lib.filter (n: finixModules ? ${n}) aspects);

  testLib = import "${inputs.finix}/tests/lib" {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  pwHash = "$6$If7oQG5J2MpI2v.T$RpwZ8z.uJyvGyky4gKzanEhOUTCzpdSZQC/UuoiRvB.FwH3WPs.fKmbhk
  RfL8nmhCnn55qZjG8RzFcJbOePKH/";

  vmNode = {
    imports = aspectsFor [
      "core"
      "session"
      "greetd"
      "niri"
      "fonts"
      "mkVM"
    ];
    services.udev.enable = lib.mkForce false;
    users.users.icarus = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "seat"
      ];
      password = pwHash;
    };
    users.users.root.password = pwHash;
  };
in
{
  packages.vm-icarus =
    (testLib.mkTest {
      name = "icarus-vm";
      nodes.machine = vmNode;
      testScript = "start_all()";
      extraDriverArgs = [ "--interactive" ];
    }).driverInteractive;
}
