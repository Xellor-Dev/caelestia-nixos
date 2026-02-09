inputs: { config
        , lib
        , pkgs
        , ...
        }:
let
  mods = import ./mods.nix { inherit lib; upstream = inputs.caelestia-dots; };
  cfg = config.programs.caelestia-dots;
in
{
  imports = with mods;
    [
      inputs.caelestia-shell.homeManagerModules.default
    ]
    ++ (mkMultipleMods { parentPath = [ ]; } [
      "hypr"
      (mkNode [ ] "caelestia")
      "btop"
      "foot"
      (mkNode [ ] "term")
      (mkNode [ ] "editor")
    ]);

  options = with lib; {
    programs.caelestia-dots = {
      enable = mkEnableOption "Enable Caelestia dotfiles";

      # Module enable options
      hypr = {
        enable = mkEnableOption "Enable Hyprland window manager configuration" // { default = false; };
      };

      editor = {
        enable = mkEnableOption "Enable editor configurations" // { default = false; };
      };

      term = {
        enable = mkEnableOption "Enable terminal configuration" // { default = false; };
      };

      btop = {
        enable = mkEnableOption "Enable btop system monitor" // { default = false; };
      };

      foot = {
        enable = mkEnableOption "Enable foot terminal emulator" // { default = false; };
      };

      caelestia = {
        enable = mkEnableOption "Enable Caelestia shell and CLI" // { default = true; };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = !cfg.hypr.enable || config.wayland.windowManager.hyprland.enable;
        message = "caelestia-dots: Hyprland module requires Hyprland to be enabled. Set 'wayland.windowManager.hyprland.enable = true' in your Home Manager config.";
      }
    ];
  };
}
