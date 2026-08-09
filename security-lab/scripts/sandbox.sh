#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "usage: sandbox <command> [args...]"
    exit 1
fi

USER_ID="$(id -u)"

XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER_ID}"

if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    echo "ERROR: XDG_RUNTIME_DIR not found: $XDG_RUNTIME_DIR"
    exit 1
fi

HOST_HOME="$HOME"
HOST_CTF_DIR="$HOST_HOME/ctf"

# Ensure the shared workspace exists.
mkdir -p "$HOST_CTF_DIR"

# Dedicated, sandbox-only persistence for GUI app config/state. Deliberately
# NOT the same paths as any real host install of these apps - this is its
# own directory tree that only the sandbox ever reads/writes, so a real
# Firefox/BurpSuite on the host (if you have one) is never touched or
# exposed, and the sandbox never sees real host browser/tool data either.
HOST_PERSIST_DIR="$HOST_HOME/.ctf-sandbox-persist"
mkdir -p \
    "$HOST_PERSIST_DIR/firefox" \
    "$HOST_PERSIST_DIR/burpsuite" \
    "$HOST_PERSIST_DIR/java-userprefs" \
    "$HOST_PERSIST_DIR/config"
chmod 700 "$HOST_PERSIST_DIR"

BWRAP_ARGS=(
    # Basic isolation
    --die-with-parent
#    --new-session  # needed for ctrl+c
    --unshare-pid
    --unshare-ipc
    --unshare-uts
   --unshare-cgroup
    --hostname sandbox

    # Filesystem
    --ro-bind /nix /nix
    --tmpfs /etc
    --ro-bind /usr /usr
    --dir /root # for ghidra

    # proc/tmp/dev - minimal synthetic /dev (null,zero,full,random,urandom,
    # tty) instead of exposing the entire host /dev tree. GPU device nodes
    # are added explicitly below.
    --proc /proc
    --tmpfs /tmp
    --dev /dev
    --dev-bind /dev/pts /dev/pts

    # Fresh home
    --tmpfs "$HOST_HOME"

    # Shared persistent CTF workspace
    --bind "$HOST_CTF_DIR" "$HOST_HOME/ctf"

    # Persistent GUI app config/state (Firefox profile, Burp settings)
    --bind "$HOST_PERSIST_DIR/firefox" "$HOST_HOME/.mozilla"
    --bind "$HOST_PERSIST_DIR/burpsuite" "$HOST_HOME/.BurpSuite"
--bind "$HOST_PERSIST_DIR/burpsuite" /root/.BurpSuite
    --bind "$HOST_PERSIST_DIR/java-userprefs" "$HOST_HOME/.java/.userPrefs"
    --bind "$HOST_PERSIST_DIR/config" "$HOST_HOME/.config"

    # Start here
    --chdir "$HOST_HOME/ctf"

    # Identity
    --setenv HOME "$HOST_HOME"
    --setenv USER "$USER"
    --setenv LOGNAME "$USER"

    # Locale
    --setenv LANG "${LANG:-C.UTF-8}"
    --setenv LC_ALL "${LC_ALL:-C.UTF-8}"

    # Shell
    --setenv PATH "$PATH"
    --setenv TERM "${TERM:-xterm-256color}"
    --setenv TMPDIR /tmp

# Rootless user namespace so we can hold CAP_NET_ADMIN
# without having host-level CAP_NET_ADMIN.
   --unshare-user
   --uid 0
   --gid 0
--cap-add CAP_NET_ADMIN
#--cap-add CAP_SYS_ADMIN
--cap-add CAP_SETUID
--cap-add CAP_SETGID
--cap-add CAP_SETFCAP

   # Isolated network namespace
    --unshare-net

    # OpenGL
    --setenv __GLX_VENDOR_LIBRARY_NAME nvidia
    --setenv LIBGL_ALWAYS_INDIRECT 0
)

#
# Curated /etc files, read-only, on top of the fresh tmpfs /etc above.
# Wholesale-binding host /etc broke the writable /etc/hosts override on
# NixOS (its /etc is a managed symlink tree bwrap couldn't punch a bind
# through), and it was exposing more of the host than needed anyway.
# resolv.conf and hosts are handled separately below since they need to
# be writable, not read-only.
#

for etc_path in \
    nsswitch.conf \
    localtime \
    machine-id \
    os-release \
    ssl \
    static \
    nix \
    fonts \
    passwd \
    group
do
    if [ -e "/etc/$etc_path" ]; then
        BWRAP_ARGS+=(
            --ro-bind "/etc/$etc_path" "/etc/$etc_path"
        )
    fi
done


#
# NVIDIA EGL external-platform configuration
#
# NixOS keeps NVIDIA's EGL platform definitions under /etc/static/egl.
# Our synthetic /etc would otherwise hide them, causing NVIDIA EGL to
# work for surfaceless/device platforms but fail to integrate with
# Wayland/X11, resulting in Mesa llvmpipe.
#

if [ -d /etc/static/egl ]; then
    BWRAP_ARGS+=(
        --ro-bind /etc/static/egl /etc/egl
    )
fi

#
# Wayland
#

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    WAYLAND_SOCKET="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"

    if [ -S "$WAYLAND_SOCKET" ]; then
        BWRAP_ARGS+=(
            --ro-bind "$WAYLAND_SOCKET" "$WAYLAND_SOCKET"
            --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
            --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
        )
    else
        echo "warning: Wayland socket missing: $WAYLAND_SOCKET"
    fi
fi

#
# X11 fallback
#

