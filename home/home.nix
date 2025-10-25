{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: 


{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.firefox.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  imports = [
    ./apps/zsh
    ./apps/neovim
    ./apps/kitty
  ];
  
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "caleb";
    homeDirectory = "/home/caleb";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";
    sessionVariables = {
      # EDITOR = "emacs";
    };
    packages = [
      pkgs.solaar
      pkgs.discord                                                                          
      pkgs.tdrop                                                                            
      pkgs.synology-drive-client                                                            
      pkgs.moonlight-qt                                                                     
      pkgs.easyeffects                                                                      
      pkgs.bitwarden                                                                        
      pkgs.vscode
      pkgs.claude-code
      pkgs.code-cursor
    ];
  };

  

}
