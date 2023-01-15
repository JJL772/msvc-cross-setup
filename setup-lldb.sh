#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
	echo "USAGE: $0 <prefix>"
	exit 1
fi

cd "$(dirname "$0")"

PYVER="3.10.0"
LLVMVER="15.0.6"

if [[ -z "$WINEPREFIX" ]]; then
	WINEPREFIX="$HOME/.wine"
fi

# Install llvm
LLVMFILE="LLVM-$LLVMVER-win64.exe"
if [[ ! -f "$LLVMFILE" ]]; then
	wget "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVMVER/$LLVMFILE"
fi
#wine "$LLVMFILE"

# Download and install python
PYFILE="python-$PYVER-embed-amd64.zip"
if [[ ! -f "$PYFILE" ]]; then
	wget "https://www.python.org/ftp/python/$PYVER/$PYFILE"
fi
[[ -d python3 ]] && rm -rf python3
mkdir -p python3 && pushd python3 > /dev/null
unzip "../$PYFILE"
cp -fv $(find .) "$WINEPREFIX/drive_c/Program Files/LLVM/bin/"
popd > /dev/null

# register the dlls
wine regsvr32.exe "$1/DIA SDK/bin/amd64/msdia140.dll"
wine regsvr32.exe "$1/DIA SDK/bin/msdia140.dll"
