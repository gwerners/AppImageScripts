#!/bin/bash
#https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

#show commands
set -x

#move para o diretorio do script caso seja executado de outro diretorio:
cd "$(dirname "${0}")"

#save base dir
ROOT=$(pwd)

export ARCH=x86_64
APP=SourceTrail
URL=https://github.com/CoatiSoftware/Sourcetrail/releases/download/2019.4.61/Sourcetrail_2019_4_61_Linux_64bit.tar.gz
PACKAGE=Sourcetrail_2019_4_61_Linux_64bit.tar.gz
echo "build SourceTrail appImage"

function checkNeeded {
  NEEDED=$(which ${1})
  if [ ! -f "${NEEDED}" ]; then
    echo "${1} is a dependency for this script!"
    exit 0
  fi
}

function downloadNeeded {
  if [ ! -f "${PACKAGE}" ]; then
    #get binary
    wget -c ${URL}
  fi
  if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    wget -c https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
    chmod a+x appimagetool-x86_64.AppImage
  fi
}

function build {
  mkdir ${APP}.AppDir && cd ${APP}.AppDir
  tar -xzf ${ROOT}/${PACKAGE}
  cp ./Sourcetrail/setup/share/icons/hicolor/256x256/apps/sourcetrail.png .
  sed '/Categories.*$/d' ./Sourcetrail/setup/share/applications/sourcetrail.desktop > ./${APP}.desktop
  sed -i '11iCategories=Development;IDE;' ./${APP}.desktop
  sed '/Exec.*$/d' ./${APP}.desktop > ./${APP}.desktop2
  sed -i '6iExec=Runner' ./${APP}.desktop2
  mv ./${APP}.desktop2 ./${APP}.desktop
  cp Sourcetrail/Sourcetrail.sh Sourcetrail/Runner
  chmod +x Sourcetrail/Runner
  cp ${ROOT}/AppRun.Sourcetrail ./AppRun
  chmod +x ./AppRun
  ${ROOT}/appimagetool-x86_64.AppImage ${ROOT}/${APP}.AppDir ${ROOT}/${APP}-x86_64.AppImage
  rm -rf ${ROOT}/${APP}.AppDir
}

checkNeeded wget  || exit 1
checkNeeded sed  || exit 1
downloadNeeded
build

