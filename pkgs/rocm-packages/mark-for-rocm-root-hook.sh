# shellcheck shell=bash

# Based on mark-for-cuda-root-hook.

(( ${hostOffset:?} == -1 && ${targetOffset:?} == 0)) || return 0

echo "Sourcing mark-for-rocm-root-hook" >&2

markForROCM_ROOT() {
    mkdir -p "${prefix:?}/nix-support"
    local markerPath="$prefix/nix-support/include-in-rocm-root"

    # Return early if the file already exists.
    [[ -f "$markerPath" ]] && return 0

    # Always create the file, even if it's empty, since setup-cuda-hook relies on its existence.
    # However, only populate it if strictDeps is not set.
    touch "$markerPath"

    # Return early if strictDeps is set.
    [[ -n "${strictDeps-}" ]] && return 0

    # Populate the file with the package name and output.
    echo "${pname:?}-${output:?}" > "$markerPath"
}

fixupOutputHooks+=(markForROCM_ROOT)
