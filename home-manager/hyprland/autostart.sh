#!/usr/bin/env bash

dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &

wlr-randr --output eDP-1 --mode 1920x1080 --scale 1
