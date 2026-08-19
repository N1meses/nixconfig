{ config, inputs, ... }: {
  aspects.desktop.apps.browser.glide = {
    description = "The Glide browser: Firefox-based, keyboard-driven, configured from a single glide.ts.";
    includes = with config.aspectLib.names; [ desktop.compositors.compositors ];
    home =
      {
        pkgs,
        lib,
        ...
      }:
      {
        imports = [ ./_common.nix ];

        # --name is not optional: launched bare, the wayland app-id comes from
        # application.ini's RemotingName (glide-glide) rather than the `glide`
        # the desktop entry produces, and the compositor rules stop matching.
        features.compositors.browser = lib.mkDefault {
          command = "glide";
          args = [
            "--name"
            "glide"
          ];
          appId = "glide";
          desktopFile = "glide.desktop";
        };

        packages = [
          inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
  };
}
