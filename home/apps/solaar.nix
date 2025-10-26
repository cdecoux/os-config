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
        source = config.lib.meta.mkMutableSymlink "./config/${app}";
        target = "${config.xdg.configHome}/${app}";
      };
    };

  };
}