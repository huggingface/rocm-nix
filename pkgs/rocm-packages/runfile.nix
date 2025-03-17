{
  fetchurl,
}:

let
  version = "6.3.3";
in
fetchurl {
  name = "rocm-bundle";
  url = "https://repo.radeon.com/rocm/installer/rocm-runfile-installer/rocm-rel-${version}/ubuntu/22.04/rocm-installer_1.0.1.60303-9~22.04.run";

  # Make the extracted runfile a fixed-output derivation. This avoids
  # unpacking the runfile during every build.
  recursiveHash = true;
  downloadToTemp = true;
  hash = "sha256-74Ms/3cfwHGD4mM4XEG+FCHqlKI0qbd73JKbLD7MqkY=";

  postFetch = ''
    SETUP_NOCHECK=1 sh "$downloadedFile" --noexec --target $out
  '';

  passthru = {
    version = version;
  };
}
