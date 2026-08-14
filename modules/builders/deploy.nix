{
  config,
  inputs,
  lib,
  ...
}:
{
  deploy.nodes =
    lib.mapAttrs
      (name: host: {
        hostname = name;
        sshOpts = [
          "-o"
          "ControlPath=none"
        ];
        profiles.system = {
          sshUser = name;
          user = "root";
          interactiveSudo = true;
          path = inputs.deploy-rs.lib.${host.system}.activate.nixos config.nixosConfigurations.${name};
        };
      })
      (
        lib.filterAttrs (
          name: host: config.nixosConfigurations ? ${name} && host.machineModules != [ ]
        ) config.registry.hosts
      );
}
