{inputs, ...}: {
  aspects.helix.home = {lib, ...}: {
    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = lib.mkDefault "hx";
    };

    features.mimeApps.defaultApplications = {
      "text/plain" = lib.mkDefault ["Helix.desktop"];
      "text/x-nix" = lib.mkDefault ["Helix.desktop"];
    };

    rum.programs.helix = {
      enable = true;

      themes = import "${inputs.self}/assets/themes/nox-default.nix";

      settings = {
        theme = lib.mkDefault "nox-default";
        editor = {
          line-number = lib.mkDefault "relative";
          mouse = lib.mkDefault true;
          default-yank-register = lib.mkDefault "+";
          clipboard-provider = lib.mkDefault "wayland";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
          indent-guides.render = true;
        };

        keys.normal = {
          space.w = ":w";
          space.q = ":q";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };
      };
    };
  };
}
