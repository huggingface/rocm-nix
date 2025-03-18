{
  lib,
  callPackage,
  newScope,
}:

let
  runfileMetadata = builtins.fromJSON (builtins.readFile ./runfile-metadata.json);
  fixedPoint = final: { inherit callPackage lib runfileMetadata; };
  composed = lib.composeManyExtensions [
    # Hooks
    (import ./hooks.nix)
    # Base package set.
    (import ./components.nix)
    # Overrides (adding dependencies, etc.)
    (import ./overrides.nix)
    # Compiler toolchain.
    (callPackage ./llvm.nix { })
    # Packages that are joins of other packages.
    (callPackage ./joins.nix { })
    # Add aotriton
    (final: prev: { inherit (prev.callPackage ../aotriton { }) aotriton_0_8 aotriton_0_9; })
  ];
in
lib.makeScope newScope (lib.extends composed fixedPoint)
