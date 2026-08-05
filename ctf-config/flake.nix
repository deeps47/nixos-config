{
  description = "Isolated environment for CTF and Gaming tools";

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

        ctf-shell = pkgs.writeShellScriptBin "ctf-shell" ''
          exec ${./scripts/ctf-shell.sh} \
            ${./ctf-aliases.sh} \
            ${./ctf-nvim-init.lua} \
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

          packages = with pkgs; [
            bashInteractive
            bash-completion
            starship

            burpsuite
            nmap
            sqlmap
            gobuster

            ghidra
            radare2
            binwalk
            file
            binutils

            firefox
            git
            tmux
            neovim
            python3

            ctf-shell
            pwn-env
            pwn-build
          ];

          shellHook = ''
            export CTF_BASH_COMPLETION="${pkgs.bash-completion}/share/bash-completion/bash_completion"
            exec ctf-shell
          '';

        };
      }
    );
}

