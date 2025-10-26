{ inputs, config, pkgs, lib, ... }:

let
  app = "kitty";
in {
  home = {
    packages = [
      pkgs.kitty
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