{ inputs, config, pkgs, lib, ... }:

{


  home = {
    packages = [
      pkgs.kitty
    ];
    file = {
      kitty = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink "${inputs.self}/dotfiles/kitty";
        target = "${config.xdg.configHome}/kitty";
        recursive = true;
      };
    };

  };
}