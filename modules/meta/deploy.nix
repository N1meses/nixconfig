{
  config,
  inputs,
  lib,
  ...
}: {
  flake.deploy.nodes =
    lib.mapAttrs (name: host: {
      hostname = name;
      profiles.system = {
        sshUser = name;
        user = "root";
        path =
          inputs.deploy-rs.lib.${host.system}.activate.nixos
          config.flake.nixosConfigurations.${name};
      };
    })
    (lib.filterAttrs (name: _: config.flake.nixosConfigurations ? ${name})
      config.registry.hosts);
}
