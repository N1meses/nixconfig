{
  config,
  inputs,
  lib,
  ...
}: {
  deploy.nodes =
    lib.mapAttrs (name: host: {
      hostname = name;
      profiles.system = {
        sshUser = host.username;
        user = "root";
        interactiveSudo = true;
        path =
          inputs.deploy-rs.lib.${host.system}.activate.nixos
          config.nixosConfigurations.${name};
      };
    })
    (lib.filterAttrs (name: _: config.nixosConfigurations ? ${name})
      config.registry.hosts);
}
