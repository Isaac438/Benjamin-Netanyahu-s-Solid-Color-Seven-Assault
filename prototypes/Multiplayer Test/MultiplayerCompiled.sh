#!/bin/sh
printf '\033c\033]0;%s\a' Multiplayer Test
base_path="$(dirname "$(realpath "$0")")"
"$base_path/MultiplayerCompiled.x86_64" "$@"
