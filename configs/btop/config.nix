{
  lib,
  upstream,
  ...
}: let
  # Parse btop.conf format: key = "value" / key = number / key = bool, # comments
  parseBtopConf = text: let
    lines = lib.splitString "\n" text;
    parsed = builtins.foldl' (acc: line: let
      trimmed = lib.trim line;
      isEmpty = trimmed == "" || lib.hasPrefix "#" trimmed;
      kv = builtins.match "([a-zA-Z_][a-zA-Z0-9_]*)[ \t]*=[ \t]*(.*)" trimmed;
    in
      if isEmpty then acc
      else if kv != null then let
        key = builtins.elemAt kv 0;
        rawVal = lib.trim (builtins.elemAt kv 1);
        # Strip surrounding quotes if present
        isQuoted = builtins.match "\"(.*)\"" rawVal;
        val =
          if isQuoted != null then builtins.elemAt isQuoted 0
          else if rawVal == "true" || rawVal == "True" then true
          else if rawVal == "false" || rawVal == "False" then false
          else let num = builtins.tryEval (lib.toInt rawVal);
               in if num.success then num.value else rawVal;
      in acc // { ${key} = val; }
      else acc
    ) {} lines;
  in parsed;

  upstreamPath =
    if upstream != null
    then "${upstream}/btop/btop.conf"
    else null;

  upstreamSettings =
    if upstreamPath != null && builtins.pathExists upstreamPath
    then parseBtopConf (builtins.readFile upstreamPath)
    else lib.warn "caelestia-dots: upstream btop/btop.conf not found, using minimal defaults." {
      color_theme = "caelestia";
      theme_background = false;
      truecolor = true;
    };
in
  upstreamSettings
