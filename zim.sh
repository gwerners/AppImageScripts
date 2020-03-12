#!/bin/bash

#https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

#show commands
#set -x

#move para o diretorio do script caso seja executado de outro diretorio:
cd "$(dirname "${0}")"

#save base dir
ROOT=$(pwd)

export ARCH=x86_64
APP=zim
URL=https://zim-wiki.org/downloads/zim_0.72.0_all.deb
DEB=zim_0.72.0_all.deb
echo "build zim appImage"

function checkNeeded {
  NEEDED=$(which ${1})
  if [ ! -f "${NEEDED}" ]; then
    echo "${1} is a dependency for this script!"
    exit 0
  fi
}

function downloadNeeded {
  if [ ! -f "$DEB" ]; then
      #get binary
      wget -c $URL
  fi
  if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    wget -c https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
    chmod a+x appimagetool-x86_64.AppImage
  fi
}

function build {
  mkdir -p ${APP}/${APP}.AppDir && cd ${APP}

  #turn into appDir
  cd $APP.AppDir
  dpkg -x ${ROOT}/$DEB .
  cp ./usr/share/icons/hicolor/scalable/apps/${APP}.svg .
  sed '/Keywords.*$/d' ./usr/share/applications/${APP}.desktop > ./${APP}.desktop

  wget -c https://raw.githubusercontent.com/AppImage/AppImageKit/master/resources/AppRun
  chmod a+x AppRun
  sed -i '12iexport PYTHONPATH=\${PYTHONPATH}:\${HERE}/usr/lib/python3/dist-packages' AppRun

  cd ..
  cp ${ROOT}/appimagetool-x86_64.AppImage .
  chmod a+x appimagetool-x86_64.AppImage
  ./appimagetool-x86_64.AppImage ${APP}.AppDir ./${APP}-x86_64.AppImage
}

checkNeeded wget  || exit 1
checkNeeded sed  || exit 1
checkNeeded dpkg  || exit 1
downloadNeeded
build

