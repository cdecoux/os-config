{pkgs, ...}: let
  commonMountOptions = {
    type = "nfs";
    mountConfig = {
      # _netdev tells systemd this is a network device and should be unmounted early during shutdown
      # soft,timeo=10 prevents hanging if NFS server is unreachable during shutdown
      Options = "noatime,_netdev,soft,timeo=10";
    };
  };
  vaultServer = "vault";
in {
  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true; # needed for NFS

  # Add to system mounts
  systemd.mounts = [
    (commonMountOptions
      // {
        what = "${vaultServer}:/volume1/homelab";
        where = "/vault/homelab";
      })

    (commonMountOptions
      // {
        what = "${vaultServer}:/volume2/media";
        where = "/vault/media";
      })

    (commonMountOptions
      // {
        what = "${vaultServer}:/volume2/nox";
        where = "/vault/nox";
      })
  ];

  # Add to automounts
  systemd.automounts = let
    commonAutoMountOptions = {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
    };
  in [
    (commonAutoMountOptions // {where = "/vault/media";})
    (commonAutoMountOptions // {where = "/vault/homelab";})
    (commonAutoMountOptions // {where = "/vault/nox";})
  ];
}
