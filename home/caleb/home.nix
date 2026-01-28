{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  username = "caleb";
  dotfilesPath = "${config.home.homeDirectory}/os-config/home/${username}/.dotfiles";
  linkedDotfilesPath = "${config.home.homeDirectory}/.dotfiles";
in {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  imports = [
    ./apps/zsh.nix
    ./apps/kitty.nix
    ./apps/solaar.nix
  ];

  config = {
    lib.meta = {
      # Helper function for creating mutable dotfiles that link back to this repo
      mkDotfilesSymLink = path:
        config.lib.file.mkOutOfStoreSymlink
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

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home = {
      username = "${username}";
      homeDirectory = "/home/${username}";
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      sessionVariables = {
        EDITOR = "vim";
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
        sops
      ];

      file = {
        dotfiles = {
          source = config.lib.file.mkOutOfStoreSymlink dotfilesPath;
          target = linkedDotfilesPath;
        };
      };
    };
  };
}
