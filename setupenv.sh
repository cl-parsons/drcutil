#!/usr/bin/env bash

source config.sh
FILENAME="$(echo $(cd $(dirname "$BASH_SOURCE") && pwd -P)/$(basename "$BASH_SOURCE"))"
RUNNINGSCRIPT="$0"
trap 'err_report $LINENO $FILENAME $RUNNINGSCRIPT; exit 1' ERR

APT_DEPENDENCIES=()

# dependencies for the script
setupenv_script()
{
  echo "Installing script dependencies"
  sudo $APT install curl
}

setupenv_OpenRTM-aist() {
if [ $OSNAME = "Darwin" ]; then
  brew install autoconf automake libtool omniorb
else
  APT_DEPENDENCIES+=(autoconf libtool-bin)
fi
}

setupenv_openhrp3() {
  if [ $OSNAME = "Darwin" ]; then
    brew install cmake eigen boost pkg-config jpeg libpng
  else
    cd $SRC_DIR/openhrp3/util
    # echo "-- Installing dependencies using script $SRC_DIR/openhrp3/util/installPackages.sh packages.list.$DIST_KIND.$DIST_VER"
    #./installPackages.sh packages.list.$DIST_KIND.$DIST_VER

    APT_DEPENDENCIES+=(openjdk-8-jdk)
    APT_DEPENDENCIES+=(openjdk-8-jre)
    APT_DEPENDENCIES+=(jython)
    APT_DEPENDENCIES+=(libreadline-java)
    APT_DEPENDENCIES+=(java-common)
    APT_DEPENDENCIES+=(build-essential)
    APT_DEPENDENCIES+=(cmake)
    APT_DEPENDENCIES+=(doxygen)
    APT_DEPENDENCIES+=(graphviz)
    APT_DEPENDENCIES+=(pkg-config)
    APT_DEPENDENCIES+=(python-yaml)
    APT_DEPENDENCIES+=(libcos4-dev)
    APT_DEPENDENCIES+=(libomnievents-dev)
    APT_DEPENDENCIES+=(libomniorb4-dev)
    APT_DEPENDENCIES+=(libomnithread4-dev)
    APT_DEPENDENCIES+=(omnievents)
    APT_DEPENDENCIES+=(omniidl)
    APT_DEPENDENCIES+=(omniidl-python)
    APT_DEPENDENCIES+=(omniorb)
    APT_DEPENDENCIES+=(omniorb-idl)
    APT_DEPENDENCIES+=(omniorb-nameserver)
    APT_DEPENDENCIES+=(python-omniorb)
    APT_DEPENDENCIES+=(python-tk)
    APT_DEPENDENCIES+=(liblapack-dev)
    APT_DEPENDENCIES+=(libatlas-base-dev)
    APT_DEPENDENCIES+=(libblas-dev)
    APT_DEPENDENCIES+=(f2c)
    APT_DEPENDENCIES+=(libf2c2)
    APT_DEPENDENCIES+=(libf2c2-dev)
    APT_DEPENDENCIES+=(libboost-dev)
    APT_DEPENDENCIES+=(libboost-filesystem-dev )
    APT_DEPENDENCIES+=(libboost-program-options-dev )
    APT_DEPENDENCIES+=(libboost-regex-dev)
    APT_DEPENDENCIES+=(libboost-thread-dev)
    APT_DEPENDENCIES+=(zlib1g-dev)
    # XXX Installing libjpeg62 causes ROS to uninstall
    # This doesn't seem to be needed
    #APT_DEPENDENCIES+=(libjpeg62-dev)
    APT_DEPENDENCIES+=(libpng-dev)
    APT_DEPENDENCIES+=(uuid-dev)
    APT_DEPENDENCIES+=(libeigen3-dev)

    echo "-- Removing openrtm-aist-dev and openrtm-aist packages (will be installed from source)"
    sudo $APT remove openrtm-aist-dev openrtm-aist # install from source
    sudo sed -i -e 's/giopMaxMsgSize = 2097152/giopMaxMsgSize = 2147483648/g' /etc/omniORB.cfg

    if [ "$BUILD_GOOGLE_TEST" = "ON" ]; then
      APT_DEPENDENCIES+=(libgtest-dev)
    fi
  fi
}

setupenv_pcl() {
  if [ $OSNAME = "Darwin" ]; then
    brew install pcl
  else
    if [ "$DIST_VER" = "14.04" ]; then
      sudo add-apt-repository -y ppa:v-launchpad-jochen-sprickerhof-de/pcl
      APT_DEPENDENCIES+=(libpcl-all)
    else
      APT_DEPENDENCIES+=(libpcl-dev libproj-dev)
    fi
  fi
}

setupenv_octomap() {
  if [ $OSNAME = "Darwin" ]; then
    brew install octomap
  else
    if ([ "$DIST_KIND" == "ubuntu" ] && [ "$DIST_VER" != "14.04" ]) || ([ "$DIST_KIND" == "debian" ] && [ "$DIST_VER" == "10" ]); then
      APT_DEPENDENCIES+=(liboctomap-dev)
    fi
  fi
}

