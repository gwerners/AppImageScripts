#!/bin/bash
#https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

#show commands
#set -x

#move para o diretorio do script caso seja executado de outro diretorio:
cd "$(dirname "${0}")"

#save base dir
ROOT=$(pwd)

echo "build leafpad appImage"

function checkNeeded {
  NEEDED=$(which ${1})
  if [ ! -f "${NEEDED}" ]; then
    echo "${1} is a dependency for this script!"
    exit 0
  fi
}

function downloadNeeded {
  if [ ! -f "leafpad_0.8.18.1-5_amd64.deb" ]; then
    #get binary
    wget -c http://ftp.rz.tu-bs.de/pub/mirror/ubuntu-packages/pool/universe/l/leafpad/leafpad_0.8.18.1-5_amd64.deb
  fi
  if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    wget -c https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
    chmod a+x appimagetool-x86_64.AppImage
  fi
}

function build {
  mkdir leafpad.AppDir

  #turn into appDir
  cd leafpad.AppDir
  dpkg -x ${ROOT}/leafpad_0.8.18.1-5_amd64.deb .
  cp ./usr/share/icons/hicolor/scalable/apps/leafpad.svg .
  cp ./usr/share/applications/leafpad.desktop .
  sed -i '/Keywords.*$/d' leafpad.desktop
  sed -i 's/text\/plain/text\/plain;/' leafpad.desktop

  wget -c https://raw.githubusercontent.com/AppImage/AppImageKit/master/resources/AppRun
  chmod a+x AppRun
  cd ${ROOT}
  ./appimagetool-x86_64.AppImage leafpad.AppDir Leafpad-x86_64.AppImage
  rm -rf leafpad.AppDir
  rm leafpad_0.8.18.1-5_amd64.deb
}

checkNeeded wget  || exit 1
checkNeeded sed  || exit 1
checkNeeded dpkg  || exit 1
downloadNeeded
build

