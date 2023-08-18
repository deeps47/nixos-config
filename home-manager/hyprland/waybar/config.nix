_: let
    font = "JetBrainsMono Nerd Font";
in {

mainbar = {
    layer = "top"; 
    position = "top"; 
    height = 30; 
    spacing = 4;

    modules-left = [ "wlr/workspaces" "hyprland/submap"];
    modules-right = [ "memory" "cpu" "battery" "pulseaudio" "network" "clock" "tray" ];
    modules-center = [ ];

    "wlr/workspaces" = {
      format = "{name}";
      on-click = "activate";
    };
   
    "tray" = {
      spacing = 10; 
    };

    "cpu" = {
      on-click = "kitty -e btop";
      format = " {usage}%";
      tooltip =  false;
    };

    "memory" = {
      on-click = "alacritty -e btop";
      format =" {}%";
    };

    "battery" = {
      "interval" = 15;
      "states" = {
        "warning" = 30;
        "critical" = 15;
      };
      format = "{icon}  {capacity}%";
      format-icons = ["" "" "" "" ""];
    };

    "pulseaudio" = {
      format = "{icon} {volume}%";
      format-bluetooth = "{icon} {volume}%";
      format-muted = "";
      format-icons = {
        default = ["" "" "󰕾"];
      };
      on-click = "pavucontrol";
    };
    
    network = {
      format-wifi = "󰤨 ";
        format-ethernet = "󰤨 {bandwidthTotalBytes}";
        format-alt = "󰤨 {essid} {signalStrength}%";
        format-disconnected = "󰤭";
        tooltip-format = "{ipaddr}/{ifname} via {gwaddr} ({signalStrength}%)";
      };

    "clock" = {
        format = "{:%H:%M}";
        format-alt = "{:%b %d, %Y}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };
     

};



}
