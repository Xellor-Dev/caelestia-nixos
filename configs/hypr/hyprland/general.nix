{ lib, upstream, ... }:
let
  parser = import ../hyprconf-parser.nix { inherit lib; };

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/general.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/general.conf")
    else
      lib.warn "caelestia-nixos: upstream hypr/hyprland/general.conf not found, using fallback defaults" {
        general = {
          layout = "dwindle";
          allow_tearing = "false";
          gaps_workspaces = "$workspaceGaps";
          gaps_in = "$windowGapsIn";
          gaps_out = "$windowGapsOut";
          border_size = "$windowBorderSize";
          "col.active_border" = "$activeWindowBorderColour";
          "col.inactive_border" = "$inactiveWindowBorderColour";
        };
        dwindle = {
          preserve_split = "true";
          smart_split = "false";
          smart_resizing = "true";
        };
      };
in
upstreamConf
