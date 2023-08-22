_: {

  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;
      scan_timeout = 3;
     
      format = "[╭╴](238)💀 $all[╰─](238)$character";

      character = {
        success_symbol = "[───󰁕](238)";
        error_symbol = "[─](238)[󰁕](red)";
        vicmd_symbol = "[](bold yellow)";
      };
      
      directory = {
        truncation_length = 4;
      };

      line_break.disabled = false;

      lua.symbol = "[](blue) ";
      python.symbol = "[](blue) ";
      nix_shell.symbol = "[](blue) ";
      rust.symbol = "[](red) ";
      package.symbol = "📦  ";

      git_branch = {
        disabled = true;
      };

      git_status = {
        disabled = true;
      };

      hostname = {
        ssh_only = true;
        format = "[$ssh_symbol](bold blue)@[$hostname](bold red) ";
        trim_at = "";
        disabled = false;
      };

      cmd_duration.disabled = true;
    };
  };
}
