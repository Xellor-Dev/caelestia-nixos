{ lib
, dots
, upstream
, ...
}:
let
  # Read starship configuration from upstream caelestia-dots repo
  upstreamSettings =
    if upstream != null && builtins.pathExists "${upstream}/starship.toml"
    then builtins.fromTOML (builtins.readFile "${upstream}/starship.toml")
    else lib.warn "caelestia-dots: upstream starship.toml not found, using empty defaults." { };
in
{
  enableFishIntegration = dots.term.fish._meta.active;

  settings = upstreamSettings;
}
