# rocm-nix

This is an overlay that repackages [AMD ROCm](https://www.amd.com/en/products/software/rocm.html) [runfile](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/rocm-runfile-installer.html) as a set of Nix derivations. In most cases it is recommended to use ROCm as it is packaged in nixpkgs. However, for [TGI](https://github.com/huggingface/text-generation-inference) and the [kernel builder](https://github.com/huggingface/kernel-builder) we need more control over ROCm version. For this reason we package precompiled ROCm builds.
