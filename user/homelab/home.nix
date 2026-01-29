{
  pkgs,
  config,
  ...
}: let
  username = "admin";
  containersPath = "${config.home.homeDirectory}/containers";
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "vim";
    };
    packages = with pkgs; [
      docker-compose
    ];

    file = {
      containers = {
        source = "${./containers}";
        target = containersPath;
      };
    };
  };

  sops = {
    age = {
      keyFile = "/vault/homelab/.config/sops/age/keys.txt";
    };

    secrets = {
      "docker.env" = {
        format = "dotenv";
        sopsFile = "${./secrets/docker.env}";
        key = "";
      };
    };
  };

  systemd.user.services.homelab-docker = {
    Install.WantedBy = ["default.target"];
    Unit = {
      Description = "Homelab docker containers via docker-compose";
      Wants = "sops-nix.service";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      WorkingDirectory = containersPath;
      EnvironmentFile = "${config.xdg.configHome}/sops-nix/secrets/docker.env";
      Environment = "COMPOSE_PROJECT_NAME=homelab";
      ExecStart = "/run/current-system/sw/bin/docker compose up --detach --build";
      ExecStop = "/run/current-system/sw/bin/docker compose stop";
    };
  };

  systemd.user.paths.homelab-docker = {
    Unit.Description = "Watch docker-compose.yaml for changes";
    Install.WantedBy = ["default.target"];
    Path.PathModified = containersPath;
  };
}
