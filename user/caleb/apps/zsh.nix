{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "python"
        "man"
      ];
      theme = "robbyrussell";
    };

  };

  home.shell = {
    enableZshIntegration = true;
  };
}