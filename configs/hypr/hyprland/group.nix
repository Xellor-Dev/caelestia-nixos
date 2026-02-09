{ lib, upstream, ... }:
let
  parser = import ../hyprconf-parser.nix { inherit lib; };

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/group.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/group.conf")
    else
      lib.warn "caelestia-nixos: upstream hypr/hyprland/group.conf not found, using fallback defaults" {
        group = {
          "col.border_active" = "$activeWindowBorderColour";
          "col.border_inactive" = "$inactiveWindowBorderColour";
          "col.border_locked_active" = "$activeWindowBorderColour";
          "col.border_locked_inactive" = "$inactiveWindowBorderColour";
          groupbar = {
            font_family = "JetBrains Mono NF";
            font_size = "15";
            gradients = "true";
            gradient_round_only_edges = "false";
            gradient_rounding = "5";
            height = "25";
            indicator_height = "0";
            gaps_in = "3";
            gaps_out = "3";
            text_color = "rgb($onPrimary)";
            "col.active" = "rgba($primaryd4)";
            "col.inactive" = "rgba($outlined4)";
            "col.locked_active" = "rgba($primaryd4)";
            "col.locked_inactive" = "rgba($secondaryd4)";
          };
        };
      };
in
upstreamConf
