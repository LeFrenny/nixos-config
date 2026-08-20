{ pkgs }:
with pkgs;
[
  # editors
  vscode
  pkgs.zed-editor
  neovim
  # terminal utils
  fastfetch
  btop
  htop
  bat
  eza
  ripgrep
  unzip
  wget
  zoxide
  lazygit
  gh
  wget
  # compilers & build
  gcc
  zeromq
  dotnet-sdk_10
  docker-compose
  # languages
  (rWrapper.override {
    packages = with rPackages; [ ggplot2 dplyr xts ];
  })
]
