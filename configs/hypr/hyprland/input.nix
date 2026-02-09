{lib, upstream, ...}: let
  parser = import ../hyprconf-parser.nix {inherit lib;};

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/input.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/input.conf")
    else lib.warn "caelestia-nixos: upstream hypr/hyprland/input.conf not found, using fallback defaults" {
      input = {
        kb_layout = "us";
        numlock_by_default = "false";
        repeat_delay = "250";
        repeat_rate = "35";
        focus_on_close = "1";
        touchpad = {
          natural_scroll = "true";
          disable_while_typing = "$touchpadDisableTyping";
          scroll_factor = "$touchpadScrollFactor";
        };
      };
      binds = {
        scroll_event_delay = "0";
      };
      cursor = {
        hotspot_padding = "1";
      };
    };
in upstreamConf
