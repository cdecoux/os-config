{ config, pkgs, lib, ... }:

{
  programs.kitty = lib.mkForce {
    enable = true;
    # settings = {
    #   confirm_os_window_close = 0;
    #   dynamic_background_opacity = true;
    #   enable_audio_bell = false;
    #   mouse_hide_wait = "-1.0";
    #   window_padding_width = 10;
    #   background_opacity = "0.5";
    #   background_blur = 5;
    #   linux_display_server = "x11";

    # };
  };

  # xdg.configFile = {
  #   kitty = {
  #     source = config.lib.file.mkOutOfStoreSymlink ./files;
  #     recursive = true;
  #   };
  # };

}