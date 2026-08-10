#!/usr/bin/env bash
set -euo pipefail

#
# Burp Suite
#
# This file is sourced by sandbox.sh.
#
# It takes the Burp Suite bwrap launcher visible inside the outer sandbox,
# creates a modified copy with its own user namespace, and places that
# modified launcher first in PATH.
#
# Therefore:
#
#     burpsuite
#
# directly executes the modified Burp launcher.
#

BURP_ORIGINAL="$(readlink -f "$(command -v burpsuite)")"

if [ ! -x "$BURP_ORIGINAL" ]; then
    echo "ERROR: Could not locate BurpSuite launcher" >&2
    exit 1
fi

# The CTF directory is bind-mounted into the outer sandbox, so the generated
# launcher remains available after the outer bwrap starts.
BURP_DIR="$HOST_PERSIST_DIR/burpsuite-launcher"
BURP_MODIFIED="$BURP_DIR/burpsuite"

mkdir -p "$BURP_DIR"

# BURP_DIR=$HOST_HOME
# BURP_MODIFIED="$BURP_DIR/burpsuite"
#
#
# Copy the original Burp bwrap launcher while inserting the additional
# bwrap arguments immediately AFTER the bwrap executable.
#
# Result:
#
#   cmd=(
#     /nix/store/.../bubblewrap/bin/bwrap
#     --unshare-user
#     --uid 0
#     --gid 0
#     ...
#   )
#
awk '
    /^cmd=\(/ {
        print
        getline
        print
        print "  --unshare-user"
        print "  --uid 0"
        print "  --gid 0"
        next
    }
    /container-init/ {
        # Force our real (persisted) $HOME through, overriding the
        # FHS rootfs stub /home that shadows it earlier in the array.
        print "  --bind \"$HOME\" \"$HOME\""
        print
        next
    }
    { print }
' "$BURP_ORIGINAL" > "$BURP_MODIFIED"

chmod +x "$BURP_MODIFIED"

#
# Put the directory containing our modified `burpsuite` first in PATH.
#
# Since this is added to BWRAP_ARGS, the modified launcher is what the user
# gets when they simply type:
#
#     burpsuite
#
BWRAP_ARGS+=(
    --setenv PATH "$BURP_DIR:$PATH"
)

