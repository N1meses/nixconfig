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

  pins.glide = {
      url = "https://github.com/glide-browser/glide.nix";
  };
}
