{
  aspects.finix.watt.finix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib.modules) mkIf;
      inherit (lib.options) mkOption mkEnableOption;
      inherit (lib.types) submodule;
      inherit (lib.meta) getExe;

      cfg = config.services.watt;

      format = pkgs.formats.toml { };
      cfgFile = format.generate "watt-config.toml" cfg.settings;

      conflictingServices = [
        "power-profiles-daemon"
        "auto-cpufreq"
        "tlp"
        "cpupower-gui"
        "thermald"
        "tuned"
      ];
    in
    {
      options.services.watt = {
        enable = mkEnableOption "Watt, automatic CPU speed & power optimizer for Linux";
        package = mkOption {
          type = lib.types.package;
          default = pkgs.watt;
          description = "Watt, automatic CPU speed & power optimizer for Linux";
        };

        settings = mkOption {
          type = submodule { freeformType = format.type; };
          default = { };
          description = "Configuration for Watt.";
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
        services.dbus.packages = [ cfg.package ];

        environment.etc."watt.toml".source = cfgFile;

        finit.services.watt = {
          description = "watt";
          conditions = "service/dbus/ready";
          environment.WATT_CONFIG = "${cfgFile}";
          command = "${getExe cfg.package}";
          state-dir = "watt";
          runtime-dir = "watt";
          runtime-dir-mode = "0755";
        };

        assertions = map (service: {
          assertion = if config.services ? ${service} then !config.services.${service}.enable else true;
          message = "You have set services.${service}.enable = true; which conflicts with Watt.";
        }) conflictingServices;
      };
    };
}
