# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository using flakes and home-manager for a single-host setup (`fw-nixos`). The configuration follows a modular approach with separate system and user configurations.

## Architecture

### Core Structure
- `flake.nix`: Main entry point defining nixpkgs and home-manager inputs
- `hosts/fw-nixos/`: System-level NixOS configuration
  - `configuration.nix`: Main system configuration (GNOME, networking, users)
  - `hardware-configuration.nix`: Hardware-specific settings
- `home/`: User-level home-manager configuration
  - `home.nix`: User packages and dotfiles management
  - `packages/`: Modular package configurations (kitty, neovim)

### Key Configuration Details
- Target system: `x86_64-linux`
- NixOS version: 25.05
- Desktop environment: GNOME with GDM
- User shell: zsh with oh-my-zsh
- Home-manager integrated via NixOS modules (not standalone)

## Common Commands

### Building and Switching
```bash
# Build and switch system configuration
sudo nixos-rebuild switch --flake .#fw-nixos

# Build without switching (test configuration)
sudo nixos-rebuild build --flake .#fw-nixos

# Test configuration temporarily (reverts on reboot)
sudo nixos-rebuild test --flake .#fw-nixos
```

### Flake Management
```bash
# Update flake inputs
nix flake update

# Show flake info
nix flake show

# Check flake syntax
nix flake check
```

### Package Management
```bash
# Search for packages
nix search nixpkgs <package-name>

# Temporarily install package
nix shell nixpkgs#<package-name>
```

## Development Workflow

### Making Changes
1. Edit configuration files in appropriate directories
2. Test with `nixos-rebuild test --flake .#fw-nixos`
3. Apply permanently with `nixos-rebuild switch --flake .#fw-nixos`
4. Commit changes to git

### Adding System Packages
- Add to `environment.systemPackages` in `hosts/fw-nixos/configuration.nix`

### Adding User Packages
- Add to `home.packages` in `home/home.nix`

### Adding New Package Configurations
- Create new files in `home/packages/` directory
- Import in `home/home.nix` if needed

## Important Notes

- The system uses experimental features: `nix-command` and `flakes`
- Home-manager is integrated as a NixOS module, not standalone
- User `caleb` is the primary user with sudo access
- Unfree packages are allowed system-wide
- The configuration targets a Framework laptop (`fw-nixos` hostname)