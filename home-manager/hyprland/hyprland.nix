# home.nix
{config, pkgs, ...}: {
   
  imports = [ ./keybinds.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
  };
  wayland.windowManager.hyprland.extraConfig = ''

  exec-once = $HOME/config/home-manager/hyprland/autostart.sh  
  
  general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 5
    gaps_out = 10
    border_size = 1
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    apply_sens_to_raw = 1; # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)

  }; 

  misc {
  force_hypr_chan = true;
  };

  decoration {
    active_opacity = 0.94
    inactive_opacity = 0.84
    fullscreen_opacity = 1.0
    rounding = 5
    
    blur {
      enabled = true
      size = 5
      passes = 1
      new_optimizations = on
      ignore_opacity = true
    }

    multisample_edges = true
    drop_shadow = true
    shadow_range= 4
    shadow_offset = 4 4 # 10 10
    shadow_render_power = 1
    col.shadow=rgba(0a0a0caa) 
  };

  animations {
    enabled = true;

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
  }; 

  '';
}
