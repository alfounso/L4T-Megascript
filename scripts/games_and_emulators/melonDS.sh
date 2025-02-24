#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  sleep 3
  exit 1
}

clear -x
echo "MelonDS script successfully started!"
echo "Credits: https://github.com/Arisotura/melonDS"
sleep 3

echo "Running updates..."
sleep 1

case "$__os_codename" in
bionic)
  echo "          -------UBUNTU 18.04 DETECTED-------"
  echo
  echo "theofficialgman has done his PPA Qt5 wizardry"
  echo "enjoy MelonDS on Ubuntu Bionic, Focal, Hirsute, and beyond"

  if ! [[ "$dpkg_architecture" =~ ^("arm64"|"armhf")$ ]]; then
    warning "You are not running an ARMhf/ARM64 architecture, your system is not supported and this may not work"
    ppa_name="beineri/opt-qt-5.15.2-bionic"
  else
    ppa_name="theofficialgman/opt-qt-5.15.2-bionic-arm"
  fi
  ppa_installer
  ppa_name="theofficialgman/melonds-depends" && ppa_installer
  ppa_name="theofficialgman/cmake-bionic" && ppa_installer

  echo "Adding Ubuntu Toolchain Test PPA to install GCC 11..."
  ppa_name="ubuntu-toolchain-r/test" && ppa_installer

  # sudo apt install cmake gcc-11 g++-11 qt5123d qt512base qt512canvas3d qt512declarative qt512gamepad qt512graphicaleffects qt512imageformats qt512multimedia qt512xmlpatterns -y || error "Could not install dependencies"
  sudo apt install -y cmake gcc-11 g++-11 qt515base qt515multimedia qt515gamepad || error "Could not install dependencies"
  ;;
*)
  package_available qt5-default
  if [[ $? == "0" ]]; then
    sudo apt install -y qt5-default qtmultimedia5-dev || error "Failed to install dependencies"
  else
    sudo apt install -y qtbase5-dev qtchooser qtmultimedia5-dev || error "Failed to install dependencies"
  fi
esac

echo "Installing dependencies..."
sleep 1
sudo apt install cmake extra-cmake-modules libcurl4-openssl-dev libpcap0.8-dev libsdl2-dev libslirp-dev libarchive-dev libepoxy-dev libzstd-dev libwayland-dev -y || error "Could not install dependencies"

echo "Building MelonDS..."
sleep 1
cd ~
git clone https://github.com/Arisotura/melonDS.git
cd melonDS
git pull || error "Could Not Pull Latest MelonDS Source Code, verify your ~/melonDS directory hasn't been modified. You can delete the ~/melonDS folder to attempt to fix this error."
mkdir -p build
cd build
rm -rf CMakeCache.txt
case "$__os_codename" in
bionic)
  cmake .. -DCMAKE_CXX_FLAGS=-mcpu=native -DCMAKE_C_FLAGS=-mcpu=native -DCMAKE_PREFIX_PATH=/opt/qt515 -DCMAKE_BUILD_WITH_INSTALL_RPATH=FALSE -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DCMAKE_C_COMPILER=gcc-11 -DCMAKE_CXX_COMPILER=g++-11
  ;;
*)
  cmake .. -DCMAKE_CXX_FLAGS=-mcpu=native -DCMAKE_C_FLAGS=-mcpu=native
  ;;
esac
make -j$(nproc) || error "Compilation failed"
sudo make install || error "Make install failed"

##echo "Removing build files..."
##sleep 1
##cd ~
##sudo rm -rf melonDS

echo "Done!"
echo "Sending you back to the main menu..."
sleep 5
