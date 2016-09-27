#! /usr/bin/env bash

set -e

while [ "$#" -ne 0 ]; do
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
    echo "Missing Sublime Text version"
    exit 1
fi

STWEB="https://www.sublimetext.com/$SUBLIME_TEXT_VERSION"

if [ $(uname) = 'Darwin'  ]; then
    STP="$HOME/Library/Application Support/Sublime Text $SUBLIME_TEXT_VERSION/Packages"
    if [ -z $(which subl) ]; then
        if [ $SUBLIME_TEXT_VERSION -eq 2 ]; then
            SUBLIME_TEXT="Sublime Text 2"
        elif [ $SUBLIME_TEXT_VERSION -eq 3 ]; then
            SUBLIME_TEXT="Sublime Text"
        fi
        echo "installing sublime text $SUBLIME_TEXT_VERSION"
        URL=$(curl -s "$STWEB" | sed -n 's/.*href="\([^"]*\.dmg\)".*/\1/p')
        if [ -z "$URL" ]; then
            echo "could not download Sublime Text binary"
            exit 1
        fi
        echo "downloading $URL"
        curl "$URL" -o ~/Downloads/sublimetext.dmg
        hdiutil attach ~/Downloads/sublimetext.dmg
        cp -r "/Volumes/$SUBLIME_TEXT/$SUBLIME_TEXT.app" "$HOME/Applications/$SUBLIME_TEXT.app"
        mkdir -p $HOME/.local/bin
        ln -s "$HOME/Applications/$SUBLIME_TEXT.app/Contents/SharedSupport/bin/subl" \
            $HOME/.local/bin/subl
        # make `subl` available
        open "$HOME/Applications/$SUBLIME_TEXT.app"
        sleep 2
        osascript -e "tell application "'"'"$SUBLIME_TEXT"'"'" to quit"
        sleep 2
    fi
else
    STP="$HOME/.config/sublime-text-$SUBLIME_TEXT_VERSION/Packages"
    if [ -z $(which subl) ]; then
        if [ $SUBLIME_TEXT_VERSION -eq 2 ]; then
            SUBLIME_TEXT="Sublime Text 2"
        elif [ $SUBLIME_TEXT_VERSION -eq 3 ]; then
            SUBLIME_TEXT="sublime_text_3"
        fi
        echo "installing sublime text $SUBLIME_TEXT_VERSION"
        URL=$(curl -s "$STWEB" | sed -n 's/.*href="\([^"]*x64\.tar\.bz2\)".*/\1/p')
        if [ -z "$URL" ]; then
            echo "could not download Sublime Text binary"
            exit 1
        fi
        echo "downloading $URL"
        if [ ! -d ~/Downloads ]; then
            mkdir ~/Downloads
        fi
        curl "$URL" -o ~/Downloads/sublimetext.tar.bz2
        tar jxfv ~/Downloads/sublimetext.tar.bz2 -C ~/Downloads/
        mkdir -p $HOME/.local/bin
        ln -sf "$HOME/Downloads/$SUBLIME_TEXT/sublime_text" $HOME/.local/bin/subl
        # make `subl` available
        "$HOME/Downloads/$SUBLIME_TEXT/sublime_text" &
        sleep 2
        killall sublime_text
        sleep 2
    fi
fi

if [ ! -d "$STP" ]; then
    echo creating sublime package directory
    mkdir -p "$STP/User"
    # disable update check
    echo '{"update_check": false }' > "$STP/User/Preferences.sublime-settings"
fi
