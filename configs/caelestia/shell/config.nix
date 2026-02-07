#
# caelestia shell — config.nix (Вариант B: модульный рефакторинг)
#
# Этот файл экспортирует дефолтный attrset для types.pass.
# Статические значения вынесены в хелперы (options.nix),
# здесь остаются только структурные дефолты + динамическая кросс-модульная проводка.
#
{
  config,
  options,
  dots,
  use,
  ...
}:
let
  opts = import ./options.nix { inherit (config._module.args) lib; };
  inherit (opts) mkEntry mkAction sessionCommands;
in
{
  package = options.programs.caelestia.package.default;

  settings = {

    # ── Appearance ──────────────────────────────────────────────────────
    appearance = {
      anim.durations.scale = 1;
      font = {
        family = {
          clock    = "Rubik";
          material = "Material Symbols Rounded";
          mono     = "CaskaydiaCove NF";
          sans     = "Rubik";
        };
        size.scale = 1;
      };
      padding.scale      = 1;
      rounding.scale     = 1;
      spacing.scale      = 1;
      transparency = {
        enabled = false;
        base    = 0.85;
        layers  = 0.4;
      };
    };

    # ── Background ──────────────────────────────────────────────────────
    background = {
      enabled      = true;
      desktopClock = { enabled = false; };
      visualiser = {
        enabled  = false;
        autoHide = true;
        rounding = 1;
        spacing  = 1;
      };
    };

    # ── Bar ─────────────────────────────────────────────────────────────
    bar = {
      clock.showIcon = true;
      dragThreshold  = 20;
      persistent     = true;
      showOnHover    = true;

      # Компактная запись через хелпер — каждый виджет в одну строку
      entries = map mkEntry [
        "logo" "workspaces" "spacer" "activeWindow"
        "spacer" "tray" "clock" "statusIcons" "power"
      ];

      scrollActions = {
        brightness = true;
        volume     = true;
        workspaces = true;
      };

      status = {
        showAudio      = false;
        showBattery    = true;
        showBluetooth  = true;
        showKbLayout   = false;
        showLockStatus = true;
        showMicrophone = false;
        showNetwork    = true;
      };

      tray = {
        background = false;
        compact    = false;
        iconSubs   = [];
        recolour   = false;
      };

      workspaces = {
        activeIndicator      = true;
        activeLabel          = "󰮯";
        activeTrail          = false;
        label                = "  ";
        occupiedBg           = false;
        occupiedLabel        = "󰮯";
        perMonitorWorkspaces = true;
        showWindows          = true;
        shown                = 5;
        specialWorkspaceIcons = [
          { name = "steam"; icon = "sports_esports"; }
        ];
      };
    };

    # ── Border ──────────────────────────────────────────────────────────
    border = {
      rounding  = 25;
      thickness = 10;
    };

    # ── Dashboard ───────────────────────────────────────────────────────
    dashboard = {
      enabled             = true;
      showOnHover         = true;
      dragThreshold       = 50;
      mediaUpdateInterval = 500; # мс
    };

    # ── General (кросс-модульная проводка через `use`) ──────────────────
    general = {
      apps = {
        audio    = [ "pavucontrol" ];
        playback = [ "mpv" ];
        # Динамические дефолты — единственная причина, по которой use нужен в config.nix
        explorer = [ (use "hypr.variables" "fileExplorer" "thunar") ];
        terminal = [ (use "hypr.variables" "terminal"     "foot") ];
      };

      battery = {
        criticalLevel = 3;
        warnLevels = [
          {
            level   = 20;
            icon    = "battery_android_frame_2";
            title   = "Low battery";
            message = "You might want to plug in a charger";
          }
          {
            level   = 10;
            icon    = "battery_android_frame_1";
            title   = "Did you see the previous message?";
            message = "You should probably plug in a charger <b>now</b>";
          }
          {
            level    = 5;
            icon     = "battery_android_alert";
            title    = "Critical battery level";
            message  = "PLUG THE CHARGER RIGHT NOW!!";
            critical = true;
          }
        ];
      };

      idle = {
        inhibitWhenAudio = true;
        lockBeforeSleep  = true;
        timeouts = [
          { timeout = 180; idleAction = "lock"; }
          { timeout = 300; idleAction = "dpms off"; returnAction = "dpms on"; }
          { timeout = 600; idleAction = sessionCommands.sleep; }
        ];
      };
    };

    # ── Launcher ────────────────────────────────────────────────────────
    launcher = {
      actionPrefix  = ">";
      specialPrefix = "@";
      dragThreshold = 50;
      maxShown      = 7;
      maxWallpapers = 9;
      showOnHover   = false;
      vimKeybinds   = false;
      hiddenApps    = [];
      enableDangerousActions = false;

      useFuzzy = {
        actions    = false;
        apps       = false;
        schemes    = false;
        variants   = false;
        wallpapers = false;
      };

      # Действия используют единый источник команд (sessionCommands) и хелпер mkAction
      actions = [
        (mkAction { name = "Calculator";    icon = "calculate";          description = "Do simple math equations (powered by Qalc)";  command = [ "autocomplete" "calc" ]; })
        (mkAction { name = "Scheme";        icon = "palette";            description = "Change the current colour scheme";            command = [ "autocomplete" "scheme" ]; })
        (mkAction { name = "Wallpaper";     icon = "image";              description = "Change the current wallpaper";                command = [ "autocomplete" "wallpaper" ]; })
        (mkAction { name = "Variant";       icon = "colors";             description = "Change the current scheme variant";           command = [ "autocomplete" "variant" ]; })
        (mkAction { name = "Transparency";  icon = "opacity";            description = "Change shell transparency";                   command = [ "autocomplete" "transparency" ]; enabled = false; })
        (mkAction { name = "Random";        icon = "casino";             description = "Switch to a random wallpaper";                command = [ "${dots.caelestia.cli.package}/bin/caelestia" "wallpaper" "-r" ]; })
        (mkAction { name = "Light";         icon = "light_mode";         description = "Change the scheme to light mode";             command = [ "setMode" "light" ]; })
        (mkAction { name = "Dark";          icon = "dark_mode";          description = "Change the scheme to dark mode";              command = [ "setMode" "dark" ]; })
        (mkAction { name = "Shutdown";      icon = "power_settings_new"; description = "Shutdown the system";                         command = sessionCommands.shutdown;  dangerous = true; })
        (mkAction { name = "Reboot";        icon = "cached";             description = "Reboot the system";                           command = sessionCommands.reboot;    dangerous = true; })
        (mkAction { name = "Logout";        icon = "exit_to_app";        description = "Log out of the current session";              command = sessionCommands.logout;    dangerous = true; })
        (mkAction { name = "Lock";          icon = "lock";               description = "Lock the current session";                    command = sessionCommands.lock; })
        (mkAction { name = "Sleep";         icon = "bedtime";            description = "Suspend then hibernate";                      command = sessionCommands.sleep; })
      ];
    };

    # ── Lock ────────────────────────────────────────────────────────────
    lock.recolourLogo = false;

    # ── Notifications ───────────────────────────────────────────────────
    notifs = {
      actionOnClick        = false;
      expire               = false;
      clearThreshold       = 0.3;
      defaultExpireTimeout = 5000; # мс
      expandThreshold      = 20;
    };

    # ── OSD ─────────────────────────────────────────────────────────────
    osd = {
      enabled          = true;
      enableBrightness = true;
      enableMicrophone = false;
      hideDelay        = 2000; # мс
    };

    # ── Paths ───────────────────────────────────────────────────────────
    paths = {
      mediaGif     = "root:/assets/bongocat.gif";
      sessionGif   = "root:/assets/kurukuru.gif";
      wallpaperDir = "~/Pictures/Wallpapers";
    };

    # ── Services (кросс-модульная проводка через use) ──────────────────
    services = {
      # Динамическая привязка к hypr.variables
      audioIncrement     = (use "hypr.variables" "volumeStep" 10.0) / 100.0;
      defaultPlayer      = "Spotify";
      gpuType            = "";
      maxVolume          = 1;
      smartScheme        = true;
      useFahrenheit      = false;
      useTwelveHourClock = false;
      visualiserBars     = 45;
      weatherLocation    = "";
      playerAliases = [
        { from = "com.github.th_ch.youtube_music"; to = "YT Music"; }
      ];
    };

    # ── Session (команды берутся из единого sessionCommands) ─────────────
    session = {
      enabled       = true;
      vimKeybinds   = false;
      dragThreshold = 30;
      commands = {
        inherit (sessionCommands) shutdown reboot logout hibernate;
      };
    };

    # ── Sidebar ─────────────────────────────────────────────────────────
    sidebar = {
      enabled       = true;
      dragThreshold = 80;
    };

    # ── Utilities ───────────────────────────────────────────────────────
    utilities = {
      enabled   = true;
      maxToasts = 4;

      toasts = {
        audioInputChanged  = true;
        audioOutputChanged = true;
        capsLockChanged    = true;
        chargingChanged    = true;
        configLoaded       = true;
        dndChanged         = true;
        gameModeChanged    = true;
        kbLayoutChanged    = true;
        nowPlaying         = false;
        numLockChanged     = true;
        vpnChanged         = true;
      };

      vpn = {
        enabled  = false;
        provider = [
          {
            name        = "wireguard";
            interface   = "your-connection-name";
            displayName = "Wireguard (Your VPN)";
          }
        ];
      };
    };
  };
}
