{ pkgs, inputs }:
with pkgs;
[
  kitty
  discord
  pavucontrol
  networkmanagerapplet
  zsh-syntax-highlighting
  zsh-autosuggestions
  starship
  thunar
  inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  libreoffice-fresh
  obsidian
  spotify

  ani-cli

  # --- art stuff ----
  gimp
  xp-pen-deco-01-v2-driver

  # ---- VM stuff ----
  virt-viewer
  spice-gtk
  virtio-win
]
