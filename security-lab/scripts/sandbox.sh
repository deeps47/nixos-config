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


BWRAP_ARGS=(
    # Basic isolation
    --die-with-parent
    --new-session
    --unshare-pid  # drop this to regain fg, bg and ctrl+z
    --unshare-ipc
    --unshare-uts
    --hostname sandbox

    # Filesystem
    --ro-bind /nix /nix
    --ro-bind /etc /etc
    --ro-bind /usr /usr

    # proc/tmp/dev
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

    # Networking
    --share-net

    # OpenGL
    --setenv __GLX_VENDOR_LIBRARY_NAME nvidia
    --setenv LIBGL_ALWAYS_INDIRECT 0
)

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
    X11_SOCKET="/tmp/.X11-unix"

    if [ -d "$X11_SOCKET" ]; then
        BWRAP_ARGS+=(
            --ro-bind "$X11_SOCKET" "$X11_SOCKET"
            --setenv DISPLAY "$DISPLAY"
        )
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

BWRAP_ARGS+=(
    --setenv LIBGL_DRIVERS_PATH "/run/opengl-driver/lib/dri"
    --setenv __GLX_VENDOR_LIBRARY_NAME "nvidia"
    --setenv GBM_BACKEND "nvidia-drm"
)

#
# Minimal bashrc
#

cat > /tmp/sandbox.bashrc <<'EOF'

PS1='\[\e[38;2;255;165;0m\](ctf)\[\e[0m\][\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]]\$ '

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
    --ro-bind /tmp/sandbox.bashrc "$HOST_HOME/.bashrc"
)

exec bwrap \
    "${BWRAP_ARGS[@]}" \
    -- \
    "$@"
