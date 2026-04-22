{inputs, ...}: {
  flake.modules = {
    nixos.mango = {...}: {
      imports = [
        inputs.mango.nixosModules.mango
      ];
      programs.mango.enable = true;
      services.graphical-desktop.enable = true;
    };

    homeManager.mango = {
      lib,
      config,
      pkgs,
      ...
    }: let
      cfg = config.features.compositors.mango;
    in {
      imports = [
        inputs.mango.hmModules.mango
      ];

      options.features.compositors.mango = {
        extraBinds = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Extra keybinds to add to the niri config.";
        };
        autoStart = lib.mkOption {
          type = lib.types.lines;
          default = '''';
          description = "Commands to run at startup.";
        };
      };

      config = {
        home.packages = [pkgs.xwayland-satellite];
        wayland.windowManager.mango = {
          enable = true;
          package = inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango;
          autostart_sh =
            ''
              ${pkgs.xwayland-satellite}/bin/xwayland-satellite &
            ''
            + cfg.autoStart;

          settings = {
            monitorrule = lib.optionals (config.features.compositors.monitors != null) (
              lib.mapAttrsToList (
                name: m: "name:^${name}$,width:${toString m.resolution.width},height:${toString m.resolution.height},refresh:${toString m.refreshRate},x:${toString m.position.x},y:${toString m.position.y},scale:${toString m.scale},vrr:${
                  if m.vrr.enable
                  then "1"
                  else "0"
                }"
              )
              config.features.compositors.monitors
            );
            focused_opacity = 0.95;
            unfocused_opacity = 0.9;
            border_radius = 16;
            gappih = 8;
            gappiv = 8;
            gappoh = 8;
            gappov = 8;
            borderpx = 2;

            rootcolor = "0x201b14ff";
            bordercolor = "0x595959ff";
            focuscolor = "0x50C878ff";
            maximizescreencolor = "0x50C878ff";
            urgentcolor = "0xff0000ff";
            blur = 1;
            blur_optimized = 1;

            animations = 1;
            layer_animations = 1;
            animation_type_open = "zoom";
            animation_type_close = "zoom";

            new_is_master = 0;
            default_mfact = 0.5;
            default_nmaster = 1;
            smartgaps = 0;
            scroller_structs = 10;
            scroller_default_proportion = 0.5;
            scroller_focus_center = 0;
            scroller_default_proportion_single = 1.0;
            scroller_proportion_preset = "0.5,1.0";
            enable_hotarea = 0;
            circle_layout = "scroller,tile,tgmix";

            focus_on_activate = 1;
            sloppyfocus = 1;
            warpcursor = 1;
            focus_cross_monitor = 1;
            exchange_cross_monitor = 1;
            focus_cross_tag = 0;

            xkb_rules_layout = "de";
            numlockon = 1;
            tap_to_click = 1;
            tap_and_drag = 1;
            drag_lock = 1;
            trackpad_natural_scrolling = 1;
            disable_while_typing = 1;
            repeat_rate = 30;

            scratchpad_width_ratio = 0.8;
            scratchpad_height_ratio = 0.8;

            gesturebind = [
              "none,right,3,focusdir,left"
              "none,left,3,focusdir,right"
              "none,up,3,viewtoright"
              "none,down,3,viewtoleft"
            ];

            mousebind = [
              "SUPER,btn_left,moveresize,curmove"
              "SUPER,btn_right,moveresize,curresize"
            ];

            bind =
              [
                "SUPER,e,spawn, ghostty -e yazi"
                "SUPER,Return,spawn, ghostty"

                "SUPER,Escape,quit"
                "SUPER,q,killclient"
                "SUPER,h,focusdir,left"
                "SUPER,j,focusdir,down"
                "SUPER,k,focusdir,up"
                "SUPER,l,focusdir,right"
                "SUPER+SHIFT,h,exchange_client,left"
                "SUPER+SHIFT,j,exchange_client,down"
                "SUPER+SHIFT,k,exchange_client,up"
                "SUPER+SHIFT,l,exchange_client,right"

                "SUPER+CTRL,h,resizewin,-50,+0"
                "SUPER+CTRL,j,resizewin,+0,+50"
                "SUPER+CTRL,k,resizewin,+0,-50"
                "SUPER+CTRL,l,resizewin,+50,+0"
                "SUPER+SHIFT,f,togglefullscreen"
                "SUPER,f,togglemaximizescreen"

                "SUPER,v,togglefloating"
                "SUPER,c,centerwin"
                "SUPER,o,toggleoverview"
                "SUPER,s,switch_layout"

                "SUPER,i,minimized"
                "SUPER+SHIFT,i,restore_minimized"

                "SUPER,1,view,1"
                "SUPER,2,view,2"
                "SUPER,3,view,3"
                "SUPER,4,view,4"
                "SUPER,5,view,5"
                "SUPER,6,view,6"
                "SUPER,7,view,7"
                "SUPER,8,view,8"
                "SUPER,9,view,9"

                "SUPER+SHIFT,1,tag,1"
                "SUPER+SHIFT,2,tag,2"
                "SUPER+SHIFT,3,tag,3"
                "SUPER+SHIFT,4,tag,4"
                "SUPER+SHIFT,5,tag,5"
                "SUPER+SHIFT,6,tag,6"
                "SUPER+SHIFT,7,tag,7"
                "SUPER+SHIFT,8,tag,8"
                "SUPER+SHIFT,9,tag,9"
              ]
              ++ cfg.extraBinds;

            env = [
              "NIXOS_OZONE_WL,1"
              "MOZ_ENABLE_WAYLAND,1"
              "GDK_BACKEND,wayland,x11"
              "QT_QPA_PLATFORM,wayland"
              "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
              "SDL_VIDEODRIVER,wayland"
              "ELECTRON_OZONE_PLATFORM_HINT,auto"
              "NVD_BACKEND,direct"
              "_JAVA_AWT_WM_NONREPARENTING,1"
            ];
          };
        };
      };
    };
  };
}
