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
  linkedDotfilesPath = "${config.home.homeDirectory}/.dotfiles";
in {
  lib.meta = {
    # Helper function for creating mutable dotfiles that link back to this repo
    mkDotfilesSymLink = path: config.lib.file.mkOutOfStoreSymlink
      ("${linkedDotfilesPath}/" + path);
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
    packages = with pkgs; [
      gcc
      discord                                                                          
      tdrop                                                                            
      synology-drive-client                                                            
      moonlight-qt                                                                     
      easyeffects                                                                      
      bitwarden                                                                        
      vscode
      claude-code
      code-cursor
    ];

    file = {
      dotfiles = {
        source = config.lib.file.mkOutOfStoreSymlink dotfilesPath;
        target = linkedDotfilesPath;
      };
    };
  };

  

}
