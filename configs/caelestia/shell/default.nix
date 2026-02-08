#
# caelestia shell — default.nix (точка входа модуля)
#
# Передаёт resolved-значение mod в programs.caelestia.
# Связь cli = {} убрана — инициализация cli принадлежит caelestia/default.nix,
# где оба сиблинга (shell и cli) объявлены рядом.
#
#
# caelestia shell — default.nix (точка входа модуля)
#
# programs.caelestia (от caelestia-shell HM-модуля) принимает:
#   enable, package, systemd, settings, cli, extraConfig
#
# `mod` — это resolved shell-конфиг (general, bar, paths, appearance, ...),
# что соответствует содержимому shell.json → кладём в settings.
#
{
  config,
  lib,
  pkgs,
  mod,
  ...
}: {
  config = {
    programs.caelestia.settings = mod;

    # Скрипт активации: преобразует symlink на readonly файл в редактируемую копию
    home.activation.caelestiaConfigWritable = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/caelestia"
      CONFIG_FILE="$HOME/.config/caelestia/shell.json"
      
      # Если это symlink, удалить его
      if [ -L "$CONFIG_FILE" ]; then
        $DRY_RUN_CMD rm "$CONFIG_FILE"
      fi
      
      # Если файла нет, скопировать из Nix Store и сделать редактируемым
      if [ ! -f "$CONFIG_FILE" ]; then
        $DRY_RUN_CMD cp "${config.programs.caelestia.package}/etc/caelestia/shell.json" "$CONFIG_FILE" 2>/dev/null || true
        $DRY_RUN_CMD chmod 644 "$CONFIG_FILE"
      fi
    '';
  };
}
