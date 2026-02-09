{lib, upstream, ...}: let
  parser = import ../hyprconf-parser.nix {inherit lib;};

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/env.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/env.conf")
    else lib.warn "caelestia-nixos: upstream hypr/hyprland/env.conf not found, using fallback defaults" {
      env = [
        "QT_QPA_PLATFORMTHEME, qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "XCURSOR_THEME, $cursorTheme"
        "XCURSOR_SIZE, $cursorSize"
        "GDK_BACKEND, wayland,x11"
        "QT_QPA_PLATFORM, wayland;xcb"
        "SDL_VIDEODRIVER, wayland,x11,windows"
        "CLUTTER_BACKEND, wayland"
        "ELECTRON_OZONE_PLATFORM_HINT, auto"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "_JAVA_AWT_WM_NONREPARENTING, 1"
      ];
    };
in upstreamConf
