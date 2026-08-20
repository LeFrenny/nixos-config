{ pkgs, inputs }:
let
  dev    = import ./dev.nix    { inherit pkgs; };
  gaming = import ./gaming.nix { inherit pkgs; };
  rice   = import ./rice.nix   { inherit pkgs; };
  apps   = import ./apps.nix   { inherit pkgs inputs; };
in
  dev ++ gaming ++ rice ++ apps
