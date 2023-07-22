#!/bin/sh
#
# aDApp.sh
#
ui_etwo () { echo ""; echo ""; clear; clear; echo ""; }

run_network () {
   # code changed for iproute2
   # challenges ahead, physical vs virtual
   if [ "${WebNic}" = "iproute2" ]; then
	# start PNI
	local incDir=$(echo "${DMMini}" | cut -d'/' -f3);
	. ."/${incDir}/PNIfunc.sh";
   else
	echo ""; echo "..."; echo "";
	echo "net-tools was not financed to survive!";
	echo "Do not use 'ifconfig'!";
	echo "This code works only with ‘iproute2’!"
	echo "";
	ui_pauseExit;
   fi
}

run_fileworks () {
   local fDir="${1}"; local fTmp="${2}";
   local btf=""; local fVar="";

   dialog   --title "Fileworks - ${fDir}" \
            --backtitle "File Explorer" \
            --fselect "${fDir}" 24 64 2>"${fTmp}";

   # capture the action selected
   btf="$?";

   fVar=$(cat "${fTmp}");

   # decsion?
   case "${btf}" in
     0)
	ui_etwo;
        printf "%b \n" "Action: ${btf} Default: ${fDir} Selected: ${fVar}";
	ui_pauseExit;
        ;;
     1)
        return 1;; # Cancel Btn
     255)
        return 1;; # ESC presse
   esac

}

get_Gvar () {
   local fName=$1; local Gvar=$2; local mEQ="";
   local mText=""; local mSrc=""; local gStr="";
   local k=""; local v="";

   if [ -f "${fName}" ]; then
      mText=$(cat "${fName}");
      gStr=$(echo "${mText}" | grep "${Gvar}" | cut -d'|' -f2);
      gStr=$(echo "${gStr}" | cut -d'=' -f2);

      for k in $(echo "${gStr}" | tr ',' '\n'); do

         for mSrc in $(echo "${mText}" | cut -d'|' -f3); do
            mEQ=$(echo "${mSrc}" | cut -d'=' -f1);
            if [ "${mEQ}" = "${k}" ]; then
               v=$(echo "${mSrc}" | cut -d'=' -f2);
               eval $(echo "$k=$v");
            fi
         done
      done
   fi
}

run_inputbox () {
   local OurFile="${DMMfle}"; local gButton="";
   local test_name="";

   # show the inputbox
   dialog   --title "InputBox Example - ${OurFile}" \
            --backtitle "A Dialog Experiment" \
            --inputbox "Baptize something " 8 60 2>"${OurFile}";

   # capture the button action
   gButton="$?";

   # get data stored in OurFile using input redirection
   test_name=$(cat "${OurFile}");

   # decsion?
   case "${gButton}" in
     0)
	ui_etwo;
	printf "%b \n" "Continue Process from user-input: ${test_name}\n";
	echo ""; echo "";
	ui_pauseExit;
	;;
     1)
	ui_etwo;
	return 1;; # Cancel pressed
     255)
	ui_etwo;
	return 1;; # ESC pressed
   esac
}

ui_pauseExit () {
   local entr=""; echo "";
   printf "%b \n" "\n\tPress Enter to continue ...";
   read entr; echo ""; return 1;
}

run_Dialog () {
   while true ; do
        DIALOG=${DIALOG=dialog}

        DMMtmp=`DMMtmp 2>/dev/null` || DMMtmp="${DMMfle}$$"
        trap "rm -f $DMMtmp" 0 1 2 5 15

        $DIALOG --clear --title "AHR(a dialog to?)" \
        --menu "Select a menu option as a staged process" 32 64 16 \
        "1" "Physical Network Interfaces PNI" \
        "2" "Test Input Box ala San Anton" \
        "3" "File Explorer with Dialog" \
        "4" "Include a file or source" \
	"5" "FormBox using sourced FuncLib" \
        "6" "Terminals do not display Chinese" \
        "Si" "Installer Simulation" \
        "Test"  "Reminder of code-work status" \
        "Exit"  "Exit to terminal mode " 2> "${DMMtmp}"

        retval=$?

        choice=$(cat $DMMtmp);

	# refresh get_Gvar
        get_Gvar "${cfgFile}" "loc=";
        get_Gvar "${cfgFile}" "mma=";
        get_Gvar "${cfgFile}" "kit=";

   case $retval in
   0)
        if [ "$choice" = "1" ]; then
           # network
           run_network;
        fi
        if [ "$choice" = "2" ]; then
           # inptbox
           run_inputbox;
        fi
        if [ "$choice" = "3" ]; then
           # File Explorer box
           run_fileworks "${DMMrot}" "${DMMfle}";
        fi
        if [ "$choice" = "4" ]; then
	   #equivalent of source - not a stable code
	   local incDir=$(echo "${DMMini}" | cut -d'/' -f3);
	   . ."/${incDir}/xFuncLib.sh";

           clear; fn_Line;
           echo "Include or source file";

	   # test func included
	   fn_this; echo ""; echo "";
	   ui_pauseExit;
        fi
	if [ "$choice" = "5" ]; then
	   # FormBox
	   # the dept of folder works for now
	   # but it is not the correct approach
	   local incDir=$(echo "${DMMini}" | cut -d'/' -f3);
	   . ."/${incDir}/xFuncLib.sh";
	   fn_formBox;
	fi
        if [ "$choice" = "6" ]; then
           # cat file
           ui_etwo;
	   cat "${DMMwrk}/xChineseQ.ahr";
           echo ""; echo "";
	   printf "%b \n" "\tDMMwrk-Path 2File: ${DMMwrk}\n";
	   printf "%b \n" "Copy and paste to notepad or word processor";
	   printf "%b \n" "[If your terminal does not display such ? tongue]";
	   echo "Use: BvSsh Client vs Powershell";
	   echo ""; echo "";
	   ui_pauseExit;
        fi
        if [ "$choice" = "Si" ]; then
           ui_etwo;
           local incDir=$(echo "${DMMini}" | cut -d'/' -f3);
           . ."/${incDir}/xFuncLib.sh";
	   simulate_installer;
##           ui_pauseExit;
        fi
        if [ "$choice" = "Test" ]; then
	   echo "Vars .................";
	   echo "1. ${DMMrot}";
	   echo "2. ${DMMini}";
	   echo "3. ${WebNic}";
	   REMnotes;
	   cat "${DMMini}";

           ui_pauseExit;
        fi
        if [ "$choice" = "Exit" ]; then
                ui_etwo; exit;
        fi
      ;;

   1)
	ui_etwo;
        return 0;; # Cancel pressed

   255)
	ui_etwo;
        return 0;; # ESC pressed
   esac
   done
}

REMnotes () {
printf "%b \n" "include/source/required";
printf "%b \n" "… as a separate function file";
printf "%b \n" "… since the code is gettin big\n";
printf "%b \n" "Assume ‘main loop’ is aDApp.sh";
printf "%b \n" "Every branch of it is a config-file(functions)";
printf "%b \n" "either ‘auto’ igniting a chain reaction B4 returning";
printf "%b \n" "or a series of CMDs [case B4 returning]\n\n";
}
# "hardcoded because we know - config?"
cfgFile='/xCK/TST/aDConfig.ahr';
if [ -f "${cfgFile}" ]; then
        get_Gvar "${cfgFile}" "loc=";
        get_Gvar "${cfgFile}" "mma=";
	get_Gvar "${cfgFile}" "kit=";
        run_Dialog;
else
        echo "[Dialog APP] Missing Configuration: ${cfgFile}";
        sleep 1;
        exit 2;
fi
