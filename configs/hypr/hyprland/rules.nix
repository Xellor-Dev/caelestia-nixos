# Hyprland 0.53+ syntax:
#   windowrule: effects need explicit values (e.g. "float on"), props use "match:" prefix
#   layerrule:  same — "match:namespace" instead of bare name
{lib, upstream, ...}: let
  parser = import ../hyprconf-parser.nix {inherit lib;};

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/rules.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/rules.conf")
    else lib.warn "caelestia-nixos: upstream hypr/hyprland/rules.conf not found, using fallback defaults" {
      windowrule = [
        "opacity $windowOpacity override, match:fullscreen false"
        "opaque true, match:class foot|equibop|org\\.quickshell|imv|swappy"
        "center true, match:float true, match:xwayland false"
        "float true, match:class guifetch"
        "float true, match:class yad"
        "float true, match:class zenity"
        "float true, match:class wev"
        "float true, match:class org\\.gnome\\.FileRoller"
        "float true, match:class file-roller"
        "float true, match:class blueman-manager"
        "float true, match:class com\\.github\\.GradienceTeam\\.Gradience"
        "float true, match:class feh"
        "float true, match:class imv"
        "float true, match:class system-config-printer"
        "float true, match:class org\\.quickshell"
        "float true, match:class foot, match:title nmtui"
        "size 60% 70%, match:class foot, match:title nmtui"
        "center 1, match:class foot, match:title nmtui"
        "float true, match:class org\\.gnome\\.Settings"
        "size 70% 80%, match:class org\\.gnome\\.Settings"
        "center 1, match:class org\\.gnome\\.Settings"
        "float true, match:class org\\.pulseaudio\\.pavucontrol|yad-icon-browser"
        "size 60% 70%, match:class org\\.pulseaudio\\.pavucontrol|yad-icon-browser"
        "center 1, match:class org\\.pulseaudio\\.pavucontrol|yad-icon-browser"
        "float true, match:class nwg-look"
        "size 50% 60%, match:class nwg-look"
        "center 1, match:class nwg-look"
        "workspace special:sysmon, match:class btop"
        "workspace special:music, match:class feishin|Spotify|Supersonic|Cider|com.github.th_ch.youtube_music"
        "workspace special:music, match:initial_title Spotify( Free)?"
        "workspace special:communication, match:class discord|equibop|vesktop|whatsapp"
        "workspace special:todo, match:class Todoist"
        "float true, match:title (Select|Open)( a)? (File|Folder)(s)?"
        "float true, match:title File (Operation|Upload)( Progress)?"
        "float true, match:title .* Properties"
        "float true, match:title Export Image as PNG"
        "float true, match:title GIMP Crash Debug"
        "float true, match:title Save As"
        "float true, match:title Library"
        "move 100%-w-2% 100%-w-3%, match:title Picture(-| )in(-| )[Pp]icture"
        "keep_aspect_ratio true, match:title Picture(-| )in(-| )[Pp]icture"
        "float true, match:title Picture(-| )in(-| )[Pp]icture"
        "pin true, match:title Picture(-| )in(-| )[Pp]icture"
        "rounding 10, match:class steam"
        "float true, match:title Friends List, match:class steam"
        "immediate true, match:class steam_app_[0-9]+"
        "idle_inhibit always, match:class steam_app_[0-9]+"
        "float true, match:class com-atlauncher-App, match:title ATLauncher Console"
        "no_blur true, match:title Fusion360|(Marking Menu), match:class fusion360\\.exe"
        "no_dim true, match:xwayland 1, match:title win[0-9]+"
        "no_shadow true, match:xwayland 1, match:title win[0-9]+"
        "rounding 10, match:xwayland 1, match:title win[0-9]+"
      ];
      workspace = [
        "w[tv1]s[false], gapsout:$singleWindowGapsOut"
        "f[1]s[false], gapsout:$singleWindowGapsOut"
      ];
      layerrule = [
        "animation fade, match:namespace hyprpicker"
        "animation fade, match:namespace logout_dialog"
        "animation fade, match:namespace selection"
        "animation fade, match:namespace wayfreeze"
        "animation popin 80%, match:namespace launcher"
        "blur true, match:namespace launcher"
        "no_anim true, match:namespace caelestia-(border-exclusion|area-picker)"
        "animation fade, match:namespace caelestia-(drawers|background)"
        "blur true, match:namespace caelestia-drawers"
        "ignore_alpha 0.57, match:namespace caelestia-drawers"
      ];
    };
in upstreamConf
