#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  sleep 3
  exit 1
}

clear -x
echo "Citra script successfully started!"
echo "Credits: https://citra-emu.org/wiki/building-for-linux/"
sleep 3

echo "Cleaning up unneeded files from old versions, if found..."
# https://github.com/citra-emu/citra/issues/6397
sudo rm -rf /usr/local/include/Zydis/ /usr/local/include/dynarmic/ /usr/local/include/fmt/ /usr/local/include/mcl/ /usr/local/include/tsl/ /usr/local/include/xbyak/ /usr/local/lib/cmake/ /usr/local/lib/libZydis.a /usr/local/lib/libdynarmic.a /usr/local/lib/libfmt.a /usr/local/lib/libmcl.a /usr/local/lib/pkgconfig/fmt.pc /usr/local/share/cmake/tsl-robin-map/

echo "Installing dependencies..."
sleep 1

case "$__os_id" in
Raspbian | Debian | LinuxMint | Linuxmint | Ubuntu | [Nn]eon | Pop | Zorin | [eE]lementary | [jJ]ing[Oo][sS])

  case "$__os_codename" in
  bionic | focal)
    echo "Adding GCC/G++ 11 repo..."
    ppa_name="ubuntu-toolchain-r/test" && ppa_installer
    echo "Adding QT6 repo..."
    #it's not redneck if it works.
    #TODO: get https://github.com/oskirby/qt6-packaging/issues/2 resolved, or just build QT6 ourselves
    ppa_name="okirby/qt6-backports" && ppa_installer
    ppa_name="okirby/qt6-testing" && ppa_installer

    sudo apt install -y gcc-11 g++-11 || error "Could not install dependencies"
    ;;
  *)
    sudo apt install -y gcc g++ || error "Could not install dependencies"
    ;;
  esac

  sudo apt-get install git libsdl2-2.0-0 libsdl2-dev qt6-base-dev qt6-base-private-dev libqt6opengl6-dev qt6-multimedia-dev libqt6multimedia6 qt6-l10n-tools libfdk-aac-dev build-essential cmake libc++-dev libswscale-dev libavdevice* libavformat-dev libavcodec-dev libssl-dev glslang-tools -y || error "Could not install dependencies"

  ;;

Fedora)
  sudo dnf install -y cmake SDL2-devel openssl-devel qt6-qtbase-devel qt6-qtbase-private-devel qt6-qtmultimedia-devel gcc-c++ || error "Could not install dependencies!"
  ;;
*)
  echo -e "\\e[91mUnknown distro detected - this script should work, but please press Ctrl+C now and install necessary dependencies yourself following https://wiki.dolphin-emu.org/index.php?title=Building_Dolphin_on_Linux if you haven't already...\\e[39m"
  sleep 5
  ;;
esac

echo "Building Citra..."
sleep 1
cd ~
git clone --recurse-submodules -j$(nproc) https://github.com/citra-emu/citra
cd citra
git pull --recurse-submodules -j$(nproc) || error "Could Not Pull Latest Source Code"
git submodule update --init --recursive || error "Could Not Pull All Submodules"
mkdir -p build
cd build
rm -rf CMakeCache.txt
case "$__os_codename" in
bionic | focal)
  cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-mcpu=native -DCMAKE_C_FLAGS=-mcpu=native -DCMAKE_C_COMPILER=gcc-11 -DCMAKE_CXX_COMPILER=g++-11
  ;;
*)
  if grep -iE 'raspberry' <<<$model >/dev/null; then
    #   https://github.com/citra-emu/citra/issues/5921
    warning "You're running a Raspberry Pi, building without ASM since Broadcom is allergic to cryptography extensions..."
    sleep 1
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-mcpu=native -DCMAKE_C_FLAGS=-mcpu=native -DCRYPTOPP_OPT_DISABLE_ASM=1
  else
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-mcpu=native -DCMAKE_C_FLAGS=-mcpu=native
  fi
  ;;
esac

make -j$(nproc) || error "Compilation failed"
sudo make install || error "Make install failed"

echo "Done!"
echo "Sending you back to the main menu..."
sleep 5