if [ -n "${DISPLAY:-}" ]; then
    # Extract the display number from formats like ":0", ":1.0", "unix:1"
    display_nr="${DISPLAY#*:}"
    display_nr="${display_nr%%.*}"
    x11_socket="/tmp/.X11-unix/X${display_nr}"

    if [ -S "$x11_socket" ]; then
        BWRAP_ARGS+=(
            --ro-bind "$x11_socket" "$x11_socket"
            --setenv DISPLAY "$DISPLAY"
        )
    else
        echo "warning: X11 socket missing: $x11_socket"
    fi
fi

#
# PipeWire
#

for socket in "$XDG_RUNTIME_DIR"/pipewire-*; do
    if [ -S "$socket" ]; then
        BWRAP_ARGS+=(
            --ro-bind "$socket" "$socket"
        )
    fi
done

#
# GPU
#

if [ -d /run/opengl-driver ]; then
    BWRAP_ARGS+=(
        --ro-bind /run/opengl-driver /run/opengl-driver
    )
fi

if [ -d /dev/dri ]; then
    BWRAP_ARGS+=(
        --dev-bind /dev/dri /dev/dri
    )
fi

for dev in \
    /dev/nvidia0 \
    /dev/nvidiactl \
    /dev/nvidia-modeset \
    /dev/nvidia-uvm \
    /dev/nvidia-uvm-tools
do
    if [ -e "$dev" ]; then
        BWRAP_ARGS+=(
            --dev-bind "$dev" "$dev"
        )
    fi
done

#
# VPN tunnel device
#

if [ -e /dev/net/tun ]; then
    BWRAP_ARGS+=(
        --dev-bind /dev/net/tun /dev/net/tun
    )
fi

BWRAP_ARGS+=(
    --setenv LIBGL_DRIVERS_PATH "/run/opengl-driver/lib/dri"
    --setenv __GLX_VENDOR_LIBRARY_NAME "nvidia"
    --setenv GBM_BACKEND "nvidia-drm"
)

#
# Create writable /etc files inside the sandbox.
#
# /etc itself is a tmpfs, so the destination files need to be explicitly
# created rather than relying on --bind to create them.
#

RESOLV_FD="$(mktemp)"
HOSTS_FD="$(mktemp)"

cat > "$RESOLV_FD" <<'EOF'
# Default: slirp4netns's built-in DNS relay.
nameserver 10.0.2.3
EOF

cp /etc/hosts "$HOSTS_FD" 2>/dev/null || : > "$HOSTS_FD"

exec {RESOLV_FD_NUM}<"$RESOLV_FD"
exec {HOSTS_FD_NUM}<"$HOSTS_FD"
rm -f "$RESOLV_FD" "$HOSTS_FD"

BWRAP_ARGS+=(
    --file "$RESOLV_FD_NUM" /etc/resolv.conf
    --file "$HOSTS_FD_NUM" /etc/hosts
)

#
# Minimal bashrc
#

SANDBOX_BASHRC="$(mktemp)"
cat > "$SANDBOX_BASHRC" <<'EOF'
export TERM="${TERM:-xterm-256color}"

PS1='\[\e[1;35m\](ctf)\[\e[0m\]\[\e[1;32m\][\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]]\$ '

set -o emacs
bind 'set enable-bracketed-paste on'

if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
fi

alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'

export HISTSIZE=10000
export HISTFILESIZE=20000
EOF

BWRAP_ARGS+=(
   --ro-bind "$SANDBOX_BASHRC" "$HOST_HOME/.bashrc"
   )

#
# Burp Suite
#
# Keep all Burp-specific setup in its own script.
#

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Source it so it can modify BWRAP_ARGS.
source "$SCRIPT_DIR/burpsuite-sandbox.sh"

#
# Run - bwrap is backgrounded (not exec'd directly) so we can hand its PID
# to slirp4netns, which attaches unprivileged userspace NAT to bwrap's
# freshly-created (and otherwise unreachable) network namespace. exec
# inside bwrap doesn't change its PID, so this stays valid for the whole
# session, however long a VPN connection inside it runs.
#

set -m  # enable job control so `fg` below can hand the terminal back to bwrap

command bwrap \
    "${BWRAP_ARGS[@]}" \
    -- \
    "$@" &
BWRAP_PID=$!

# --unshare-pid may make bwrap keep an outer monitor process around to reap
# the new pid namespace, in which case $BWRAP_PID above is NOT itself inside
# the new user/net namespaces slirp4netns needs to join - a forked child is.
# Look for that child briefly; if none ever shows up, $BWRAP_PID itself was
# already the right target all along.
BWRAP_TARGET_PID="$BWRAP_PID"
for _ in $(seq 1 50); do
    CHILD="$(cat "/proc/$BWRAP_PID/task/$BWRAP_PID/children" 2>/dev/null | awk '{print $1}')"
    if [ -n "$CHILD" ]; then
        BWRAP_TARGET_PID="$CHILD"
        break
    fi
    sleep 0.05
done

command slirp4netns \
    --configure \
    --mtu=65520 \
    --disable-host-loopback \
    --netns-type=path \
    --userns-path="/proc/$BWRAP_TARGET_PID/ns/user" \
    "/proc/$BWRAP_TARGET_PID/ns/net" \
    tap0 &
SLIRP_PID=$!


cleanup() {
    kill "$SLIRP_PID" 2>/dev/null || true
    #rm -f "$RESOLV_FD" "$HOSTS_FD"
    rm -f "$SANDBOX_BASHRC"
}

trap cleanup EXIT

# `wait` alone does not restore terminal foreground ownership - `fg` does
# (it's the job-control builtin that calls tcsetpgrp under the hood), which
# is what actually lets you type into the sandboxed shell.
fg %1
EXIT_CODE=$?

exit "$EXIT_CODE"
