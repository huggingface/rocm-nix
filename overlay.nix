final: prev:
let
  flattenVersion = prev.lib.strings.replaceStrings [ "." ] [ "_" ];
  readPackageMetadata = path: (builtins.fromJSON (builtins.readFile path));
  versions = [
    "6.2.4"
    "6.3.4"
  ];
  newRocmPackages = final.callPackage ./pkgs/rocm-packages { };
in
builtins.listToAttrs (
  map (version: {
    name = "rocmPackages_${flattenVersion (prev.lib.versions.majorMinor version)}";
    value = newRocmPackages {
      packageMetadata = readPackageMetadata ./pkgs/rocm-packages/rocm-${version}-metadata.json;
    };
  }) versions
)
