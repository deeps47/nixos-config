{
  description = "Generic Bubblewrap Desktop Sandbox + FHS pwn shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];

      makeOutputs = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          sandbox = pkgs.stdenvNoCC.mkDerivation {
            pname = "sandbox";
            version = "0.1.0";

            src = ./.;

            installPhase = ''
              mkdir -p $out/bin

              cp scripts/sandbox.sh $out/bin/sandbox
              cp scripts/burpsuite-sandbox.sh $out/bin/burpsuite-sandbox.sh

              chmod +x $out/bin/sandbox
              chmod +x $out/bin/burpsuite-sandbox.sh
            '';
          };

          # -----------------------------------------------------------------
          # Standalone FHS environment for pwn work (gdb, pwntools, dynamic
          # linking against a standard /lib64/ld-linux, etc).
          #
          # Deliberately NOT wired into `sandbox` / the GPU bwrap script.
          # buildFHSEnv builds its own bwrap-based root remapping /usr/lib,
          # the dynamic linker, etc, which stomps on the manual
          # /run/opengl-driver + GLVND vendor-JSON bindings sandbox.sh sets
          # up for Firefox. Keeping them as two separate, non-nested
          # sandboxes avoids that collision entirely.
          # -----------------------------------------------------------------
          pwnFHS = pkgs.buildFHSEnv {
            name = "pwn-shell";
            chdirToPwd = false;

            targetPkgs = pkgs: with pkgs; [
              gcc
              gnumake
              gdb
              #              pwndbg
              python3
              python3Packages.pwntools
              python3Packages.ropper
              patchelf
              binutils
              elfutils
              file
              socat
              netcat-openbsd
              strace
              ltrace
              glibc
              glibc.static
              zlib
              ncurses
              readline
              which
              coreutils
              gnused
              gnugrep
            ];

            # Pulls in 32-bit (i686) copies of these so statically/dynamically
            # linked 32-bit CTF binaries link correctly. Most pwn challenges
            # ship i386 binaries, so this matters.
            multiPkgs = pkgs: with pkgs; [
              zlib
              glibc
              ncurses
              readline
            ];
            extraPreBwrapCmds = ''
                mkdir -p "$HOME/ctf"

              SANDBOX_BASHRC="$(mktemp)"
              cat > "$SANDBOX_BASHRC" <<'EOF'
              export TERM=xterm-256color

              PS1='\[\e[38;5;208m\](pwn)\[\e[0m\][\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]]\$ '

              set -o emacs
              bind 'set enable-bracketed-paste on'

              alias ls='ls --color=auto'
              alias ll='ls -lah --color=auto'
              alias grep='grep --color=auto'

              export HISTSIZE=10000
              export HISTFILESIZE=20000
              BASHRC
            '';

            extraBwrapArgs = [
              "--tmpfs"
              "$HOME"

              "--bind"
              "$HOME/ctf"
              "$HOME/ctf"

              "--chdir"
              "$HOME/ctf"

              "--ro-bind"
              "$SANDBOX_BASHRC"
              "$HOME/.bashrc"
            ];
            runScript = "bash -i";
          };

        in
        {
          packages = {
            sandbox = sandbox;
            pwn-shell = pwnFHS;
          };

          apps = {
            sandbox = {
              type = "app";
              program = "${sandbox}/bin/sandbox";
            };
          };

          devShells = {
            # Unchanged: GUI / GPU-accelerated CTF sandbox (Firefox, Ghidra,
            # Burp, etc). Auto-drops you into the bwrap sandbox on entry,
            # exactly as before.
            default =
              let
                sandboxScript = "${sandbox}/bin/sandbox";
              in
              pkgs.mkShell {
                packages = with pkgs; [
                  bashInteractive
                  bubblewrap
                  mesa-demos
                  vulkan-tools
                  wayland-utils
                  firefox
                  ghidra
                  burpsuite
                  slirp4netns
                  openvpn
                  libcap
                  pstree
                  vim
                  iproute2
                  libuuid
                  busybox
                  strace
                ];

                shellHook = ''
                  mkdir -p "$HOME/ctf"
                  cd "$HOME/ctf"

                  if [ -z "$IN_BWRAP_SHELL" ]; then
                    export IN_BWRAP_SHELL=1
                    exec ${sandboxScript} ${pkgs.bashInteractive}/bin/bash \
                      --rcfile ~/.bashrc -i
                  fi
                '';
              };
            # New: plain FHS shell for pwn work. Run this in a separate
            # terminal (a different Hyprland workspace/pane) alongside
            # `nix develop` (default). No bwrap nesting, no GPU env vars,
            # so it can't interfere with the GUI sandbox at all.
            #
            # Usage:
            #   nix develop .#pwn
            #   ./chall               # runs against a real FHS ld.so layout
            #   gdb ./chall
            #   python3 exploit.py
            pwn = pwnFHS.env;
          };
        };

    in
    {

      devShells =
        nixpkgs.lib.genAttrs systems
          (system: (makeOutputs system).devShells);
    };
}
