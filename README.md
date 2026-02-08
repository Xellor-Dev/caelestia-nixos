# caelestianix

**A declarative Home Manager framework for [caelestia-dots](https://github.com/caelestia-dots/caelestia) on NixOS.**

Caelestianix brings the beautiful caelestia dotfiles ecosystem into the reproducible world of Nix Flakes. Configure your entire desktop environment — Hyprland, terminal tools, editors, and more — using pure Nix expressions with deep customization support.

> [!NOTE]
> This is a fork of [caelestia-nix](https://github.com/Markus328/caelestia-nix) with significant enhancements for editor integrations and usability.

## ✨ Key Features

- **Declarative Configuration**: All dotfiles managed as Nix modules with type safety
- **Deep Customization**: Override any setting using infuse.nix sugars (`__prepend`, `__append`, etc.)
- **Modular Architecture**: Enable only what you need — Hyprland, editors, terminal, btop, etc.
- **VSCode/VSCodium Integration**: Full GitHub Copilot support with automatic configuration
- **Multiple Editors**: First-class support for VSCode, Zed, and Micro
- **Reproducible**: Lock dotfiles versions with flake.lock

## 🔄 What's New in This Fork

This fork extends the original caelestia-nix with:

- **VSCode/VSCodium Full Support**
    - GitHub Copilot enabled out-of-the-box
    - Automatic product.json patching for authentication
    - Writable settings.json for extension compatibility
    - VS Marketplace integration
- **Enhanced Editor Modules**
    - Added Zed editor configuration
    - Added Micro editor support
    - Unified editor interface under `programs.caelestia-dots.editor.*`

- **Hyprland 0.53+ Compatibility**
    - Updated rules and misc settings for latest Hyprland syntax
- **Improved Shell Integration**
    - Fixed settings path handling for caelestia shell modules

> [!WARNING]
> This module is in active development. Breaking changes may occur frequently as we refine the API.

## 🚀 Installation

Add `caelestianix` and `home-manager` as inputs to your flake, then include the module in your home configuration.

### Example `flake.nix`:

```nix
{
  description = "My NixOS configuration with caelestianix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    caelestianix.url = "github:Xellor-Dev/caelestia-nixos";
  };

  outputs = { self, nixpkgs, home-manager, caelestianix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations."user@nixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          caelestianix.homeManagerModules.default
        ];
      };
    };
}
```

### Basic `home.nix`:

```nix
{ config, pkgs, ... }:

{
  programs.caelestia-dots = {
    enable = true;

    # Optional: enable specific components
    hypr.enable = true;
    editor.vscode.enable = true;
    term.enable = true;
    btop.enable = true;
  };
}
```

## ⚙️ Customization

Caelestianix provides rich customization through the `settings` attribute and infuse.nix sugars.

### Basic Configuration

```nix
programs.caelestia-dots = {
  enable = true;

  # Hyprland keybindings
  hypr.hyprland.keybinds.settings.bind = [
    "SUPER, Return, exec, footclient"
    "SUPER SHIFT, Q, killactive"
  ];

  # Shell configuration
  caelestia.shell.settings = {
    launcher.actionPrefix = ".";
    battery.warnLevels.__prepend = [
      {
        level = 80;
        title = "High Battery";
        message = "Consider unplugging for battery health";
        icon = "battery_android_frame_5";
      }
    ];
  };

  # VSCode with Copilot
  editor.vscode = {
    enable = true;
    settings.userSettings = {
      "editor.fontSize" = 14;
      "workbench.colorTheme" = "Tokyo Night";
    };
  };
};
```

### Advanced: Infuse.nix Sugars

Use special keywords to modify nested configurations without rewriting defaults:

- `__prepend` - Add to beginning of list
- `__append` - Add to end of list
- `__override` - Replace entire value
- `__delete` - Remove a key

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for complete documentation.

## 📦 Available Modules

| Module            | Description                                   | Status      |
| ----------------- | --------------------------------------------- | ----------- |
| `hypr`            | Hyprland window manager + variables + schemes | ✅ Stable   |
| `caelestia.shell` | Caelestia shell integration                   | ✅ Stable   |
| `caelestia.cli`   | CLI tools configuration                       | ✅ Stable   |
| `editor.vscode`   | VSCode/VSCodium + Copilot                     | ✅ Enhanced |
| `editor.zed`      | Zed editor                                    | ✅ New      |
| `editor.micro`    | Micro terminal editor                         | ✅ New      |
| `term`            | Terminal tools (fish, eza, starship)          | ✅ Stable   |
| `btop`            | System monitor                                | ✅ Stable   |
| `foot`            | Foot terminal emulator                        | ✅ Stable   |

## 🙏 Credits

- [caelestia-dots](https://github.com/caelestia-dots/caelestia) - The amazing dotfiles that inspired this project
- [caelestia-nix](https://github.com/Markus328/caelestia-nix) - Original Home Manager module by Markus328
- [infuse.nix](https://codeberg.org/amjoseph/infuse.nix) - Deep configuration merging magic
- [Home Manager](https://github.com/nix-community/home-manager) - Declarative dotfiles management

## 📄 License

This project inherits the license from the original caelestia-nix project.

---

<br>

You can configure like you configure any other module option, but you have extras: **sugars**. For deeper instructions, read [CUSTOMIZATION](docs/CUSTOMIZATION.md)

## Thanks

- [caelestia-dots](https://github.com/caelestia-dots/caelestia), awesome dotfiles and shell
- [infuse.nix](https://codeberg.org/amjoseph/infuse.nix), greatly enhances customization

test
