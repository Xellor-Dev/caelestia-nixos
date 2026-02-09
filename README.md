# caelestianix

**Use [caelestia-dots](https://github.com/caelestia-dots/caelestia) on NixOS — without manual dotfile management.**

## The Problem

[caelestia-dots](https://github.com/caelestia-dots/caelestia) is a beautiful, feature-rich desktop environment built on Hyprland. But it's designed for traditional Linux distros: you clone the repo, run install scripts, and manually track updates. On NixOS this approach breaks — the system is immutable, paths are in `/nix/store`, and configs must be declared, not copied.

**caelestianix solves this.** It's a Home Manager module that:

1. **Reads upstream caelestia-dots configs at build time** — Hyprland settings, keybinds, color schemes, animations, terminal configs, and more are parsed directly from the [caelestia-dots repo](https://github.com/caelestia-dots/caelestia) during `nix build`. No manual copying.
2. **Automatically stays in sync** — run `nix flake update` and all upstream changes flow in. No need to manually track what changed in caelestia-dots.
3. **Adapts paths for NixOS** — commands like `hyprpicker`, `cliphist`, `wpctl` are automatically replaced with their `/nix/store/...` equivalents so everything actually works on NixOS.
4. **Lets you override anything** — thanks to [infuse.nix](https://codeberg.org/amjoseph/infuse.nix), you can prepend, append, or replace any setting without forking upstream.

> [!NOTE]
> Fork of [caelestia-nix](https://github.com/Markus328/caelestia-nix) with upstream auto-sync, editor integrations (VSCode/Copilot), and expanded module coverage.

## How It Works

```
caelestia-dots repo (upstream)          caelestianix (this module)           Your NixOS system
┌─────────────────────────┐        ┌──────────────────────────────┐     ┌──────────────────────┐
│ hyprland/*.conf          │──parse──▶ Nix attrsets                │     │                      │
│ variables.conf           │──parse──▶ + substitute Nix store paths│──▶  │ ~/.config/hypr/...   │
│ scheme/default.conf      │──parse──▶ + user overrides (infuse)   │     │ ~/.config/foot/...   │
│ foot/foot.ini            │──parse──▶ + Home Manager integration  │     │ ~/.config/starship/  │
│ starship/starship.toml   │──parse──▶                              │     │ ...                  │
│ btop/btop.conf           │──parse──▶                              │     │                      │
└─────────────────────────┘        └──────────────────────────────┘     └──────────────────────┘
```

**17 config modules** read from upstream automatically. Parsers handle each format:

- **Hyprconf** (`.conf`) → custom `parseSections` / `parseVars` parser
- **TOML** (starship) → `builtins.fromTOML`
- **JSON** (VSCode) → `builtins.fromJSON`
- **INI** (foot) → custom INI parser
- **Key=Value** (btop) → custom parser

## Quick Start

### 1. Add to `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestianix = {
      url = "github:Xellor-Dev/caelestia-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Include the module

```nix
home-manager.users.youruser = {
  imports = [
    caelestianix.homeManagerModules.default
  ];
};
```

### 3. Enable what you need in `home.nix`

```nix
{
  programs.caelestia-dots = {
    enable = true;

    hypr.enable = true;       # Hyprland: keybinds, animations, rules, colors, variables
    editor.enable = true;     # VSCode/Zed/Micro with caelestia theme
    term.enable = true;       # Fish + Starship + Eza
    btop.enable = true;       # System monitor
    foot.enable = true;       # Terminal emulator
    caelestia.enable = true;  # Caelestia shell & CLI (enabled by default)
  };
}
```

### 4. Stay updated

```bash
nix flake update         # pulls latest caelestia-dots + nixpkgs
home-manager switch      # rebuilds with new upstream configs
```

That's it. No install scripts, no `git pull` into `~/.config`, no manual syncing.

## Modules

| Module          | What it configures                                                                                         | Upstream source                                                           |
| --------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `hypr`          | Hyprland WM — keybinds, animations, decorations, rules, input, gestures, env vars, color scheme, variables | `hypr/hyprland/*.conf`, `hypr/variables.conf`, `hypr/scheme/default.conf` |
| `editor.vscode` | VSCode/VSCodium + GitHub Copilot + product.json patching                                                   | `vscode/settings.json`                                                    |
| `editor.zed`    | Zed editor settings                                                                                        | `zed/settings.json`                                                       |
| `editor.micro`  | Micro terminal editor                                                                                      | `micro/settings.json`                                                     |
| `term`          | Fish shell + Starship prompt + Eza aliases                                                                 | `starship/starship.toml`                                                  |
| `btop`          | System monitor                                                                                             | `btop/btop.conf`                                                          |
| `foot`          | Foot terminal emulator                                                                                     | `foot/foot.ini`                                                           |
| `caelestia`     | Caelestia shell integration & CLI tools                                                                    | —                                                                         |

## Customization

Override any upstream setting without forking — infuse.nix merges your values with upstream:

```nix
programs.caelestia-dots = {
  # Add your own keybinds alongside upstream ones
  hypr.hyprland.keybinds.settings.bind.__append = [
    "SUPER, Return, exec, footclient"
  ];

  # Override a specific animation
  hypr.hyprland.animations.settings.animations.animation.__override = [
    "windows, 1, 3, easeOut, slide"
  ];

  # Customize shell settings
  caelestia.shell.settings = {
    launcher.actionPrefix = ".";
    battery.warnLevels.__prepend = [
      { level = 80; title = "High Battery"; message = "Unplug"; icon = "battery_5"; }
    ];
  };

  # VSCode extra settings
  editor.vscode.settings.userSettings = {
    "editor.fontSize" = 14;
    "workbench.colorTheme" = "Tokyo Night";
  };
};
```

**Available infuse.nix operations:** `__prepend`, `__append`, `__override`, `__delete`

## Hyprland Services

The `hypr` module optionally sets up supporting services:

```nix
programs.caelestia-dots.hypr.services = {
  gnomeKeyring.enable = true;      # Secret storage
  polkitGnome.enable = true;       # Privilege escalation
  gammastep.enable = true;         # Night light (geoclue2 or manual)
  cliphist.enable = true;          # Clipboard history
};
```

All default to `true` but can be individually disabled.

## Requirements

- **NixOS** with Flakes enabled
- **Home Manager**
- **x86_64-linux**
- **Wayland** (for Hyprland module)

## Credits

- [caelestia-dots](https://github.com/caelestia-dots/caelestia) — the upstream dotfiles
- [caelestia-nix](https://github.com/Markus328/caelestia-nix) — original module by Markus328
- [infuse.nix](https://codeberg.org/amjoseph/infuse.nix) — deep config merging
- [Home Manager](https://github.com/nix-community/home-manager) — declarative dotfiles on NixOS

## License

Inherits the license from the original caelestia-nix project.
