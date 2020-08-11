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
#which python2
#python2 --version
#which python3
#python3 --version
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

# setup venv
sudo ${PYTHON_PATH} -m pip install --upgrade --ignore-installed pip setuptools virtualenv
sudo rm -rf /tmp/pyinstaller_venv
${PYTHON_PATH} -m virtualenv /tmp/pyinstaller_venv
source /tmp/pyinstaller_venv/bin/activate

# install PyInstaller
python -m pip uninstall -y PyInstaller
python -m pip install --upgrade --ignore-installed PyInstaller
#sudo ${PYTHON_PATH} -m pip install --upgrade --ignore-installed https://github.com/pyinstaller/pyinstaller/archive/develop.zip

#####################
# PYINSTALLER BUILD #
#####################

mkdir pyinstaller
pushd pyinstaller

#${PYTHON_PATH} -m PyInstaller -y --clean --windowed --onefile --debug all --name "${APP_NAME}" ../main.py
python -m PyInstaller -y --clean --windowed --onefile --log-level DEBUG --name "${APP_NAME}" ../main.py

pushd dist

# change the timestamps of all the files in the .app dir for reproducable builds
find ${APP_NAME}.app -exec touch -h -t "`date -r ${SOURCE_DATE_EPOCH} "+%Y%m%d%H%M.%S"`" {} +

# and the onefile binary too
touch -h -t "`date -r ${SOURCE_DATE_EPOCH} "+%Y%m%d%H%M.%S"`" "${APP_NAME}"
shasum "${APP_NAME}"

#hdiutil create ./${APP_NAME}.dmg -srcfolder ${APP_NAME}.app -ov
hdiutil create ./${APP_NAME}.dmg -srcfolder ${APP_NAME} -ov
touch -h -t "`date -r ${SOURCE_DATE_EPOCH} "+%Y%m%d%H%M.%S"`" "${APP_NAME}.dmg"
shasum "${APP_NAME}.dmg"

popd

#######################
# OUTPUT VERSION INFO #
#######################

uname -a
sw_vers
#which python2
#python2 --version
#which python3
#python3 --version
python --version
python -m pip list
python -c 'import os; print( os.environ )'
python -c 'import sys; print( sys.argv, sys.builtin_module_names, sys.executable, sys.path, sys.platform, sys.prefix, sys.version, sys.api_version )'

echo $PATH
pwd
ls -lah
ls -lah dist

##################
# CLEANUP & EXIT #
##################

# exit cleanly
exit 0
