{ lib, upstream, ... }:
let
  parser = import ../hyprconf-parser.nix { inherit lib; };

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/misc.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/misc.conf")
    else
      lib.warn "caelestia-nixos: upstream hypr/hyprland/misc.conf not found, using fallback defaults" {
        misc = {
          vfr = "true";
          vrr = "1";
          animate_manual_resizes = "false";
          animate_mouse_windowdragging = "false";
          disable_hyprland_logo = "true";
          force_default_wallpaper = "0";
          allow_session_lock_restore = "true";
          middle_click_paste = "false";
          focus_on_activate = "true";
          session_lock_xray = "true";
          mouse_move_enables_dpms = "true";
          key_press_enables_dpms = "true";
          background_color = "rgb($surfaceContainer)";
        };
        debug = {
          error_position = "1";
        };
      };
in
upstreamConf
