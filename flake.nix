{
  description = "A caelestia-dots home-manager module.";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-dots = {
      url = "github:caelestia-dots/caelestia";
      flake = false;
    };
  };
  outputs = inputs: {
    homeManagerModules.default = import ./caelestia.nix inputs;
  };
}
