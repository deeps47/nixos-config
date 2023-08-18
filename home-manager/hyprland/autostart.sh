#!/usr/bin/env bash

dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &

hyprland-autoname-workspaces -c $HOME/config/home-manager/hyprland/waybar/autoname.toml &

wlr-randr --output eDP-1 --mode 1920x1080 --scale 1
