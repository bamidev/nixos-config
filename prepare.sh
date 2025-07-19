#!/bin/sh
nix-shell -p git -p wget <<HEREDOC
if [ -f "/home/bamilab/Documents/wallpapers/grub.png" ]; then
	git update-index --assume-unchanged "/etc/nixos/img/grub-background.png"
	cp "/home/bamilab/Documents/wallpapers/grub.png" "/etc/nixos/igm/grub-background.png"
fi
HEREDOC
