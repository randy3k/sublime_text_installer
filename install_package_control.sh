#! /usr/bin/env bash

BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [[ $# > 1 ]]; do
    key="$1"
    case "$key" in
        --st)
            SUBLIME_TEXT_VERSION="$2"
            shift 2
        ;;
        *)
            echo "Unknown option: $1"
            exit 1
        ;;
    esac
done

if [ -z $SUBLIME_TEXT_VERSION ]; then
    echo "missing Sublime Text version"
    exit 1
fi

if [ $(uname) = 'Darwin' ]; then
    STP="$HOME/Library/Application Support/Sublime Text $SUBLIME_TEXT_VERSION/Packages"
else
    STP="$HOME/.config/sublime-text-$SUBLIME_TEXT_VERSION/Packages"
fi

STIP="${STP%/*}/Installed Packages"

if [ ! -d "$STIP" ]; then
    mkdir -p "$STIP"
fi

PC_PATH="$STIP/Package Control.sublime-package"
if [ ! -f "$PC_PATH" ]; then
    PC_URL="https://packagecontrol.io/Package Control.sublime-package"
    wget -O "$PC_PATH" "$PC_URL"
fi

PCI_PATH="$STP/0_package_control_helper"

if [ ! -d "$PCI_PATH" ]; then
    mkdir -p "$PCI_PATH"
    cp "$BASE"/helper.py "$PCI_PATH"/helper.py
fi

if [ $(uname) = 'Darwin' ]; then
    if [ $SUBLIME_TEXT_VERSION -eq 2 ]; then
        osascript -e 'tell application "Sublime Text 2" to activate'
    elif [ $SUBLIME_TEXT_VERSION -eq 3 ]; then
        osascript -e 'tell application "Sublime Text" to activate'
    fi
else
    subl
fi

Pref="$STP/User/Preferences.sublime-settings"

until [ -f "$Pref" ] && grep 0_package_control_helper "$Pref" > /dev/null ; do
    echo -n "."
    sleep 5
done

sleep 2
echo -e "\nPackage Control installed."
