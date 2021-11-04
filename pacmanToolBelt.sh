#!/usr/bin/env bash

################################################################################
#                                                                              #
#                                                                              #
#                               pacmanToolBelt                                 #
#                                                                              #
# Created By: S4NDM4N                                           Version: 0.0.1 #
################################################################################

#Creating the UI using YAD.
pacTools=$(yad --width=400 --entry --title="Pacman Tool Belt" \
        --image=gtk-convert --window-icon=gtk-convert \
        --button="Execute:0" --button="Close:1" \
        --text="Choose the commande you want the tool belt to run" \
        --entry-text "pac update" "pac upgrade" "pac check")

cmnd=$? #Get the selected choice and assignes it to cmmd variable.

[[ cmnd -eq 1 ]] && exit 0

case $pacTools in
    *update) cmd="sudo pacman -Sy"   ;;
    *upgrade) cmd="sudo pacman -Syu" ;;
    *check) cmd="yad --width=100 --title='msg' --text='Working'" ;;
    #*) exit 1 ;;
esac

eval exec "$cmd"