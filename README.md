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

### Step 1: Add caelestianix to your `flake.nix`

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

  outputs = { self, nixpkgs, home-manager, caelestianix }:
    let
      username = "youruser";
      system = "x86_64-linux";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          caelestianix.homeManagerModules.default
          ./home.nix
        ];
      };
    };
}
```

### Step 2: Configure `home.nix`

```nix
{ config, pkgs, ... }:

{
  programs.caelestia-dots = {
    enable = true;

    # Enable the modules you want (caelestia is enabled by default)
    hypr.enable = true;       # Hyprland: all keybinds, colors, animations, etc from upstream
    editor.enable = true;     # VSCode/Zed/Micro from upstream
    term.enable = true;       # Fish + Starship + Eza from upstream
    btop.enable = true;       # System monitor from upstream
    foot.enable = true;       # Terminal emulator from upstream
  };

  # Rest of your Home Manager config (home.username, home.homeDirectory, etc)
}
```

### Step 3: Build and switch

```bash
# Build your Home Manager configuration
home-manager switch

# That's it! Your system now has:
# - Hyprland with all upstream keybinds, animations, color scheme, variables
# - All Nix store paths automatically substituted (hyprpicker, wpctl, etc)
# - Terminal configured exactly like upstream (starship, fish aliases)
# - Editors (VSCode with GitHub Copilot if enabled)
# - System monitor (btop)
```

### Step 4: Stay updated

```bash
# Pull latest caelestia-dots + nixpkgs updates
nix flake update

# Rebuild Home Manager
home-manager switch

# Done! All upstream changes are now applied to your system
```

---

## The Complete Workflow

### Scenario: You discover caelestia-dots and want it on NixOS

**Without caelestianix (traditional approach — doesn't work on NixOS):**

```bash
# Clone caelestia-dots
git clone https://github.com/caelestia-dots/caelestia ~/.config/caelestia

# Run install script
cd ~/.config/caelestia
./install.sh

# Manual steps to make paths work on NixOS (lots of breakage)
# Manually update when upstream changes
# No declarative config, hard to version control
```

**With caelestianix (NixOS-native approach):**

```bash
# 1. Create flake.nix with caelestianix input (done once)
# 2. Create home.nix with programs.caelestia-dots config (done once)

# 3. Apply the configuration
home-manager switch

# 4. Get updates (whenever you want)
nix flake update
home-manager switch

# Everything is:
# - Declaratively defined in Nix
# - Version controlled (flake.lock locks all versions)
# - Reproducible (can recreate the same system on another machine)
# - Easy to customize (override anything with infuse.nix)
```

### What happens when you run `home-manager switch`

1. **Parse upstream configs** → caelestianix reads from caelestia-dots flake input
    - `hypr/hyprland/*.conf` → parsed into Nix attrsets
    - `hypr/variables.conf` → 58 variables extracted
    - `hypr/scheme/default.conf` → 106 color tokens loaded
    - `starship/starship.toml` → TOML parsed
    - `vscode/settings.json` → JSON parsed
    - etc.

2. **Substitute Nix store paths** → commands replaced with real paths

    ```
    hyprpicker  →  /nix/store/...-hyprpicker-0.4.5/bin/hyprpicker
    wpctl       →  /nix/store/...-wireplumber-0.4.X/bin/wpctl
    notify-send →  /nix/store/...-libnotify-0.X/bin/notify-send
    ```

3. **Merge with your overrides** → infuse.nix combines upstream with your settings

    ```nix
    hypr.hyprland.keybinds.settings.bind.__append = [
      "SUPER, Return, exec, footclient"  # Your custom keybind
    ];
    # Now you have all upstream keybinds PLUS your custom one
    ```

4. **Generate Home Manager configuration** → all files written to `~/.config/`

    ```
    ~/.config/hypr/hyprland.conf  (generated from parsed upstream + your overrides)
    ~/.config/hypr/variables.conf
    ~/.config/hypr/hyprlandcolor.conf
    ~/.config/foot/foot.ini
    ~/.config/starship.toml
    ~/.config/Code/User/settings.json
    ...
    ```

5. **Activate** → Home Manager manages the files

### Example: You want to add a custom keybind

```nix
# home.nix
programs.caelestia-dots = {
  enable = true;
  hypr.enable = true;

  # Add your keybind to upstream ones (don't override, just append)
  hypr.hyprland.keybinds.settings.bind.__append = [
    "SUPER, Return, exec, footclient"  # Your custom bind
  ];
};
```

```bash
home-manager switch
```

Result: You now have **all 95+ upstream keybinds** from caelestia-dots PLUS your custom keybind.

No forking. No copy-paste. Just one line.

### Example: You want to customize the color scheme

```nix
programs.caelestia-dots = {
  enable = true;
  hypr.enable = true;

  # Override a specific color (keeps rest from upstream)
  hypr.scheme.settings.colors.base00.__override = "#000000";  # Pure black instead
};
```

```bash
home-manager switch
```

Result: Color scheme is mostly from upstream with your one custom color.

---

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
