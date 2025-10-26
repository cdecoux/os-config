{ config, pkgs, lib, ... }:

let
	app = "nvim";
in {

  home = {
      packages = with pkgs; [
        ripgrep
        tree-sitter
        fd
        neovim
        nodejs_24
        unzip
        cargo
      ];

      file = {
        "${app}"= {
          enable = true;
          source = config.lib.meta.mkDotfilesSymLink ".config/${app}";
          target = "${config.xdg.configHome}/${app}";
        };
        };
    };

}
