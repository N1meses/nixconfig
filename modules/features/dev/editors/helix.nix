{inputs, ...}: {
  flake.modules.homeManager.helix = {lib, ...}: {
    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = lib.mkDefault "hx";
    };

    xdg.mimeApps.defaultApplications = {
      "text/plain" = lib.mkDefault ["Helix.desktop"];
      "text/x-nix" = lib.mkDefault ["Helix.desktop"];
    };

    programs.helix = {
      enable = true;

      themes = import "${inputs.self}/assets/themes/nox-default.nix";

      settings = {
        theme = "nox-default";
        editor = {
          line-number = "relative";
          mouse = true;
          default-yank-register = "+";
          clipboard-provider = "wayland";
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
