#!/usr/bin/env bash

################################################################################
#                                                                              #
#                                                                              #
#                               pacmanToolBelt                                 #
#                                                                              #
# Created By: S4NDM4N                                           Version: 0.0.1 #
################################################################################

#To echo the messages
printLine(){ echo "$@" >&2 ; }

#Sources in  eos-shared and checks for the shared script.
commonScriptCehck(){
    
    local LIB_EOS_SCRIPT=source /usr/share/endeavouros/scripts/eos-script-lib-yad

    if [ ! -f $LIB_EOS_SCRIPT ] ; then
        printLine "Please installe 'eos-bash-share' for this script to work."
        exit 1
    fi

    #Imports in all the goodness from the eos-shared lib.
    source $LIB_EOS_SCRIPT

    #export the needed functions.
    #export -f eos_yad
    export -f eos_yab_RunCmdTermBash
    export -f eos_yad_teminal

}

#Check su or sudo available.
sudoCheck(){
    
    local chkSudo
    local chkSu

    chkSudo=$(sudo -nv 2>&1)
    chkSu=$(su -nv 2>&1)

    if echo "$chkSudo" | grep -q '^sudo:'; then
        echo "sudo"
    elif echo "$chkSu" | grep -q '^su:'; then
        echo "su"
    else
        echo "non"
    fi

}

#After checking echos the right one and assignes the right one the variable.
setSudo(){
    
    suChk=$(sudoCheck)

    case "$suChk" in
        "sudo") echo "sudo" ;;
        "su") echo "su" ;;
        *) exit 1  ;;
    esac
}


#sftNameRepo(){
#    local text=""
#    text+="Enter the name of the sofwate you want to search\n"
#    text+="in the official repository."
#TODO:
#   Make while ... do loop to loop the below command until user enters a value.
#    local nme=(
#        yad --form --align-buttons --use-interp --title="Software Name" \
#        --text="$text" --field="" --button="Search!gtk-search!Click to search":0
#    )
#    local name="$("${nme[@]}" | cut -d '|' -f1)"
#    
#    if [[ -n "$name" ]]; then #Runs the below command if name is not empty
#        case "$?" in
#            0) RunInTerminal pacman -Ss "$name" ;;
#        esac

#    else
#        yad --form --use-interp image="error" --text-align=left \
#        --text="Name field cannot be empty" --title="Empty Field" \
#        --width=300 --button="Close!gtk-close!Click to close.":0

#        case "$?" in
#            0) "${nme[@]}"  ;;
#        esac
#    fi
#}

sftNameRepo(){
    #Variable decleration.
    local nme=()
    local searchName=""
    local result=""
    local text=""
    local check=0

    #Bulding the text message for the GUI.
    text+="Enter the name of the sofwate you want to search\n"
    text+="in the official repository."

    while
    nme=(
        yad --form --align-buttons --use-interp --title="Software Name" \
        --text="$text" --field=""       
    )
    
    #Assign the above YAD array to a new local variable named result.
    #Checks if it's set if not it's returned.
    result="$("${nme[@]}")" ; [ -n "$result" ] || return
    
    #Cut the result varible from the 1 st itteration of text to get the search string.
    searchName="$(echo "$result" | cut -d '|' -f1)"

    #Check if above searchName is set or not. If set then set the check to 1
    #which would execute the 1st command from the below case statement.
    if [[ -n "$searchName" ]]; then
        check=1
    fi    

        case "$check" in
            #If the above searchName is not set then sets check to 2
            0) if [[ -z "$searchName" ]]; then 
                check=2
               fi ;;
            1) RunInTerminal pacman -Ss "$searchName" ;;
            *) ;;
        esac
    
    #If check is equal to 2 then execute the error message.
    #And will throw the loop to top which will show the UI until user search
    #or cancels.
    [[ "$check" -eq 2 ]]
    do
        yad --form --use-interp image="error" --text-align=left \
        --text="Name field cannot be empty" --title="Empty Field" \
        --width=300 --button="OK!gtk-close!Click to close.":0 ;done    
}
export -f sftNameRepo

#Creating the UI using YAD.
mainFunstionSet(){
local su=$(setSudo)
local handle="$1"
local exitBtn="$?"

#Text for the UI.
local lbl=""    
lbl+="Wlecome to pacmanToolBelt\n"
lbl+="This is simple <b>UI for pacman</b>. It runs some simple commen commands\n"
lbl+="with out typing in the terminal.\n"

local windowContent=(
    yad --form --align-buttons --use-interp --title="Pacman Tool Belt" \
    --text="$lbl" --image=gtk-convert --window-icon=gtk-convert --columns=2 \
    --button="Close!gtk-close!Close the app.":0
)   

    windowContent+=(
        --field="Update!application-internet!Synchronize the databases":fbtn "RunInTerminal $su pacman -Sy"
    )

    windowContent+=(
        --field="System Upgrade!application-system!Synchronize the databases and install updates":fbtn "RunInTerminal $su pacman -Syu"
    )

    windowContent+=(
        --field="Search Software!preferences-system!Search for the software in te repos":fbtn 'sftNameRepo'
    )

    windowContent+=(
        --field="Search Installed Software!preferences-system!Search for installed software details":fbtn 'enterSoftwareName'
    )

    [ "$handle" != "calculate" ] && "${windowContent[@]}" >& /dev/null &

    [[ $exitBtn -eq 0 ]] && exit 0
}

mainFunstionSet "$@"