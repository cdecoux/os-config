{config, ...}: let
  username = "admin";
  containersPath = "${config.home.homeDirectory}/containers";
  filePath = "docker-compose.homelab-services.yml";
in {
  systemd.user.services.homelab-services = {
    Install.WantedBy = ["default.target"];
    Unit = {
      Description = "homelab-services docker containers via docker-compose";
      Wants = "sops-nix.service";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      Restart = "on-failure";
      RestartSec = "30";
      WorkingDirectory = containersPath;
      EnvironmentFile = "${config.xdg.configHome}/sops-nix/secrets/docker.env";
      Environment = "COMPOSE_PROJECT_NAME=homelab-services GIT_SSH_COMMAND=/run/current-system/sw/bin/ssh";
      ExecStart = "/run/current-system/sw/bin/docker compose -f ${filePath} up --detach --build --remove-orphans";
      ExecStop = "/run/current-system/sw/bin/docker compose -f ${filePath} stop";
      ExecReload = "/run/current-system/sw/bin/docker compose -f ${filePath} up --detach --build --remove-orphans";
    };
  };

  systemd.user.paths.homelab-services = {
    Unit.Description = "Watch docker-compose.yaml for changes";
    Install.WantedBy = ["default.target"];
    Path = {
      # Watch the symlink itself for changes (when home-manager updates it)
      PathChanged = "${containersPath}/${filePath}";
      Unit = "homelab-services.service";
    };
  };
}
