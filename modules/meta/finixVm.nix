{
  inputs,
  config,
  lib,
  ...
}: let
  finixModules = config.flake.modules.finix;

  stripClass = m: args: removeAttrs (m args) ["_class"];
  aspectsFor = aspects:
    map (n: stripClass finixModules.${n})
    (lib.filter (n: finixModules ? ${n}) aspects);

  pwHash = "$6$If7oQG5J2MpI2v.T$RpwZ8z.uJyvGyky4gKzanEhOUTCzpdSZQC/UuoiRvB.FwH3WPs.fKmbhkRfL8nmhCnn55qZjG8RzFcJbOePKH/";

  vmNode = {
    imports = aspectsFor ["core" "session" "greetd" "niri" "fonts" "mkVM"];

    services.udev.enable = lib.mkForce false;

    users.users.icarus = {
      isNormalUser = true;
      extraGroups = ["wheel" "seat"];
      password = pwHash;
    };
    users.users.root.password = pwHash;
  };
in {
  perSystem = {pkgs, ...}: let
    testLib = import "${inputs.finix}/tests/lib" {
      inherit (pkgs) lib;
      inherit pkgs;
    };
  in {
    packages.vm-icarus =
      (testLib.mkTest {
        name = "icarus-vm";
        nodes.machine = vmNode;
        testScript = "start_all()";
        extraDriverArgs = ["--interactive"];
      })
      .driverInteractive;
  };
}
