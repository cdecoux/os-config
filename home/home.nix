{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: with lib;

let
  dotfilesPath = "${config.home.homeDirectory}/os-config/home/.dotfiles";
in {
  lib.meta = {
    mkDotfilesSymLink = path: config.lib.file.mkOutOfStoreSymlink
      ("${config.home.homeDirectory}/.dotfiles/" + path);
  };

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
    ./apps/zsh.nix
    ./apps/neovim.nix
    ./apps/kitty.nix
    ./apps/solaar.nix
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

    file = {
      dotfiles = {
        source = config.lib.file.mkOutOfStoreSymlink dotfilesPath;
        target = "${config.home.homeDirectory}/.dotfiles";
      };
    };
  };

  

}
