# ROCm configuration for RX 560 (Polaris/GCN 4.0)
# Note: Using ROCm 6.0 with HSA_OVERRIDE_GFX_VERSION workaround for deprecated Polaris GPU
{pkgs, ...}: let
  # Use ROCm 6.0 explicitly to match container version
  rocmPackages = pkgs.rocmPackages_6;
in {
  # Enable AMD GPU kernel modules
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["amdgpu"];

  # Kernel parameters for AMD GPU
  boot.kernelParams = [
    # Enable ROCm support for Polaris (GCN 4.0) architecture
    # The RX 560 uses gfx803 architecture
    "amdgpu.gpu_recovery=1"
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  # Hardware OpenGL configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      # AMD ROCm OpenCL runtime (ROCm 6.0)
      rocmPackages.clr.icd
      rocmPackages.clr
      rocmPackages.rocm-runtime
      rocmPackages.rocminfo
      rocmPackages.rocm-smi
    ];
  };

  # System packages for ROCm
  environment.systemPackages = [
    # ROCm 6.0 tools
    rocmPackages.rocminfo
    rocmPackages.rocm-smi

    # Additional GPU tools
    pkgs.radeontop
    pkgs.clinfo
  ];

  # Environment variables for ROCm
  environment.variables = {
    # Force ROCm to recognize Polaris (gfx803) GPUs
    # The RX 560 uses gfx803 architecture
    HSA_OVERRIDE_GFX_VERSION = "8.0.3";

    # ROCm device visibility
    ROCR_VISIBLE_DEVICES = "0";

    # HIP settings
    HIP_VISIBLE_DEVICES = "0";
  };

  # Add users who need GPU access to the render and video groups
  users.users.admin = {
    extraGroups = ["render" "video"];
  };

  # Systemd tmpfiles rules for ROCm
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm - - - - ${rocmPackages.rocm-runtime}"
  ];

  # Ensure GPU devices have proper permissions for Docker
  services.udev.extraRules = ''
    # Make AMD GPU devices accessible to render group
    KERNEL=="kfd", GROUP="render", MODE="0660"
    KERNEL=="renderD*", GROUP="render", MODE="0660"
  '';
}
