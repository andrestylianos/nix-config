{
  config,
  pkgs,
  ...
}: let

  homeDir = config.home.homeDirectory;

  emoji = "${pkgs.wofi-emoji}/bin/wofi-emoji";
  launcher = "wofi";
in {
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER

    # scale apps
    exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2

    exec-once = eww open bar

    misc {
      # enable Variable Frame Rate
      vfr = true
      # disable auto polling for config file changes
      disable_autoreload = true
      focus_on_activate = true
    }

    input {
      kb_layout = us

      # focus change on cursor move
      follow_mouse = 1
      accel_profile = flat
    }

    general {
      gaps_in = 5
      gaps_out = 5
      border_size = 2

    }

    decoration {
      rounding = 16
      blur = true
      blur_size = 3
      blur_passes = 3
      blur_new_optimizations = true

      drop_shadow = true
      shadow_ignore_window = true
      shadow_offset = 2 2
      shadow_range = 4
      shadow_render_power = 1
      col.shadow = 0x55000000
    }

    animations {
      enabled = true
      animation = border, 1, 2, default
      animation = fade, 1, 4, default
      animation = windows, 1, 3, default, popin 80%
      animation = workspaces, 1, 2, default, slide
    }

    dwindle {
      # keep floating dimentions while tiling
      pseudotile = true
      preserve_split = true
    }

    # make Firefox PiP window floating and sticky
    windowrulev2 = float, title:^(Picture-in-Picture)$
    windowrulev2 = pin, title:^(Picture-in-Picture)$

    # throw sharing indicators away
    windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
    windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

    # start spotify tiled in ws9
    windowrulev2 = tile, class:^(Spotify)$
    windowrulev2 = workspace 9 silent, class:^(Spotify)$

    # start Discord/WebCord in ws2
    windowrulev2 = workspace 2, title:^(.*(Disc|WebC)ord.*)$

    # idle inhibit while watching videos
    windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
    windowrulev2 = idleinhibit fullscreen, class:^(firefox)$

    # mouse movements
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
    bindm = $mod ALT, mouse:272, resizewindow

    # compositor commands
    bind = $mod SHIFT, E, exec, pkill Hyprland
    bind = $mod, Q, killactive,
    bind = $mod, F, fullscreen,
    bind = $mod, G, togglegroup,
    bind = $mod SHIFT, N, changegroupactive, f
    bind = $mod SHIFT, P, changegroupactive, b
    bind = $mod, R, togglesplit,
    bind = $mod, T, togglefloating,
    bind = $mod, P, pseudo,
    bind = $mod ALT, ,resizeactive,
    # toggle "monocle" (no_gaps_when_only)
    $kw = dwindle:no_gaps_when_only
    bind = $mod, M, exec, hyprctl keyword $kw $(($(hyprctl getoption $kw -j | jaq -r '.int') ^ 1))

    # utility
    # launcher
    bindr = $mod, SUPER_L, exec, pkill .${launcher}-wrapped || run-as-service ${launcher}
    # terminal
    bind = $mod, Return, exec, run-as-service kitty
    # logout menu
    bind = $mod, Escape, exec, wlogout -p layer-shell
    # lock screen
    bind = $mod, L, exec, loginctl lock-session
    # emoji picker
    bind = $mod, E, exec, ${emoji}
    # select area to perform OCR on
    bind = $mod, O, exec, run-as-service wl-ocr

    # move focus
    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d

    # window resize
    bind = $mod, S, submap, resize

    submap = resize
    binde = , right, resizeactive, 10 0
    binde = , left, resizeactive, -10 0
    binde = , up, resizeactive, 0 -10
    binde = , down, resizeactive, 0 10
    bind = , escape, submap, reset
    submap = reset

    # media controls
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioPrev, exec, playerctl previous
    bindl = , XF86AudioNext, exec, playerctl next

    # volume
    bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%+
    binde = , XF86AudioRaiseVolume, exec, ${homeDir}/.config/eww/scripts/volume osd
    bindle = , XF86AudioLowerVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%-
    binde = , XF86AudioLowerVolume, exec, ${homeDir}/.config/eww/scripts/volume osd
    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bind = , XF86AudioMute, exec, ${homeDir}/.config/eww/scripts/volume osd
    bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # backlight
    bindle = , XF86MonBrightnessUp, exec, light -A 5
    binde = , XF86MonBrightnessUp, exec, ${homeDir}/.config/eww/scripts/brightness osd
    bindle = , XF86MonBrightnessDown, exec, light -U 5
    binde = , XF86MonBrightnessDown, exec, ${homeDir}/.config/eww/scripts/brightness osd

    # screenshot
    # stop animations while screenshotting; makes black border go away
    #$screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
    #bind = , Print, exec, $screenshotarea
    #bind = $mod SHIFT, R, exec, $screenshotarea

    #bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
    #bind = $mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output

    #bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
    #bind = $mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen

    # workspaces
    # binds mod + [shift +] {1..10} to [move to] ws {1..10}
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}

    # special workspace
    bind = $mod SHIFT, grave, movetoworkspace, special
    bind = $mod, grave, togglespecialworkspace, eDP-1

    # cycle workspaces
    bind = $mod, bracketleft, workspace, m-1
    bind = $mod, bracketright, workspace, m+1
    # cycle monitors
    bind = $mod SHIFT, braceleft, focusmonitor, l
    bind = $mod SHIFT, braceright, focusmonitor, r
  '';
}