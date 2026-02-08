{
  config,
  lib,
  pkgs,
  mod,
  ...
}: let
  caelesita-vscode-integration = pkgs.callPackage ./caelestia-vscode-integration.nix {};
  extUniqueId = caelesita-vscode-integration.vscodeExtUniqueId;
  vscodeExtDir = "${config.programs.vscode.dataFolderName}/extensions";
in {
  config = {
    programs.vscode = mod;

    # Note that in this way, the extension dir is writable, but not the settings dir.
    # This means the extension cannot change the icon theme dinamically to match the light/dark theme.
    # A solution would be if the icon theme was provided by this extension or the user use some kind of
    # approach to make the settings writable.
    home.activation.caelestiaDotsEnableVscodeIntegration = lib.hm.dag.entryAfter ["linkGeneration"] ''
      cp -Lr --update=none ${caelesita-vscode-integration}/share/vscode/extensions/* ${vscodeExtDir}/${extUniqueId}
      chmod -R 755 ${vscodeExtDir}/${extUniqueId}
    '';

    # Make settings.json writable by replacing HM symlink with a real file.
    # This allows extensions (e.g., Copilot) to update settings, but future
    # declarative updates to userSettings won't be applied automatically.
    home.activation.caelestiaDotsWritableVscodeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settings_dir="${config.xdg.configHome}/${config.programs.vscode.dataFolderName}/User"
      settings_file="$settings_dir/settings.json"

      if [ -L "$settings_file" ]; then
        tmp=$(mktemp)
        cp -L "$settings_file" "$tmp"
        rm -f "$settings_file"
        mkdir -p "$settings_dir"
        cp "$tmp" "$settings_file"
        chmod 644 "$settings_file"
        rm -f "$tmp"
      fi
    '';
  };
}
