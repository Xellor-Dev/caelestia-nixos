{lib, upstream, ...}: let
  parser = import ../hyprconf-parser.nix {inherit lib;};

  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/decoration.conf"
    then parser.parseSections (builtins.readFile "${upstream}/hypr/hyprland/decoration.conf")
    else lib.warn "caelestia-nixos: upstream hypr/hyprland/decoration.conf not found, using fallback defaults" {
      decoration = {
        rounding = "$windowRounding";
        blur = {
          enabled = "$blurEnabled";
          xray = "$blurXray";
          special = "$blurSpecialWs";
          ignore_opacity = "true";
          new_optimizations = "true";
          popups = "$blurPopups";
          input_methods = "$blurInputMethods";
          size = "$blurSize";
          passes = "$blurPasses";
        };
        shadow = {
          enabled = "$shadowEnabled";
          range = "$shadowRange";
          render_power = "$shadowRenderPower";
          color = "$shadowColour";
        };
      };
    };
in upstreamConf
