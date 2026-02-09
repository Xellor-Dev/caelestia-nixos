{ config
, lib
, mod
, path
, mods
, pkgs
, use
, ...
}: {
  # Hypr module

  imports = with mods; [
    (mkRawMod path [ "variables" ]) # variables.conf
    (mkRawMod path [ "scheme" ]) # scheme/default.conf
    (mkNode path [ "hyprland" ])
  ];

  options = with lib; {
    programs.caelestia-dots.hypr.services = {
      gnomeKeyring = {
        enable = mkEnableOption "GNOME Keyring service" // { default = true; };
      };
      polkitGnome = {
        enable = mkEnableOption "GNOME Polkit agent" // { default = true; };
      };
      gammastep = {
        enable = mkEnableOption "Gammastep color temperature adjustment" // { default = true; };
        provider = mkOption {
          type = types.str;
          default = "geoclue2";
          description = "Location provider for gammastep (geoclue2, manual, etc.)";
        };
      };
      cliphist = {
        enable = mkEnableOption "Clipboard history manager" // { default = true; };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = config.wayland.windowManager.hyprland.enable || !config.programs.caelestia-dots.hypr.enable;
        message = "hyprland must be enabled in wayland.windowManager to use caelestia hypr module";
      }
    ];

    wayland.systemd.target = lib.mkDefault "hyprland-session.target";
    wayland.windowManager.hyprland = lib.mkIf config.programs.caelestia-dots.hypr.enable {
      enable = true;
      sourceFirst = false;
      settings = mod.settings;
      systemd.variables = with lib; map (env: head (splitString "," env)) (use "hypr.hyprland.env" "env" [ ]);
    };

    services = {
      gnome-keyring.enable = lib.mkDefault config.programs.caelestia-dots.hypr.services.gnomeKeyring.enable;
      polkit-gnome.enable = lib.mkDefault config.programs.caelestia-dots.hypr.services.polkitGnome.enable;
      gammastep = lib.mkIf config.programs.caelestia-dots.hypr.services.gammastep.enable {
        enable = true;
        provider = config.programs.caelestia-dots.hypr.services.gammastep.provider;
      };
      cliphist.enable = lib.mkDefault config.programs.caelestia-dots.hypr.services.cliphist.enable;
    };

    home.pointerCursor = {
      enable = true;
      name = mod.variables.cursorTheme;
      size = mod.variables.cursorSize;
      gtk.enable = true;
      package =
        lib.mkIf (mod.variables.cursorTheme == "Sweet-cursors")
          pkgs.sweet-nova;
    };
  };
}
