{
  lib,
  stdenv,
  fetchFromGitHub,
  linuxPackages,
  kernel ? linuxPackages.kernel,
}:

# vfs_monitor.ko, the out-of-tree kernel module behind deepin-anything's file
# change notifications. Upstream ships it via DKMS; here it is built against
# the kernel it will run on (the NixOS module passes the running one).
stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-anything-module";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-anything";
    tag = finalAttrs.version;
    hash = "sha256-nj8I4hm/OyfMNq7PmX3XlRIbYSvvFGylpBHbrChqa+Q=";
  };

  # Only the module sources are needed for the out-of-tree kbuild.
  setSourceRoot = "sourceRoot=$(echo */src/kernelmod)";

  # Upstream's Makefile derives the kernel build dir from `uname -r`, which is
  # wrong inside the sandbox, and only defines `all`/`clean` (no
  # `modules_install`, which the stdenv install phase expects). Fix both.
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'kdir := /lib/modules/$(shell uname -r)/build' \
                     'kdir := $(KERNELDIR)'

    cat >> Makefile <<'EOF'

    modules_install:
    	make -C $(kdir) M=$(cwd) modules_install
    EOF
  '';

  hardeningDisable = [ "pic" ];

  makeFlags = linuxPackages.kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  installTargets = [ "modules_install" ];

  enableParallelBuilding = true;

  meta = {
    description = "Kernel module for deepin-anything file change notifications";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
