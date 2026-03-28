{...}: {
  flake.modules.homeManager.helix = {config, lib, ...}: {
    options.features.dev.editors.helix.enable = lib.mkEnableOption "helix editor";

    config = lib.mkIf config.features.dev.editors.helix.enable {
    programs.helix = {
      enable = true;

      settings = {
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
  };
}
