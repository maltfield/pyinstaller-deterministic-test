$ErrorActionPreference = 'continue'
Set-PSDebug -Trace 1

######################################
#### A Note about ' | Out-String' ####
######################################
# Straingely, when PowerShell calls any '.exe', it appears to have an implicit
# amp-off effect where that .exe is executed in the background and the next
# command is initiated without waiting. This creates tons of nondeterministic
# and undesired behaviour. The fix is a hack: just append ' | Out-String' to the
# end of an .exe call, and it will prevent it from running in the backgound,
# delaying the subsequent line from running until the current line finishes
######################################

############
# SETTINGS #
############

$env:APP_NAME="helloWorld"

# make PyInstaller produce reproducible builds. This will only affect the hash
# randomization at build time. When the frozen app built by PyInstaller is
# executed, hash randomization will be enabled (per defaults)
# * https://pyinstaller.readthedocs.io/en/stable/advanced-topics.html#creating-a-reproducible-build
# * https://docs.python.org/3/using/cmdline.html#cmdoption-r
$env:PYTHONHASHSEED=0

# https://reproducible-builds.org/docs/source-date-epoch/
$env:SOURCE_DATE_EPOCH=1577883661

########
# INFO #
########

Write-Output "listing contents of C drive root"
Get-ChildItem -Path C:\ -Force | Out-String

Write-Output "listing contents of cwd"
Get-ChildItem -Force | Out-String

Write-Output 'INFO: Beginning execution'

###################
# INSTALL DEPENDS #
###################

# See https://docs.python.org/3.7/using/windows.html#installing-without-ui
Write-Output 'INFO: Downloading python3.7'
curl -OutFile python3.7.exe https://www.python.org/ftp/python/3.7.7/python-3.7.7-amd64.exe | Out-String

Write-Output 'INFO: Installing python'
New-Item -Path C:\tmp -Type Directory | Out-String
New-Item -Path C:\tmp\python -Type Directory | Out-String
.\python3.7.exe /passive TargetDir=C:\tmp\python IncludePip=1 | Out-String

Write-Output 'INFO: Installing pip, setuptools, and virtualenv' | Out-String
C:\tmp\python\python.exe -m pip install --upgrade --user pip wheel setuptools virtualenv | Out-String

Write-Output 'INFO: Enter venv'
New-Item -Path C:\tmp\pyinstaller_venv -Type Directory | Out-String
C:\tmp\python\python.exe -m virtualenv C:\tmp\pyinstaller_venv | Out-String
C:\tmp\pyinstaller_venv\Scripts\activate.ps1 | Out-String

Write-Output 'INFO: Installing Python Depends'
C:\tmp\pyinstaller_venv\Scripts\python.exe -m pip install --upgrade PyInstaller | Out-String

#############
# BUILD EXE #
#############

# create 'pyinstaller' dir and enter it
New-Item -Path pyinstaller -Type Directory | Out-String
cd pyinstaller | Out-String

C:\tmp\pyinstaller_venv\Scripts\python.exe -m PyInstaller -y --clean --windowed --onefile --log-level DEBUG --name "$env:APP_NAME" ../main.py

# output the file hash
Get-FileHash dist\$env:APP_NAME | Out-String

# return to the root of our build dir
cd .. | Out-String

#######################
# OUTPUT VERSION INFO #
#######################

# output list of files
Get-ChildItem -Force | Out-String
Get-ChildItem -Path pyinstaller -Force | Out-String
Get-ChildItem -Path pyinstaller\dist -Force | Out-String

Write-Output 'INFO: Python versions info'

# before exiting, output the versions of software installed
C:\tmp\pyinstaller_venv\Scripts\python.exe --version | Out-String
C:\tmp\pyinstaller_venv\Scripts\python.exe -m pip list | Out-String

# print all environment variables
Get-ChildItem env:

##################
# CLEANUP & EXIT #
##################

# TODO?