setupenv_hrpsys-base() {
if [ $OSNAME = "Darwin" ]; then
  brew install opencv sdl boost-python
else
  APT_DEPENDENCIES+=(libxml2-dev libsdl-dev libglew-dev libopencv-dev libqhull-dev freeglut3-dev libxmu-dev python-dev libboost-python-dev)
  # XXX where is this installed from?
  # XXX mc_rtc repositories work here
  APT_DEPENDENCIES+=(openrtm-aist-python)
  echo "-- Add mc_rtc PPA (needed for openrtm-aist-python)"
  curl -1sLf 'https://dl.cloudsmith.io/public/mc-rtc/stable/setup.deb.sh' | sudo -E bash
  if [ "$DIST_KIND" = "ubuntu" ] && [ "$DIST_VER" != "18.04" ] && [ "$DIST_VER" != "20.04" ]; then
    APT_DEPENDENCIES+=(libcvaux-dev libhighgui-dev)
  fi
fi
}

setupenv_HRP2() {
  :
}

setupenv_HRP2KAI() {
  :
}

setupenv_HRP5P() {
  :
}

setupenv_HRP4CR() {
  :
}

setupenv_HRP4J() {
  :
}

setupenv_sch-core() {
:
}

setupenv_state-observation() {
if [ $OSNAME = "Darwin" ]; then
  brew install doxygen
else
  APT_DEPENDENCIES+=(libboost-test-dev libboost-timer-dev)
fi
}

setupenv_hmc2() {
  if [ $OSNAME = "Darwin" ]; then
    brew install libyaml
  else
    APT_DEPENDENCIES+=(libyaml-cpp-dev libyaml-dev libncurses5-dev libglpk-dev)
  fi
}

setupenv_hrpsys-private() {
:
}

setupenv_hrpsys-humanoid() {
if [ $OSNAME != "Darwin" ]; then
  APT_DEPENDENCIES+=(libusb-dev)
fi
}

setupenv_hrpsys-state-observation() {
:
}

setupenv_trap-fpe() {
:
}

setupenv_savedbg() {
  APT_DEPENDENCIES+=(elfutils)
  if [ "$DIST_VER" = 14.04 ]; then
    APT_DEPENDENCIES+=(realpath)
  fi
}

setupenv_choreonoid() {
  if [ $OSNAME = "Darwin" ]; then
    brew install gettext qt zbar
  else
    #choreonoid
    cd $SRC_DIR/choreonoid/misc/script
    # echo "-- Installing choreonoid dependecies using $SRC_DIR/choreonoid/misc/script/install-requisites-$DIST_KIND-$DIST_VER.sh"
    # ./install-requisites-$DIST_KIND-$DIST_VER.sh

      #APT_DEPENDENCIES+=(build-essential)
      #APT_DEPENDENCIES+=(cmake-curses-gui)
      APT_DEPENDENCIES+=(libboost-dev)
      APT_DEPENDENCIES+=(libboost-system-dev)
      APT_DEPENDENCIES+=(libboost-program-options-dev)
      APT_DEPENDENCIES+=(libboost-iostreams-dev)
      APT_DEPENDENCIES+=(libboost-filesystem-dev)
      APT_DEPENDENCIES+=(libeigen3-dev)
      APT_DEPENDENCIES+=(uuid-dev)
      APT_DEPENDENCIES+=(libxfixes-dev)
      APT_DEPENDENCIES+=(libyaml-dev)
      APT_DEPENDENCIES+=(libfmt-dev)
      APT_DEPENDENCIES+=(gettext)
      APT_DEPENDENCIES+=(zlib1g-dev)
      APT_DEPENDENCIES+=(libjpeg-dev)
      APT_DEPENDENCIES+=(libpng-dev)
      APT_DEPENDENCIES+=(qt5-default)
      APT_DEPENDENCIES+=(libqt5x11extras5-dev)
      APT_DEPENDENCIES+=(libqt5svg5-dev)
      APT_DEPENDENCIES+=(qttranslations5-l10n)
      APT_DEPENDENCIES+=(python3-dev)
      APT_DEPENDENCIES+=(python3-numpy)
      APT_DEPENDENCIES+=(libassimp-dev)
      APT_DEPENDENCIES+=(libode-dev) # XXX is this used?
      APT_DEPENDENCIES+=(libfcl-dev) # XXX is this used?
      APT_DEPENDENCIES+=(libpulse-dev)
      APT_DEPENDENCIES+=(libsndfile1-dev) # XXX is this used?
      APT_DEPENDENCIES+=(libgstreamer1.0-dev)
      APT_DEPENDENCIES+=(libgstreamer-plugins-base1.0-dev)

      #hrpcnoid
      if [ "$DIST_VER" = "20.04" ]; then
        APT_DEPENDENCIES+=(libzbar-dev python3-matplotlib libqt5x11extras5-dev libxfixes-dev)
      else
        APT_DEPENDENCIES+=(libzbar-dev python-matplotlib)
      fi
  fi
}

setupenv_choreonoid-ros()
{
  setupenv_choreonoid

  # Setup ROS
  sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
  APT_DEPENDENCIES+=(ros-noetic-desktop python3-catkin-tools libfmt-dev)
}

setupenv_is-jaxa() {
:
}

setupenv_takenaka() {
  :
}

setupenv_flexiport() {
  :
}

setupenv_hokuyoaist() {
  :
}

setupenv_rtchokuyoaist() {
  :
}


if [ ! $# -eq 0 ]; then
  PACKAGES=$@
fi

setupenv_script
for package in $PACKAGES; do
  setupenv_$package
done

if [ "$DIST_VER" = "20.04" ]; then
  # Ensure that we build with python2 on Ubuntu 20.04 (the default is now python3)
  APT_DEPENDENCIES+=(python python-is-python2)
fi;
echo "-- Updating packages list"
sudo $APT update || true
echo "-- Installing dependencies"
sudo $APT install "${APT_DEPENDENCIES[*]}"
