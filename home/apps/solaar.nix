{ inputs, config, pkgs, lib, ... }:


let
  app = "solaar";
in {
  home = {
    packages = [
      pkgs.solaar
    ];
    file = {
      "${app}"= {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink "${inputs.self}/dotfiles/${app}";
        target = "${config.xdg.configHome}/${app}";
        recursive = true;
      };
    };

  };
}