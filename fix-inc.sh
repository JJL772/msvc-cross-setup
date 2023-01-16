#!/usr/bin/env bash

# Fixer for fucked up windows includes
set -e
if [[ -z "$1" ]]; then
	echo "USAGE: $0 <prefix>"
	exit 1
fi

cd "$(dirname "$0")"

# Fixup kits
for kit in "$1/kits/10/Include/"*; do
	#ln -svf "$kit/um/ole2.h" "$kit/um/Ole2.h"
	#ln -svf "$kit/um/olectl.h" "$kit/um/OleCtl.h"
	./msvc-wine/fixinclude "$kit/um/"
done

# Fixup MFC/ATL
for msvc in "$1/VC/Tools/MSVC"*; do
	./msvc-wine/lowercase "$msvc/atlmfc/include"
	./msvc-wine/fixinclude "$msvc/atlmfc/include"
done

