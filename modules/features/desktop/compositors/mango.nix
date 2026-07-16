{
  config,
  inputs,
  ...
}: {
    aspects.mango = {
      nixos = {...}: {
        imports = [
          inputs.mango.nixosModules.mango
        ];
        programs.mango.enable = true;
      };

      home = {
        lib,
        config,
        pkgs,
        ...
      }: let
        cfg = config.features.compositors.mango;
        c = config.features.compositors;
        toMango = hex: "0x${lib.removePrefix "#" hex}ff";
        scratchpadId = "${c.terminal.command}-scratchpad";
        termArgs = lib.optionalString (c.terminal.args != []) " ${lib.concatStringsSep " " c.terminal.args}";
        termClass = cls: cmd:
          "${c.terminal.command}${termArgs} ${c.terminal.classFlag}=${cls}"
          + lib.optionalString (c.terminal.execFlag != "") " ${c.terminal.execFlag}"
          + " ${cmd}";
      in {
        options.features.compositors.mango = {
          extraBinds = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };
        };

        config = let
          mangoLib = import "${inputs.mango}/nix/lib.nix" lib;
          autostartText =
            ''
              ${pkgs.xwayland-satellite}/bin/xwayland-satellite &
              dbus-update-activation-environment --all
            ''
            + lib.concatMapStrings (cmd: "${cmd} &\n") c.autoStart;
          settings = {
              monitorrule = lib.optionals (c.monitors != null) (
                lib.mapAttrsToList (
                  name: m: "name:^${name}$,width:${toString m.resolution.width},height:${toString m.resolution.height},refresh:${toString m.refreshRate},x:${toString m.position.x},y:${toString m.position.y},scale:${toString m.scale},vrr:${
                    if m.vrr.enable
                    then "1"
                    else "0"
                  }"
                )
                c.monitors
              );

              focused_opacity = c.opacity.focused;
              unfocused_opacity = c.opacity.unfocused;
              border_radius = c.borders.radius;
              gappih = c.gaps.inner;
              gappiv = c.gaps.inner;
              gappoh = c.gaps.outer;
              gappov = c.gaps.outer;
              borderpx = c.borders.width;
              rootcolor = toMango c.colors.background;
              bordercolor = toMango c.colors.inactive;
              focuscolor = toMango c.colors.active;
              maximizescreencolor = toMango c.colors.active;
              urgentcolor = "0xff0000ff";
              blur = 1;
              blur_optimized = 1;
              animations = 1;
              layer_animations = 1;
              animation_type_open = "zoom";
              animation_type_close = "zoom";
              new_is_master = 0;
              default_mfact = 0.495;
              default_nmaster = 1;
              smartgaps = 0;
              tagrule = lib.genList (i: "id:${toString (i + 1)},layout_name:scroller") 9;
              scroller_structs = 8;
              scroller_default_proportion = 1.0;
              scroller_focus_center = 0;
              scroller_default_proportion_single = 1.0;
              scroller_ignore_proportion_single = 0;
              scroller_proportion_preset = "0.5,1.0";
              enable_hotarea = 0;
              circle_layout = "scroller,dwindle";
              drag_tile_to_tile = 1;
              focus_on_activate = 1;
              sloppyfocus = 1;
              warpcursor = 1;
              focus_cross_monitor = 1;
              exchange_cross_monitor = 1;
              focus_cross_tag = 0;
              cursor_size = c.cursor.size;
              cursor_hide_timeout = 3;
              xkb_rules_layout = c.keyboard.layout;
              numlockon = 1;
              tap_to_click = 1;
              tap_and_drag = 1;
              drag_lock = 1;
              trackpad_natural_scrolling = 1;
              disable_while_typing = 1;
              repeat_rate = 30;
              xwayland_persistence = 1;
              scratchpad_width_ratio = 0.8;
              scratchpad_height_ratio = 0.8;

              windowrule = [
                "focused_opacity:1.0,unfocused_opacity:1.0,appid:com.brave.Browser"
                "focused_opacity:1.0,unfocused_opacity:1.0,appid:brave-browser"
                "isfloating:1,title:Picture-in-Picture"
                "isglobal:1,title:Picture-in-Picture"
                "width:640,height:360,title:Picture-in-Picture"
                "isnamedscratchpad:1,width:2400,height:1500,appid:${scratchpadId}"
                "scroller_proportion:0.5,appid:${c.terminal.appId}"
              ];

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

              axisbind = [
                "SUPER,UP,focusdir,left"
                "SUPER,DOWN,focusdir,right"
              ];

              bind =
                [
                  "SUPER,Return,spawn,${c.terminal.command}${termArgs}"
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
                  "SUPER,e,toggle_named_scratchpad,${scratchpadId},none,${termClass scratchpadId "yazi"}"
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
                "AWT_TOOLKIT,MToolkit"
                "DISPLAY,:0"
              ];
          };
        in {
          packages = [pkgs.xwayland-satellite];

          features.portals.desktops.mango = {
            extraPortals = with pkgs; [xdg-desktop-portal-wlr xdg-desktop-portal-gtk];
            backendMap = {
              default = "wlr;gtk";
              "org.freedesktop.impl.portal.ScreenCast" = "wlr";
              "org.freedesktop.impl.portal.Screenshot" = "wlr";
              "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
              "org.freedesktop.impl.portal.Inhibit" = "gtk";
              "org.freedesktop.impl.portal.Notification" = "gtk";
              "org.freedesktop.impl.portal.Account" = "gtk";
              "org.freedesktop.impl.portal.Background" = "gtk";
              "org.freedesktop.impl.portal.Email" = "gtk";
              "org.freedesktop.impl.portal.OpenURI" = "gtk";
              "org.freedesktop.impl.portal.Print" = "gtk";
              "org.freedesktop.impl.portal.AppChooser" = "gtk";
            };
          };

          xdg.config.files."mango/config.conf".text =
            mangoLib.toMango {} settings
            + "\nexec-once=~/.config/mango/autostart.sh\n";
          xdg.config.files."mango/autostart.sh".source =
            pkgs.writeShellScript "mango-autostart" autostartText;
        };
      };
    };
    aspects.mango.includes = with config.aspectLib.names; [compositors portalsHjem];
}
