#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "USAGE: setup.sh <prefix>"
	exit 1
fi

pushd msvc-wine > /dev/null
./vsdownload.py --dest "$1"
./install.sh "$1"
./vsdownload.py --dest "$1" "Win10SDK_10.0.20348" "Microsoft.VisualCpp.ATL.X64" "Microsoft.VisualCpp.MFC.X64" "Microsoft.VisualStudio.Component.VC.ATLMFC"
popd > /dev/null

pushd cmake > /dev/null
./configure --prefix="$1" --parallel=$(nproc) -- -DCMAKE_USE_OPENSSL=OFF
make -j$(nproc)
make install
popd > /dev/null


