{
  pkgs,
  config,
  lib,
  upstream,
  use,
  ...
}: let
  parser = import ../hyprconf-parser.nix {inherit lib;};
  
  # Подстановка Nix store путей
  substituteCommands = text: let
    replacements = [
      { from = "trash-empty"; to = "${pkgs.trash-cli}/bin/trash-empty"; }
      { from = "mpris-proxy"; to = "${pkgs.bluez}/bin/mpris-proxy"; }
      { from = "cliphist"; to = "${pkgs.cliphist}/bin/cliphist"; }
      { from = "wl-paste"; to = "${pkgs.wl-clipboard}/bin/wl-paste"; }
      { from = "gammastep"; to = "${pkgs.gammastep}/bin/gammastep"; }
      { from = "sleep"; to = "${pkgs.coreutils}/bin/sleep"; }
      { from = "gsettings"; to = "${pkgs.glib}/bin/gsettings"; }
      { from = " caelestia"; to = " ${config.programs.caelestia.cli.package}/bin/caelestia"; }
    ];
    applyReplacement = acc: r: 
      builtins.replaceStrings [r.from] [r.to] acc;
  in builtins.foldl' applyReplacement text replacements;
  
  
  upstreamConf =
    if upstream != null && builtins.pathExists "${upstream}/hypr/hyprland/execs.conf"
    then let
      rawConf = builtins.readFile "${upstream}/hypr/hyprland/execs.conf";
      substituted = substituteCommands rawConf;
    in parser.parseSections substituted
    else lib.warn "caelestia-nixos: upstream hypr/hyprland/execs.conf not found, using fallback defaults" {
  # commented execs were supplied by home-manager modules
  exec-once = [
    # "gnome-keyring-daemon --start --components=secrets"
    # "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    # "wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
    # "wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
    "${pkgs.trash-cli}/bin/trash-empty 30"
    "hyprctl setcursor $cursorTheme $cursorSize"
    # "gsettings set org.gnome.desktop.interface cursor-theme '$cursorTheme'"
    # "gsettings set org.gnome.desktop.interface cursor-size $cursorSize"
    # "/usr/lib/geoclue-2.0/demos/agent"
    # "sleep 1 && ${pkgs.gammastep}/bin/gammastep"
    "${pkgs.bluez}/bin/mpris-proxy"
    "${config.programs.caelestia.cli.package}/bin/caelestia resizer -d"
    # "caelestia shell -d"
  ];
};
in
  use upstreamConf
