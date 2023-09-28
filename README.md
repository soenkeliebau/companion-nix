# Bitfocus Companion Derivation
An attempt to package [Companion](https://github.com/bitfocus/companion) as a derivation for NixOS.

## Building

`nix-build -E 'let pkgs = import <nixpkgs> { }; in pkgs.callPackage ./default.nix {}'`
