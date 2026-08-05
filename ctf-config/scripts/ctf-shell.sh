#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${IN_CTF_SANDBOX:-}" ]]; then
  alias ctf-browser='firefox -P ctf-profile'
  alias pwn='pwn-env'
  exec bash -i
fi

USER_ID="$(id -u)"
FIREJAIL_BIN="/run/wrappers/bin/firejail"

if [ ! -x "$FIREJAIL_BIN" ]; then
  echo "firejail wrapper not found; enable programs.firejail.enable = true"
  exit 1
fi

mkdir -p "$HOME/ctf/.config/nvim" \
         "$HOME/ctf/.mozilla" \
         "$HOME/ctf/.java" \
         "$HOME/ctf/workspace"

cp "$1" "$HOME/ctf/.bash_aliases"
cp "$2" "$HOME/ctf/.config/nvim/init.lua"

chmod 700 "$HOME/ctf/.bash_aliases"
chmod 700 "$HOME/ctf/.config/nvim/init.lua"

if [ ! -f "$HOME/ctf/.inputrc" ]; then
  cat > "$HOME/ctf/.inputrc" <<'INPUTRC'
set disable-completion off
set show-all-if-ambiguous on
set completion-ignore-case on
TAB: complete
INPUTRC
fi

if [ ! -f "$HOME/ctf/.config/starship.toml" ]; then
  cat > "$HOME/ctf/.config/starship.toml" <<'STARSHIP'
format = """
[\\(ctf\\)](bold yellow)[\\[]($style)$username@$hostname:$directory[\\]]($style)$character
"""

[username]
show_always = true
style_user = "bold green"
format = "[$user]($style)"

[hostname]
ssh_only = false
style = "bold blue"
format = "[$hostname]($style)"

[directory]
style = "bold cyan"
format = "[$path]($style)"

[character]
success_symbol = "\\$ "
error_symbol = "\\$ "
STARSHIP
fi

if [ ! -f "$HOME/ctf/.bashrc" ]; then
  cat > "$HOME/ctf/.bashrc" <<'BASHRC'
[[ -r "$CTF_BASH_COMPLETION" ]] && source "$CTF_BASH_COMPLETION"
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

export TERM="${TERM:-xterm-256color}"

if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='(ctf) \u@\h:\w\$ '
fi
BASHRC
fi

FHS_ENV="$3"
shift

exec "$FIREJAIL_BIN" \
  --noprofile \
  --private="$HOME/ctf" \
  --private-etc=nix,static,resolv.conf,ssl,passwd,group,fonts \
  --nonewprivs \
  --env=IN_CTF_SANDBOX=1 \
  --env=DISPLAY="$DISPLAY" \
  --env=WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
  --env=_JAVA_AWT_WM_NONREPARENTING=1 \
  --env=INPUTRC="$HOME/.inputrc" \
  "$FHS_ENV"
