{
  description = "Isolated environment for CTF";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        fhs = pkgs.buildFHSEnv {
          name = "ctf-fhs";

          targetPkgs = pkgs: with pkgs; [
            gcc
            glibc
            gdb
            patchelf
            python3
            file
            binutils
            ltrace
            strace
          ];

          multiPkgs = pkgs: with pkgs; [
            ghidra
            burpsuite
            firefox
            neovim
            git
            tmux
            radare2
            binwalk
            nmap
            sqlmap
            gobuster
            starship
          ];

          runScript = "bash";
        };

        ctf-shell = pkgs.writeShellScriptBin "ctf-shell" ''
          exec ${./scripts/ctf-shell.sh} \
            ${./ctf-aliases.sh} \
            ${./ctf-nvim-init.lua} \
            ${fhs}/bin/ctf-fhs \
            "$@"
        '';

        pwn-env = pkgs.writeShellScriptBin "pwn-env" ''
          exec ${./pwn-container/enter-pwn-env.sh} "$@"
        '';

        pwn-build = pkgs.writeShellScriptBin "pwn-build" ''
          exec ${./pwn-container/build.sh} "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          name = "ctf-env";

          packages = [
            ctf-shell
            pwn-env
            pwn-build
          ];

          shellHook = ''
            export CTF_BASH_COMPLETION="${pkgs.bash-completion}/share/bash-completion/bash_completion"
            exec ctf-shell
          '';
        };
      });
}
