# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository using Nix flakes to manage multiple system configurations and home-manager setups. The repository manages two distinct NixOS hosts (`fw-nixos` and `homelab-nix`) and their associated user configurations.

## Repository Structure

- `flake.nix`: Main entry point defining all system configurations and home-manager configurations
- `host/`: System-level NixOS configurations, one directory per host
  - `fw-nixos/`: Desktop/workstation configuration
  - `homelab-nix/`: Homelab server configuration with Docker containers, NFS mounts, and remote deployment
- `user/`: Home-manager user configurations
  - `caleb/`: Desktop user configuration with GUI applications
  - `homelab/`: Server admin user configuration with Docker Compose services and secrets management

## Build and Deployment Commands

### Building and Switching Configurations

For the homelab server (remote deployment):
```bash
# Deploy to homelab server using Task (preferred)
task deploy:homelab-nix:admin@192.168.0.145

# Manual deployment
nixos-rebuild switch --flake .#homelab-nix --target-host admin@192.168.0.145 --use-remote-sudo
```

For home-manager (desktop user):
```bash
home-manager switch --flake .#caleb@fw-nixos
```

For local NixOS systems:
```bash
sudo nixos-rebuild switch --flake .#fw-nixos
```

### Installation and VM Testing

Install NixOS remotely using nixos-anywhere:
```bash
# Using Task (preferred)
task install:homelab-nix:root@TARGET_IP

# Manual
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./host/homelab-nix/hardware-configuration.nix --flake .#homelab-nix --target-host TARGET_HOST
```

Build and run a VM for testing:
```bash
task vm
# This builds a VM with port forwarding: SSH (2222), HTTP (8000), HTTPS (9443)
```

### Formatting

Format all Nix files using alejandra:
```bash
nix fmt
```

## Architecture

### Flake Structure

The flake defines:
- **nixosConfigurations**: Two NixOS system configurations
  - `fw-nixos`: Standalone desktop system
  - `homelab-nix`: Server with disko for disk partitioning, sops-nix for secrets, and integrated home-manager
- **homeConfigurations**: Standalone home-manager configuration for `caleb@fw-nixos`

### Key Dependencies

- `nixpkgs`: NixOS 25.11 release branch
- `home-manager`: User environment management (release-25.11)
- `alejandra`: Nix code formatter
- `neovim-nix`: Custom neovim configuration (github:cdecoux/neovim-nix)
- `sops-nix`: Secrets management using age encryption
- `disko`: Declarative disk partitioning (used by homelab-nix)

### Homelab Server Architecture

The homelab server (`homelab-nix`) has a unique architecture:

1. **Disk Management**: Uses disko to declaratively partition disks with GPT layout (boot, ESP, LVM root)
2. **NFS Mounts**: Mounts remote NFS shares from a "vault" server for persistent storage:
   - `/vault/homelab`: Server configuration and Docker volumes
   - `/vault/media`: Media files for Jellyfin
3. **Docker Containers**: Managed via systemd user service that runs docker-compose
   - Configuration: `user/homelab/containers/docker-compose.yml`
   - Services include: Cloudflare DDNS, Cloudflare tunnels, Deluge, Jellyfin, Home Assistant
   - Auto-reloads when docker-compose.yml changes (via systemd path unit)
4. **Secrets**: Environment variables for containers stored in encrypted `user/homelab/secrets/docker.env`, decrypted via sops-nix
5. **Home-Manager Integration**: Configured directly in the NixOS configuration (not standalone)

### Desktop User Architecture

The `caleb` user configuration:

1. **Dotfiles Management**: Uses out-of-store symlinks to keep dotfiles mutable
   - Dotfiles source: `~/os-config/user/caleb/.dotfiles`
   - Linked to: `~/.dotfiles`
2. **Application Modules**: Modular app configurations in `user/caleb/apps/` (zsh, kitty, solaar)
3. **Custom Helper**: `config.lib.meta.mkDotfilesSymLink` for creating mutable dotfile symlinks

## Important Notes

### Remote Deployment

The homelab server is designed to be deployed remotely. All changes should be tested locally in a VM before deploying to the actual server. The server uses NFS for persistent storage, so Docker volumes and application data persist across rebuilds.

### Secrets Management

- SOPS age keys are required for decrypting secrets
- Age public keys defined in `.sops.yaml`
- Homelab secrets keyfile location: `/vault/homelab/.config/sops/age/keys.txt`
- To edit encrypted files: `sops user/homelab/secrets/docker.env`

### Docker Container Management

The homelab Docker containers are managed via a systemd user service that:
- Automatically starts containers on boot
- Watches the docker-compose.yml file for changes
- Reloads containers when the compose file is modified
- Uses environment variables from sops-encrypted secrets

Access containers via Portainer at port 9443 or through docker CLI on the homelab server.

### VM Testing Configuration

The homelab configuration includes a `virtualisation.vmVariant` section that:
- Enables password authentication (disabled in production)
- Sets test credentials (admin/admin)
- Configures VM resources (8GB RAM, 3 cores, 12GB disk)
- Disables graphics for headless testing

### Task Runner

This repository uses go-task (Taskfile.yml) as the preferred task runner. Tasks support pattern matching:
- `task deploy:CONFIG_NAME:TARGET_HOST` - Deploy a configuration
- `task install:CONFIG_NAME:TARGET_HOST` - Install NixOS remotely
