{
  config,
  ...
}:
let
  c = config.features.compositors;
  cfg = c.umbriel;
in
{
  _class = "hjem";

  umbriel.settings = {
    window_rule = [
      {
        blur = true;
        blur_optimized = true;
      }
      {
        match.is_focused = false;
        opacity = c.opacity.unfocused;
      }
      {
        match.is_focused = true;
        opacity = c.opacity.focused;
      }
      {
        match.app_id = "^${c.terminal.appId}$";
        default_width = 0.5;
      }
      {
        match.app_id = "^${c.terminal.appId}$";
        match.title = "^termfilechooser$";
        default_floating = true;
        default_size = [
          1024
          768
        ];
      }
      {
        match.title = "Bitwarden";
        default_floating = true;
        default_size = [
          1024
          768
        ];
      }
      {
        match.app_id = "^${c.browser.appId}$";
        opacity = 1.0;
      }
      {
        match.app_id = "^dev.noctalia.Noctalia$";
        default_floating = true;
        default_size = [
          1020
          900
        ];
      }
      {
        match.app_id = "^dev.noctalia.UmbrielSharePicker$";
        default_floating = true;
        default_size = [
          800
          600
        ];
      }
    ]
    ++ cfg.extraWindowRules;

    layer_rule = [
      {
        match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
        blur = true;
        blur_ignore_alpha = 0.5;
        blur_optimized = false;
      }
    ]
    ++ cfg.extraLayerRules;
  };
}
