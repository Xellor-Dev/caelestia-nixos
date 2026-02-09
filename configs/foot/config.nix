{ lib
, upstream
, ...
}:
let
  # Simple INI parser: reads foot.ini and returns a Nix attrset of sections
  parseIni = text:
    let
      lines = lib.splitString "\n" text;

      # Process each line, building up sections
      processed = builtins.foldl'
        (acc: line:
          let
            trimmed = lib.trim line;
            isSection = lib.hasPrefix "[" trimmed && lib.hasSuffix "]" trimmed;
            sectionName = lib.removePrefix "[" (lib.removeSuffix "]" trimmed);
            isKeyValue = builtins.match "([^=]+)=(.*)" trimmed;
            isEmpty = trimmed == "" || lib.hasPrefix "#" trimmed;
          in
          if isEmpty then acc
          else if isSection then acc // { currentSection = sectionName; ${sectionName} = (acc.${sectionName} or { }); }
          else if isKeyValue != null then
            let
              key = lib.trim (builtins.elemAt isKeyValue 0);
              value = lib.trim (builtins.elemAt isKeyValue 1);
              section = acc.currentSection;
            in
            acc // { ${section} = (acc.${section} or { }) // { ${key} = value; }; }
          else acc
        )
        { currentSection = "main"; }
        lines;
    in
    builtins.removeAttrs processed [ "currentSection" ];

  upstreamIniPath =
    if upstream != null
    then "${upstream}/foot/foot.ini"
    else null;

  upstreamSettings =
    if upstreamIniPath != null && builtins.pathExists upstreamIniPath
    then parseIni (builtins.readFile upstreamIniPath)
    else
      lib.warn "caelestia-dots: upstream foot/foot.ini not found, using minimal defaults." {
        main = {
          shell = "fish";
          title = "foot";
          font = "JetBrains Mono Nerd Font:size=12";
          pad = "25x25";
        };
        scrollback = { lines = "10000"; };
        cursor = { style = "beam"; beam-thickness = "1.5"; };
        colors = { alpha = "0.78"; };
      };
in
upstreamSettings
