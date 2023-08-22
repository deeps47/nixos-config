{

  wayland.windowManager.hyprland.extraConfig = ''
    $mainMod = SUPER

    bind = $mainMod, RETURN, exec, kitty
    bind = $mainMod, C, killactive
    bind = $mainMod, R, exec, rofi -show drun -show-icons
    bind = , Print, exec, grimblast copy area

    # workspaces
    # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = $mainMod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow


    # Move focus with mainMod + arrow keys
    bind = $mainMod, h, movefocus, l
    bind = $mainMod, l, movefocus, r
    bind = $mainMod, j, movefocus, u
    bind = $mainMod, k, movefocus, d


    # Moving windows
    bind = $mainMod SHIFT, left, movewindow,l
    bind = $mainMod SHIFT, right, movewindow,r
    bind = $mainMod SHIFT, up, movewindow,u
    bind = $mainMod SHIFT, down, movewindow,d

    # Brightness keybinds
    binde = , XF86MonBrightnessUp,     exec, brightness set 10%+
    binde = , XF86MonBrightnessDown,   exec, brightness set 10%-

    # Audio Keybinds
    binde = , xf86audioraisevolume, exec, volume -i 5
    binde = , xf86audiolowervolume, exec, volume -d 5
    binde = , XF86AudioMute, exec, volume -t


  '';
 
 
}
