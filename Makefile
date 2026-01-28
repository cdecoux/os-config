.PHONY: vm homelab-switch


homelab-switch:
	nixos-rebuild switch --flake .#homelab-nix --target-host admin@192.168.0.145 --use-remote-sudo

vm:
	nixos-rebuild build-vm --flake .#homelab-nix
	QEMU_NET_OPTS="hostfwd=tcp::2222-:22,hostfwd=tcp::8000-:8000,hostfwd=tcp::9443-:9443" result/bin/run-nixos-vm
