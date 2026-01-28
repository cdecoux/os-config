{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "ens3";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
