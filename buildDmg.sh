#!/bin/bash
set -x

############
# SETTINGS #
############

PYTHON_PATH='/usr/local/bin/python3'
APP_NAME='helloWorld'

# make PyInstaller produce reproducible builds. This will only affect the hash
# randomization at build time. When the frozen app built by PyInstaller is
# executed, hash randomization will be enabled (per defaults)
# * https://pyinstaller.readthedocs.io/en/stable/advanced-topics.html#creating-a-reproducible-build
# * https://docs.python.org/3/using/cmdline.html#cmdoption-r
export PYTHONHASHSEED=1

# https://reproducible-builds.org/docs/source-date-epoch/
export SOURCE_DATE_EPOCH=1577883661

########
# INFO #
########

# print some info for debugging failed builds
uname -a
sw_vers
which python2
python2 --version
which python3
python3 --version
${PYTHON_PATH} --version
echo $PATH
pwd
ls -lah
env

###################
# INSTALL DEPENDS #
###################

# first update brew
brew update

# install os-level depends
brew install python3

# install PyInstaller
#${PYTHON_PATH} -m pip install --upgrade --user PyInstaller
${PYTHON_PATH} -m pip install --upgrade --user https://github.com/pyinstaller/pyinstaller/archive/develop.zip

#####################
# PYINSTALLER BUILD #
#####################

mkdir pyinstaller
pushd pyinstaller

${PYTHON_PATH} -m PyInstaller -y --clean --windowed --name "${APP_NAME}" ../main.py

pushd dist

# change the timestamps of all the files in the appdir or reproducable builds
find ${APP_NAME}.app -exec touch -h -t "`date -r ${SOURCE_DATE_EPOCH} "+%Y%m%d%H%M.%S"`" {} +

hdiutil create ./${APP_NAME}.dmg -srcfolder ${APP_NAME}.app -ov
touch -h -t "`date -r ${SOURCE_DATE_EPOCH} "+%Y%m%d%H%M.%S"`" "${APP_NAME}.dmg"

popd

#######################
# OUTPUT VERSION INFO #
#######################

uname -a
sw_vers
which python2
python2 --version
which python3
python3 --version
${PYTHON_PATH} --version
${PYTHON_PATH} -m pip list
echo $PATH
pwd
ls -lah
ls -lah dist

##################
# CLEANUP & EXIT #
##################

# exit cleanly
exit 0
