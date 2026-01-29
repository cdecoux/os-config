# Firewall ports for Docker services managed by home-manager
{...}: {
  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant (host network mode)
  ];
}