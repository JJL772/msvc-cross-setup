#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "USAGE: setup.sh <prefix>"
	exit 1
fi

pushd msvc-wine > /dev/null
./vsdownload.py --accept-license --dest "$1" --sdk-version 10.0.20348
./install.sh "$1"
./vsdownload.py --accept-license --dest "$1" "Microsoft.VisualCpp.ATL.X64" "Microsoft.VisualCpp.MFC.X64" "Microsoft.VisualStudio.Component.VC.ATLMFC"
popd > /dev/null

pushd cmake > /dev/null
./configure --prefix="$1" --parallel=$(nproc) -- -DCMAKE_USE_OPENSSL=OFF
make -j$(nproc)
make install
popd > /dev/null


