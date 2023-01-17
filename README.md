# win64-cross-setup

A tiny little wrapper around msvc-wine

./setup-lldb.sh to setup lldb within your current `WINEPREFIX`, for easier debugging.

./setup.sh to setup stuff needed to build Source engine tools/games.

## Usage

Make sure to clone recursively

```sh
# Setup the base MSVC stuff, incl. MFC/ATL
./setup.sh ~/msvc

# Setup LLDB for easier debugging
./setup-lldb.sh ~/msvc

# Fixup bad includes and create some library symlinks
./fixup.sh ~/msvc
```
