{ lib, ... }:
let
  t = lib.types;
in
{
  options.registry.containers = lib.mkOption {
    default = { };
    description = ''
      Application container images, exported as OCI tarballs loadable by docker or
      podman.

      Deliberately *not* hosts. A host is a machine (or a system container built
      from one — see `images.<host>.proxmox-lxc`) and carries users, aspects and a
      machine layer. An application container is a package set plus an entrypoint,
      with no init and no system, so it shares none of that machinery.
    '';
    type = t.attrsOf (
      t.submodule (
        { name, ... }:
        {
          options = {
            description = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = "One line on what this image is for. Shown in the generated reference.";
            };

            packages = lib.mkOption {
              type = t.listOf t.package;
              default = [ ];
              description = "Everything placed in the image's root filesystem.";
            };

            cmd = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
              description = "Default command (image config `Cmd`).";
            };

            entrypoint = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
              description = "Image config `Entrypoint`; prepended to `cmd` at runtime.";
            };

            env = lib.mkOption {
              type = t.attrsOf t.str;
              default = { };
              description = "Environment variables baked into the image.";
            };

            ports = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
              example = [ "8080/tcp" ];
              description = "Ports declared in the image metadata. Documentation for the runtime, not a firewall.";
            };

            volumes = lib.mkOption {
              type = t.listOf t.str;
              default = [ ];
              description = "Paths declared as volumes in the image metadata.";
            };

            workdir = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = "Working directory (image config `WorkingDir`).";
            };

            user = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = "User the entrypoint runs as. Null means root, which most runtimes dislike.";
            };

            tag = lib.mkOption {
              type = t.str;
              default = "latest";
              description = "Image tag.";
            };

            imageName = lib.mkOption {
              type = t.str;
              default = name;
              description = "Image name; defaults to the attribute name.";
            };

            system = lib.mkOption {
              type = t.enum [
                "x86_64-linux"
                "aarch64-linux"
              ];
              default = "x86_64-linux";
              description = "Architecture to build the image for.";
            };

            extraConfig = lib.mkOption {
              type = t.attrsOf t.raw;
              default = { };
              description = "Escape hatch merged into the OCI image config verbatim.";
            };
          };
        }
      )
    );
  };
}
