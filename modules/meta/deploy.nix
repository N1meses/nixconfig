{
  config,
  inputs,
  lib,
  ...
}: {
  flake.deploy.nodes =
    lib.mapAttrs (name: host: {
      hostname = name;
      sshOpts = ["-o" "ControlPath=none"];
      profiles.system = {
        sshUser = host.username;
        user = "root";
        interactiveSudo = true;
        path =
          inputs.deploy-rs.lib.${host.system}.activate.nixos
          config.flake.nixosConfigurations.${name};
      };
    })
    (lib.filterAttrs (name: _: config.flake.nixosConfigurations ? ${name})
      config.registry.hosts);
}
