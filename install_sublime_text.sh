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

if [ $(uname) = 'Darwin'  ]; then
    STP="$HOME/Library/Application Support/Sublime Text $SUBLIME_TEXT_VERSION/Packages"
    if [ -z $(which subl) ]; then
        brew update
        brew tap caskroom/cask
        if [ $SUBLIME_TEXT_VERSION -eq 2 ]; then
            echo "installing sublime text 2"
            brew cask install sublime-text
            # make `subl` available
            open "$HOME/Applications/Sublime Text 2.app"
            sleep 2
            osascript -e 'tell application "Sublime Text 2" to quit'
            sleep 2
        elif [ $SUBLIME_TEXT_VERSION -eq 3 ]; then
            echo "installing sublime text 3"
            brew tap caskroom/versions
            brew cask install sublime-text3
            # make `subl` available
            open "$HOME/Applications/Sublime Text.app"
            sleep 2
            osascript -e 'tell application "Sublime Text" to quit'
            sleep 2
        fi
    fi
else
    STP="$HOME/.config/sublime-text-$SUBLIME_TEXT_VERSION/Packages"
    if [ -z $(which subl) ]; then
        if [ $SUBLIME_TEXT_VERSION -eq 2 ]; then
            echo "installing sublime text 2"
            sudo add-apt-repository ppa:webupd8team/sublime-text-2 -y
            sudo apt-get update
            sudo apt-get install sublime-text -y
        elif [ $SUBLIME_TEXT_VERSION -eq 3 ]; then
            echo "installing sublime text 3"
            sudo add-apt-repository ppa:webupd8team/sublime-text-3 -y
            sudo apt-get update
            sudo apt-get install sublime-text-installer -y
        fi
    fi
fi

if [ ! -d "$STP" ]; then
    echo creating sublime package directory
    mkdir -p "$STP/User"
    # disable update check
    echo '{"update_check": false }' > "$STP/User/Preferences.sublime-settings"
fi
