#!/usr/bin/env python3

import json
import argparse
import re
import pathlib

parser = argparse.ArgumentParser(description='Fixes compile_commands.json generated by CMake when cross compiling with clang-cl')
parser.add_argument('file')
parser.add_argument('--sdk-path', type=str, required=False, help='Use this path to point to the MSVC toolchain')

SYSROOT=re.compile(r"(?<=/winsysroot\s)(\"(.*)\"|\S+)", re.MULTILINE|re.IGNORECASE)

flag_cache = {}

# Builds a list of flags for the MSVC toolchain path (substitute for winsysroot)
def get_flags_from_path(msvc_path: str) -> str:
    global flag_cache
    if msvc_path in flag_cache:
        return flag_cache[msvc_path]
    flags = ''
    # Iterate through msvc paths
    msvc = pathlib.Path(msvc_path) / 'VC/Tools/MSVC'
    for dir in msvc.iterdir():
        msvc = dir
        break # For now just use first
    print(f'MSVC path is {msvc}')

    # Add the common inc dirs for msvc
    flags += f' -I{msvc}/include -I{msvc}/atlmfc/include '

    # Add the windows SDK paths
    winsdk = pathlib.Path(msvc_path) / 'kits/10/Include'
    for dir in winsdk.iterdir():
        winsdk = dir
        break
    print(f'Windows SDK inc path is {winsdk}')
    flags += f' -I{winsdk}/um -I{winsdk}/ucrt -I{winsdk}/shared '

    print(f'flags for {msvc_path}: {flags}')
    flag_cache[msvc_path] = flags
    return flags


def main():
    args = parser.parse_args()
    db = {}
    with open(args.file, 'r') as fp:
        db = json.load(fp)
    for ent in db:
        c: str = ent['command']
        if c is None:
            break
        msvc_path = re.search(SYSROOT, c)
        if msvc_path is None:
            continue
        fl = get_flags_from_path(msvc_path.group(0))
        c = c.replace('/winsysroot', '').replace(f' {msvc_path.group(0)} ', fl)  # Ugly af
        ent['command'] = c

    with open(args.file, 'w') as fp:
        json.dump(db, fp, indent=2)


if __name__ == '__main__':
    main()