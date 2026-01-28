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
        source = config.lib.meta.mkDotfilesSymLink ".config/${app}";
        target = "${config.xdg.configHome}/${app}";
      };
    };

  };
}