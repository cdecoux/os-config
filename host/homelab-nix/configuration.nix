# configuration.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "homelab-nix"; # Define your hostname.
  nix.settings.trusted-users = ["admin"];
  users.groups.admin = {};
  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = ["wheel" "docker"];
      group = "admin";
      openssh = {
        authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9NxiO2YcDOrIQqFBFyPK06lQAmd/Vrr+05KBxuZ7VbV4uVvV+s7h0DV7UrJ+x8OBnBI+bsf2CHsaYbbwlD50a9S3XRmSvI0TCaJP6ir8cBoLF8VAFOkezD2e43IuQHhXB7XOxx3wu3ptbjV9qI/WCTR7Jy/yG+KxBQ1q43HjJMa2Hwg62QJbBTf7NDWUynXUuI/i8tJkFt+1/DYyjFus/BcRr38ipZjFPK+x6TTzG5DOWlAWvYUs9eq57lHt3CagZ7L7dVgrY0QJ38fNsFfUGlBr1x+9FfJUjuWM/rN9c7FS7LhQJ5zjBWiMF217Z803DUMThkbjBGKe5S02bSOVvlMCWEnVVuYUOObEOWjRIR1HUL2ng8xU6VdcgeOlMPut5BBf40Cta/nk42nyzqeFE5yfEJ607n09mt3XLiupOFzbmMHJ0sA7iOfInNuf4i4msrTcGOgUFaQgegpf4dWCGjIBw0DhX6gJEGIpkqucmnPf8KUJbX25z5hg32L8vIqs="
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.firewall.allowedTCPPorts = [22];
  environment.systemPackages = with pkgs; [
    htop
  ];

  imports = [
    ./networking.nix
    ./nfs.nix
  ];

  virtualisation.docker = {
    enable = true;
    # Customize Docker daemon settings using the daemon.settings option
    daemon.settings = {
      dns = ["1.1.1.1" "8.8.8.8"];
      log-driver = "journald";
      storage-driver = "overlay2";
    };
  };

  virtualisation.oci-containers.containers = {
    portainer = {
      image = "portainer/portainer-ce:lts";

      ports = ["8000:8000" "9443:9443"];
      volumes = [
        "portainer_data:/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };

  # Virtualization for Testing
  virtualisation.vmVariant = {
    users.users.admin.password = "admin";
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 8048; # Use 2048MiB memory.
      cores = 3;
      graphics = false;
      diskSize = 12000;
    };
  };
  system.stateVersion = "25.05";
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
