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
  mod,
  ...
}: {
  config = {
    programs.caelestia.settings = mod;
  };
}
