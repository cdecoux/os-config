{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Caleb DeCoux";
        email = "cdecoux@protonmail.com";
      };
      core = {
        sshCommand = "/run/current-system/sw/bin/ssh -i /vault/homelab/secrets/github_key";
      };
      init.defaultBranch = "main";
      url = {
        "ssh://git@github.com/" = {
          insteadOf = [
            "https://github.com/"
          ];
        };
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/vault/homelab/secrets/github_key";
      };
    };
  };
}
