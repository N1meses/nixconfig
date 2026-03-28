{inputs, ...}: {
  flake.modules.homeManager.noctalia = {
    config,
    lib,
    ...
  }: let
    cfg = config.features.desktop.noctalia;
    flakeRoot = inputs.self;
  in {
    imports = [inputs.noctalia.homeModules.default];

    options.features.desktop.noctalia = {
      enable = lib.mkEnableOption "Noctalia shell";
    };

    config = lib.mkIf cfg.enable {
      features.compositors.niri.autoStart = ["noctalia-shell"];
      features.compositors.hyprland.autoStart = ["noctalia-shell"];

      programs.noctalia-shell = {
        enable = true;

        settings = {
          appLauncher = {
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWrapText = true;
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            pinnedApps = [];
            viewMode = "list";
            showCategories = true;
            iconMode = "tabler";
            showIconBackground = false;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            ignoreMouseInput = false;
            screenshotAnnotationTool = "";
            backgroundOpacity = 0.69;
            customLaunchPrefix = "";
            customLaunchPrefixEnabled = false;
            enableClipboardHistory = true;
            pinnedExecs = [];
            position = "bottom_center";
            sortByMostUsed = true;
            terminalCommand = "ghostty -e";
            useApp2Unit = false;
          };

          audio = {
            cavaFrameRate = 60;
            mprisBlacklist = [];
            preferredPlayer = "";
            visualizerQuality = "high";
            visualizerType = "linear";
            volumeOverdrive = false;
            volumeStep = 2;
          };

          bar = {
            barType = "floating";
            showOutline = false;
            capsuleOpacity = 1;
            useSeparateOpacity = false;
            frameThickness = 8;
            frameRadius = 12;
            hideOnOverview = true;
            displayMode = lib.mkDefault "floating";
            autoHideDelay = 500;
            autoShowDelay = 150;
            backgroundOpacity = 0.955555;
            density = "default";
            exclusive = true;
            floating = true;
            marginHorizontal = lib.mkDefault 8;
            marginVertical = lib.mkDefault 8;
            monitors = [];
            outerCorners = false;
            position = lib.mkDefault "left";
            showCapsule = true;
            widgets = {
              center = [];
              left = [
                {
                  customIconPath = "${flakeRoot}/assets/icons/nixos.png";
                  icon = "NixOS";
                  id = "ControlCenter";
                  useDistroLogo = false;
                }
                {id = "Tray";}
                {id = "plugin:simple-notes";}
                {id = "plugin:todo";}
                {id = "TaskbarGrouped";}
              ];
              right = [
                {
                  id = "AudioVisualizer";
                  width = 200;
                  hideWhenIdle = true;
                }
                {id = "WallpaperSelector";}
                {
                  id = "SystemMonitor";
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskUsage = false;
                  showMemoryAsPercent = true;
                  showMemoryUsage = true;
                  showNetworkStats = true;
                  usePrimaryColor = true;
                }
                {
                  displayMode = "alwaysshow";
                  id = "Battery";
                  warningThreshold = 30;
                }
                {
                  displayMode = "onhover";
                  id = "Volume";
                }
                {
                  displayMode = "onhover";
                  id = "Bluetooth";
                }
                {
                  displayMode = "onhover";
                  id = "WiFi";
                }
                {
                  defaultSettings = {
                    compactMode = false;
                    defaultPeerAction = "copy-ip";
                    hideDisconnected = false;
                    pingCount = 5;
                    refreshInterval = 5000;
                    showIpAddress = true;
                    showPeerCount = true;
                    terminalCommand = "";
                  };
                  id = "plugin:tailscale";
                }
                {id = "plugin:promodoro";}
                {
                  customFont = "";
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  id = "Clock";
                  useCustomFont = false;
                  usePrimaryColor = true;
                }
                {
                  id = "SessionMenu";
                  compactMode = true;
                }
              ];
            };
          };

          battery.chargingMode = 0;

          brightness = {
            brightnessStep = 2;
            enableDdcSupport = false;
            enforceMinimum = true;
          };

          colorSchemes = {
            predefinedScheme = "Noctalia (default)";
            monitorForColors = "";
            darkMode = true;
            generateTemplatesForPredefined = false;
            manualSunrise = "06:30";
            manualSunset = "18:30";
            generationMethod = "rainbow";
            schedulingMode = "off";
            useWallpaperColors = true;
          };

          templates.activeTemplates = [
            {
              enabled = true;
              id = "ghostty";
            }
            {
              enabled = true;
              id = "gtk";
            }
            {
              enabled = true;
              id = "qt";
            }
            {
              enabled = true;
              id = "btop";
            }
            {
              enabled = true;
              id = "discord";
            }
          ];

          controlCenter = {
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
            position = "close_to_bar_button";
            shortcuts = {
              left = [
                {id = "WiFi";}
                {id = "Bluetooth";}
                {id = "PowerProfile";}
                {id = "Notifications";}
              ];
              right = [
                {id = "KeepAwake";}
                {id = "NightLight";}
                {id = "ScreenRecorder";}
                {id = "WallpaperSelector";}
              ];
            };
          };

          dock = {
            backgroundOpacity = 0.69;
            colorizeIcons = false;
            displayMode = "auto_hide";
            enabled = lib.mkDefault false;
            floatingRatio = 0.5;
            monitors = [];
            onlySameOutput = true;
            pinnedApps = [];
            size = 1;
          };

          general = {
            animationDisabled = false;
            animationSpeed = 1.5;
            avatarImage = "${flakeRoot}/assets/icons/hunter.jpeg";
            compactLockScreen = false;
            dimDesktop = true;
            enableShadows = false;
            forceBlackScreenCorners = true;
            language = "";
            lockOnSuspend = true;
            radiusRatio = 0.95;
            scaleRatio = 1;
            screenRadiusRatio = 1;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            showScreenCorners = true;
          };

          hooks = {
            darkModeChange = "";
            enabled = false;
            wallpaperChange = "";
          };

          location = {
            analogClockInCalendar = false;
            firstDayOfWeek = -1;
            name = "Tokyo";
            showCalendarEvents = true;
            showCalendarWeather = true;
            showWeekNumberInCalendar = false;
            use12hourFormat = false;
            useFahrenheit = false;
            weatherEnabled = false;
          };

          network.wifiEnabled = true;

          nightLight = {
            autoSchedule = true;
            dayTemp = "6500";
            enabled = false;
            forced = false;
            manualSunrise = "06:30";
            manualSunset = "18:30";
            nightTemp = "4000";
          };

          notifications = {
            backgroundOpacity = 0.69;
            criticalUrgencyDuration = 15;
            doNotDisturb = false;
            enabled = true;
            location = "top_right";
            lowUrgencyDuration = 3;
            monitors = [];
            normalUrgencyDuration = 8;
            overlayLayer = true;
            respectExpireTimeout = false;
          };

          osd = {
            autoHideMs = 2000;
            enabled = true;
            location = "top_right";
            monitors = [];
            overlayLayer = true;
          };

          screenRecorder = {
            audioCodec = "opus";
            audioSource = "default_output";
            colorRange = "limited";
            directory = "${config.xdg.userDirs.videos}";
            frameRate = 60;
            quality = "very_high";
            showCursor = true;
            videoCodec = "h264";
            videoSource = "portal";
          };

          settingsVersion = 21;
          setupCompleted = true;

          ui = {
            panelBackgroundOpacity = 0.93;
            settingsPanelMode = "attached";
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            networkPanelView = "wifi";
            bluetoothHideUnnamedDevices = false;
            boxBorderEnabled = false;
            fontDefault = "IBM Plex";
            fontDefaultScale = 1;
            fontFixed = "IBM Plex Mono";
            fontFixedScale = 1;
            panelsAttachedToBar = true;
            settingsPanelAttachToBar = false;
            tooltipsEnabled = true;
          };

          wallpaper = {
            monitorDirectories = [];
            showHiddenFiles = false;
            viewMode = "single";
            useSolidColor = false;
            solidColor = "#1a1a2e";
            automationEnabled = false;
            wallpaperChangeMode = "random";
            hideWallpaperFilenames = false;
            useWallhaven = false;
            wallhavenQuery = "";
            wallhavenSorting = "favorites";
            wallhavenOrder = "desc";
            wallhavenCategories = "110";
            wallhavenPurity = "100";
            wallhavenRatios = "";
            wallhavenApiKey = "";
            wallhavenResolutionMode = "atleast";
            wallhavenResolutionWidth = "";
            wallhavenResolutionHeight = "";
            sortOrder = "name";
            defaultWallpaper = "${config.xdg.userDirs.pictures}/Wallpapers/wallhaven_exkqk8.jpg";
            directory = "${config.xdg.userDirs.pictures}/Wallpapers";
            enableMultiMonitorDirectories = false;
            enabled = true;
            fillColor = "#000000";
            fillMode = "crop";
            monitors = [];
            overviewEnabled = false;
            panelPosition = "follow_bar";
            randomEnabled = true;
            randomIntervalSec = 600;
            recursiveSearch = false;
            setWallpaperOnAllMonitors = true;
            transitionDuration = 750;
            transitionEdgeSmoothness = 0.05;
            transitionType = "random";
          };
        };
      };
    };
  };
}
