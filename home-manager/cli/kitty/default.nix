{ pkgs, ... }: {

  programs.kitty = {
    enable = true;
    extraConfig = ''
    font_size  11
    font_family      JetBrainsMono Nerd Font Mono
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    background_opacity 0.69

    single_window_margin_width -1
    placement_strategy top-left
    window_padding_width 5

    scrollback_lines 10000
    enable_audio_bell no
    '';
  };

}
