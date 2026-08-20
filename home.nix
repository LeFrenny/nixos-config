{ config, pkgs, inputs, ... }:
{
  home.username = "frenny";
  home.homeDirectory = "/home/frenny";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [

    # Neovim config dependencies (benbrastmckie/nvim fork)
    nodejs_22
    python3
    uv
    ripgrep
    fd
    texliveMedium
    zathura
    tree-sitter
    gcc
    gnumake
  ];
}
