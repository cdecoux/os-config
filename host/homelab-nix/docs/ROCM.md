# Docker GPU Access for RX 560 (ROCm)

This guide explains how to run Docker containers with GPU access on the homelab-nix host with an AMD RX 560.

## Required Docker Flags

To enable GPU access in your Docker containers, you need to:

1. **Mount GPU devices**:
   - `/dev/kfd` - ROCm compute device
   - `/dev/dri` - GPU render devices (all of them)

2. **Set proper permissions**:
   - Add `video` and `render` group access

3. **Pass ROCm environment variables**

## Example Docker Run Command

```bash
docker run -it \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --group-add render \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  -e HSA_OVERRIDE_GFX_VERSION=8.0.3 \
  -e ROCR_VISIBLE_DEVICES=0 \
  -e HIP_VISIBLE_DEVICES=0 \
  your-image:tag
```

## Docker Compose Example

```yaml
services:
  your-service:
    image: your-image:tag
    devices:
      - /dev/kfd
      - /dev/dri
    group_add:
      - video
      - render
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp=unconfined
    environment:
      - HSA_OVERRIDE_GFX_VERSION=8.0.3
      - ROCR_VISIBLE_DEVICES=0
      - HIP_VISIBLE_DEVICES=0
```

## Important Notes

### RX 560 (Polaris/gfx803) Compatibility

- The `HSA_OVERRIDE_GFX_VERSION=8.0.3` environment variable is **critical**
- ROCm 6.0+ deprecated Polaris support, so this forces compatibility
- Your RX 560 is gfx803 architecture (Polaris/GCN 4.0)

### CUDA vs ROCm

If you get "CUDA" errors in a ROCm environment:

1. **Some apps support both**: Many ML/AI frameworks support both NVIDIA CUDA and AMD ROCm
2. **Check for ROCm image**: Look for a ROCm-specific Docker image (e.g., `rocm/pytorch` instead of `nvidia/pytorch`)
3. **HIP compatibility**: Some CUDA apps can run on ROCm via HIP (heterogeneous-compute interface for portability)

### Container ROCm Installation

If your container doesn't have ROCm installed, you may need to:

1. Use a ROCm base image (e.g., `rocm/dev-ubuntu-22.04`)
2. Install ROCm inside the container
3. Mount `/opt/rocm` from the host: `-v /opt/rocm:/opt/rocm:ro`

### Verifying GPU Access Inside Container

```bash
# Inside the container
rocminfo                    # Check GPU detection
rocm-smi                    # Check GPU status
/opt/rocm/bin/rocminfo      # If rocminfo not in PATH
```

## Troubleshooting

### "No GPU detected" inside container

- Ensure all devices are mounted (`--device=/dev/kfd --device=/dev/dri`)
- Check group membership (`--group-add video --group-add render`)
- Verify `HSA_OVERRIDE_GFX_VERSION=8.0.3` is set

### "CUDA failed with error invalid device ordinal"

- This usually means the app expects CUDA but you have ROCm
- Look for ROCm-compatible version of the application
- Check if app supports `ROCR_VISIBLE_DEVICES` instead of `CUDA_VISIBLE_DEVICES`

### Permission denied on /dev/kfd

- Ensure udev rules are applied (reboot after configuration changes)
- Verify user is in `render` and `video` groups
- Check device permissions: `ls -la /dev/kfd /dev/dri/`

## Example Applications

### PyTorch with ROCm

```bash
docker run -it \
  --device=/dev/kfd --device=/dev/dri \
  --group-add video --group-add render \
  -e HSA_OVERRIDE_GFX_VERSION=8.0.3 \
  rocm/pytorch:latest \
  python -c "import torch; print(torch.cuda.is_available())"
```

Note: PyTorch uses "cuda" in its API even for ROCm builds.

### TensorFlow with ROCm

```bash
docker run -it \
  --device=/dev/kfd --device=/dev/dri \
  --group-add video --group-add render \
  -e HSA_OVERRIDE_GFX_VERSION=8.0.3 \
  rocm/tensorflow:latest \
  python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

## Getting Group IDs

To find the numeric group IDs for your docker-compose file:

```bash
getent group video  # Usually 44
getent group render # Usually 303 or varies
```

Then use them as:
```yaml
group_add:
  - "44"    # video
  - "303"   # render
```
