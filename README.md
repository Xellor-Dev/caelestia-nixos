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

**📖 Full installation guide:** See [INSTALLATION.md](docs/INSTALLATION.md)

Add `caelestianix` and `home-manager` as inputs to your flake, then include the module in your home configuration.

### Quick Start

1. Add to your `flake.nix`:

```nix
caelestianix = {
  url = "github:Xellor-Dev/caelestia-nixos";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

2. Include in Home Manager modules:

```nix
modules = [
  ./home.nix
  caelestianix.homeManagerModules.default
];
```

3. Configure in `home.nix` (see below)

### Basic `home.nix`:

```nix
{ config, pkgs, ... }:

{
  programs.caelestia-dots = {
    enable = true;

    # Optional: enable specific components (all default to false except caelestia)
    hypr = {
      enable = true;
    };

    editor = {
      enable = true;
    };

    term = {
      enable = true;
    };

    btop = {
      enable = true;
    };

    foot = {
      enable = true;
    };

    caelestia = {
      enable = true;  # Caelestia shell (enabled by default)
    };
  };
}
```

## Module Configuration

Each module can be independently enabled or disabled. Below are the available modules:

### Hyprland (`hypr`)

```nix
programs.caelestia-dots.hypr = {
  enable = true;

  # Configure which services to enable (all default to true)
  services = {
    gnomeKeyring.enable = true;
    polkitGnome.enable = true;
    gammastep = {
      enable = true;
      provider = "geoclue2";  # or "manual"
    };
    cliphist.enable = true;
  };
};
```

### Editors (`editor`)

```nix
programs.caelestia-dots.editor = {
  enable = true;

  # Configure individual editors
  vscode.enable = true;
  zed.enable = true;
  micro.enable = true;
};
```

### Terminal (`term`)

```nix
programs.caelestia-dots.term.enable = true;
```

### System Monitor (`btop`)

```nix
programs.caelestia-dots.btop.enable = true;
```

### Terminal Emulator (`foot`)

```nix
programs.caelestia-dots.foot.enable = true;
```

### Caelestia Shell (`caelestia`)

```nix
programs.caelestia-dots.caelestia = {
  enable = true;  # Enabled by default
};
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

## ✅ Requirements

- **NixOS 23.05 or newer**
- **Flakes enabled** in nix.conf
- **Home Manager** configured
- **x86_64-linux** system (aarch64-linux support planned)
- **Wayland environment** (for Hyprland module)

---

## 📚 Documentation

- **[INSTALLATION.md](docs/INSTALLATION.md)** - Complete step-by-step installation guide
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** - Advanced customization and module options
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Solutions to common problems
- **[FAQ.md](docs/FAQ.md)** - Frequently asked questions
- **[Examples](examples/)** - Ready-to-use configuration examples
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

---

## 🐛 Troubleshooting

Having issues? Check the [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) guide for solutions to common problems.

**Common Issues:**

- "hyprland must be enabled" → See [Troubleshooting: Hyprland](docs/TROUBLESHOOTING.md#error-hyprland-must-be-enabled-in-waylandwindowmanagerhydrland-to-use-caelestia-hypr-module)
- "Copilot not working" → See [Troubleshooting: Copilot](docs/TROUBLESHOOTING.md#copilot-not-working-in-vscode)
- Keybinds not working → See [Troubleshooting: Keybinds](docs/TROUBLESHOOTING.md#keybinds-not-working)

---

## 🤝 Contributing

Contributions are welcome! Whether it's bug reports, documentation improvements, or new features:

1. **Report bugs** - Open an [issue](https://github.com/Xellor-Dev/caelestia-nixos/issues)
2. **Suggest features** - Start a [discussion](https://github.com/Xellor-Dev/caelestia-nixos/discussions)
3. **Submit PRs** - Fork and create a pull request

---

## 📞 Support

- **GitHub Issues** - For bugs and feature requests
- **GitHub Discussions** - For general questions
- **caelestia-dots community** - For caelestia-specific questions

---
