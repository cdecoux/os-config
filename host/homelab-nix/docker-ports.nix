# Firewall ports for Docker services managed by home-manager
{...}: {
  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant (host network mode)
    5000 # Registry
    7777 # Terraria Server
    8080 # Service Port
    8091 # Service Port
  ];

  networking.firewall.allowedUDPPorts = [
    7777 # Terraria Server
  ];
}
