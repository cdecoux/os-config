# ROCm configuration for RX 560 (Polaris/GCN 4.0)
# Note: RX 560 requires ROCm 5.7.x or earlier as Polaris support was deprecated in ROCm 6.0+
{pkgs, ...}: {
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
    extraPackages = with pkgs; [
      # AMD ROCm OpenCL runtime
      rocmPackages.clr.icd
      rocmPackages.clr
      rocmPackages.rocm-runtime
      rocmPackages.rocminfo
      rocmPackages.rocm-smi
    ];
  };

  # System packages for ROCm
  environment.systemPackages = with pkgs; [
    # ROCm tools
    rocmPackages.rocminfo
    rocmPackages.rocm-smi

    # Additional GPU tools
    radeontop
    clinfo
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
    "L+ /opt/rocm - - - - ${pkgs.rocmPackages.rocm-runtime}"
  ];
}
