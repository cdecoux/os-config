{pkgs, ...}: let
  commonMountOptions = {
    type = "nfs";
    mountConfig = {
      Options = "noatime";
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
        what = "${vaultServer}:/volume1/media";
        where = "/vault/media";
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
  ];
}
