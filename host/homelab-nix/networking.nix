{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    hostName = "homelab-nix"; # Define your hostname.
    firewall.allowedTCPPorts = [22 68 53];
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "ens3";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };

    useDHCP = true;
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
