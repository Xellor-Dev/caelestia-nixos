{ pkgs, ... }: {
  extensions = [ "nix" "qml" ];
  extraPackages = with pkgs; [ kdePackages.qtdeclarative alejandra nixd ];
  userKeymaps = [
    {
      bindings = {
        alt-down = [
          "editor::SelectNext"
          { replace_newest = false; }
        ];
        alt-up = [
          "editor::SelectPrevious"
          { replace_newest = false; }
        ];
        ctrl-shift-down = "editor::MoveLineDown";
        ctrl-shift-up = "editor::MoveLineUp";
      };
      context = "Editor";
    }
  ];
  userSettings = {
    buffer_font_family = "CaskaydiaCove Nerd Font";
    buffer_font_size = 16;
    languages = {
      Nix = {
        language_servers = [
          "nixd"
          "!nil"
        ];
      };
      QML = {
        formatter = {
          external = {
            arguments = [
              "-c"
              "tmp=$(mktemp --suffix .qml); cat > $tmp; qmlformat $tmp"
            ];
            command = "sh";
          };
        };
      };
    };
    lsp = {
      nixd = {
        settings = {
          formatting = {
            command = [ "alejandra" ];
          };
          nixpkgs = {
            expr = "import (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs {}";
          };
        };
      };
      qml = {
        binary = {
          arguments = [ "-E" ];
        };
      };
    };
    discord-presence-lsp = {
      binary = "steam-run";
      arguments = [
        "/home/xellor/.local/share/zed/extensions/work/discord-presence/discord-presence-lsp-v0.10.0/discord-presence-lsp-x86_64-unknown-linux-gnu/discord-presence-lsp"
      ];
    };
  };
  multi_cursor_modifier = "cmd_or_ctrl";
  theme = {
    dark = "One Dark";
    light = "One Light";
    mode = "system";
  };
  ui_font_size = 16;
};
}
