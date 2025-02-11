{
  stdenv,
  wrapCCWith,
  bintools,
  glibc,
  llvm,
  rocm-device-libs,
  rsync,
}:

wrapCCWith rec {
  inherit bintools;

  cc = stdenv.mkDerivation {
    inherit (llvm) version;
    pname = "romc-llvm-clang";

    nativeBuildInputs = [ rsync ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      for path in ${llvm}/llvm ${bintools}; do
        rsync -a $path/ $out/
      done
      chmod -R u+w $out

      clang_version=`$out/bin/clang --version | grep -E -o "clang version [0-9]+" | cut -d ' ' -f3`
      ln -s $out/lib/* $out/lib/clang/$clang_version/lib
      ln -sf $out/include/* $out/lib/clang/$clang_version/include

      substituteInPlace $out/bin/rocm.cfg \
        --replace-fail "<CFGDIR>/../../.." "<CFGDIR>/.."

      runHook postInstall
    '';

    passthru = {
      isClang = true;
      isROCm = true;
    };
  };

  gccForLibs = stdenv.cc.cc;

  extraPackages = [
    bintools
    glibc
  ];

  nixSupport.cc-cflags = [
    "-resource-dir=$out/resource-root"
    "-fuse-ld=lld"
    "--rocm-device-lib-path=${rocm-device-libs}/amdgcn/bitcode"
    "-rtlib=compiler-rt"
    "-unwindlib=libunwind"
    "-Wno-unused-command-line-argument"
  ];

  extraBuildCommands = ''
    clang_version=`${cc}/bin/clang --version | grep -E -o "clang version [0-9]+" | cut -d ' ' -f3`
    mkdir -p $out/resource-root
    ln -s ${cc}/lib/clang/$clang_version/{include,lib} $out/resource-root

    echo "" > $out/nix-support/add-hardening.sh

    # The cc wrapper puts absolute paths to the libstdc++ headers here.
    # However, absolute paths put them before the ROCm wrappers. This
    # cause compilation errors in downstream dependencies because e.g.
    # libstdc++'s new operator cannot handle device code.
    echo "" > $out/nix-support/libcxx-cxxflags

    # GPU compilation uses builtin `lld`
    substituteInPlace $out/bin/{clang,clang++} \
      --replace-fail "-MM) dontLink=1 ;;" "-MM | --cuda-device-only) dontLink=1 ;;''\n--cuda-host-only | --cuda-compile-host-device) dontLink=0 ;;"
  '';
}
