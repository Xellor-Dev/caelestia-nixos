# Hyprconf parser - converts Hyprland config format to Nix attrsets
# Handles: sections (key { ... }), key = value pairs, repeated keys (lists),
# $variable = value lines, and nested sections.
{lib}: let
  # Parse $variable = value lines into an attrset
  parseVars = text: let
    lines = lib.splitString "\n" text;
    isVarLine = line: let
      trimmed = lib.strings.trim line;
    in
      trimmed != "" && !(lib.hasPrefix "#" trimmed) && lib.hasPrefix "$" trimmed;
    parseLine = line: let
      trimmed = lib.strings.trim line;
      withoutDollar = lib.removePrefix "$" trimmed;
      parts = lib.splitString " = " withoutDollar;
      key = builtins.head parts;
      value = lib.concatStringsSep " = " (builtins.tail parts);
    in {inherit key value;};
    varLines = builtins.filter isVarLine lines;
    parsed = map parseLine varLines;
    toNixValue = str: let
      intMatch = builtins.match "^([0-9]+)$" str;
      floatMatch = builtins.match "^([0-9]+\\.[0-9]+)$" str;
    in
      if intMatch != null
      then lib.strings.toInt str
      else if floatMatch != null
      then lib.strings.toDouble str
      else if str == "true"
      then true
      else if str == "false"
      then false
      else str;
  in
    lib.listToAttrs (map (p: lib.nameValuePair p.key (toNixValue p.value)) parsed);

  # Parse a Hyprconf file with sections into a Nix attrset.
  # This is a line-based parser that handles:
  #   - key = value (simple assignment)
  #   - key { ... } (section blocks, possibly nested)
  #   - Repeated keys become lists
  #   - Comments (#) are stripped
  #   - $variable lines are treated as key = value with $ prefix preserved in key
  parseSections = text: let
    lines = lib.splitString "\n" text;

    # Remove comments and empty lines
    cleanLine = line: let
      trimmed = lib.strings.trim line;
    in
      if lib.hasPrefix "#" trimmed
      then ""
      else trimmed;

    # Strip inline comments from a value (text after # preceded by whitespace)
    stripInlineComment = str: let
      # Match: content before "  #" or " #" (whitespace + hash)
      m = builtins.match "^(.*[^ ])[ \t]+#.*$" str;
    in
      if m != null then builtins.head m else str;

    cleanLines = builtins.filter (l: l != "") (map cleanLine lines);

    # Recursive descent parser using fold
    # State: { result = attrset; stack = [parent_states]; current_key = "section_name" or null }
    processLines = let
      # Merge a key-value into an attrset, handling repeated keys as lists
      addToAttrs = attrs: key: value: let
        existing = attrs.${key} or null;
      in
        if existing == null
        then attrs // {${key} = value;}
        else if builtins.isList existing
        then attrs // {${key} = existing ++ [value];}
        else attrs // {${key} = [existing value];};

      # Prefix used for ordered keys like _1submap, _beziers
      foldFn = state: line: let
        # Check if line opens a section: "key {"
        sectionMatch = builtins.match "^([a-zA-Z_][a-zA-Z0-9_.:-]*) \\{$" line;
        # Check if line closes a section: "}"
        isClose = line == "}";
        # Check if line is a key = value
        kvMatch = builtins.match "^([^ ]+) = (.*)$" line;
      in
        if sectionMatch != null
        then
          # Push current state, start new section
          {
            result = {};
            stack = [{inherit (state) result; key = builtins.head sectionMatch;}] ++ state.stack;
          }
        else if isClose && state.stack != []
        then
          # Pop: merge current result into parent as a section
          let
            parent = builtins.head state.stack;
          in {
            result = addToAttrs parent.result parent.key state.result;
            stack = builtins.tail state.stack;
          }
        else if kvMatch != null
        then
          # Key = value pair
          let
            key = builtins.elemAt kvMatch 0;
            rawValue = builtins.elemAt kvMatch 1;
            value = stripInlineComment rawValue;
          in {
            result = addToAttrs state.result key value;
            inherit (state) stack;
          }
        else
          # Standalone line without = (skip)
          state;

      initial = {
        result = {};
        stack = [];
      };
    in
      (builtins.foldl' foldFn initial cleanLines).result;
  in
    processLines;
in {
  inherit parseVars parseSections;
}
