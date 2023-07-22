#!/bin/sh
# only functions here
# call this file as: . ./Demo/xFuncLib.sh (an equivalent of source)
#
fn_etwo () { echo ""; echo ""; clear; clear; echo ""; }

fn_Line () {
   echo ""; echo ""; clear;
   DMMrot=$(echo $(pwd)); ### to make sure
   l64chrs="---------------------------------------------------------------";
   printf "%b \n" "\n${l64chrs}";
}

fn_prompt () {
   # USE AS:
   # if ui_prompt "Press Y/yes to confirm (N/n cancel): ";
   local yn="";
   while true; do
      read -p "$1 " yn
      case $yn in
	[Yy]* ) return 0 ;;
	[Nn]* ) return 1 ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

fn_this () {
   local lstF=""; local fl=""; local rp="";
   local tDir="";

   printf "%b \n" "\tHello World ${DMMrot}\n\n";

   tDir=$(dirname "$0");
   rp=$(readlink -f "${tDir}/xFuncLib.sh");

   printf "%b \n" "\tScript Dir: ${tDir} Script Path: ${rp}";
   ###Some sinister reaction is source [. ./Demo/file name]
   ###For some reason did not accept a full path to file

}

fn_pauseExit () {
   local entr=""; echo "";
   printf "%b \n" "\tPress Enter to continue ...";
   read entr; echo ""; return 1;
}

# Same function used by installer script
# The function creates its own tmp-file
fn_formBox () {
   local DMMrot=$(echo $(pwd));
   local iTmp="${DMMrot}/zTmp";
   local iFle="${iTmp}/fTemp.ahr";

   if [ ! -d "${iTmp}" ]; then
      mkdir -p "${iTmp}";
      printf "%b \n" "\tDirectory Created: ${iTmp}";
      touch "${iFle}";
   else
      printf "%b \n" "\tDirectory Exists: ${iTmp}";
      touch "${iFle}";
   fi

   local retval="";
   while true ; do
        DIALOG=${DIALOG=dialog}

        iTmp=`iTmp 2>/dev/null` || iTmp="${iFle}$$"
        trap "rm -f $iTmp" 0 1 2 5 15

        $DIALOG --clear --title "AHR(a dialog to?)" \
      --backtitle "A Dialog Experiment" \
      --form "Create Project Space: ${DMMrot}" 12 64 4 \
         "    Project Name Folder: " 1 1 "/Demo" 1 25 25 0 \
         "Dialog Temporary Folder: " 2 1 "/zDtmp" 2 25 25 0 \
         "  Project Backup Folder: " 3 1 "/zBkup" 3 25 25 0 2>"${iFle}";

        retval="$?";
   local nK=1; local vC=1; local vStr="";
   local sk="DMMwrk,DMMtmp,DMMbkp";
   vStr=$(cat "${iFle}");
   vStr=$(echo "${vStr}" | tr '\n' ',');
   vStr=$(echo "${vStr}" | cut  -d',' -f1,2,3);

   for k in $(echo "${sk}" | tr ',' '\n'); do
      v=$(echo "${vStr}" | cut  -d',' -f"${nK}");
      eval $(echo "$k=$v");
   nK=$(($nK + 1));
   done

   rm -R "${DMMrot}/zTmp";

   case "${retval}" in

   0)
	#This is where the action starts
	ui_etwo;
	echo "WorkSpace: ${DMMwrk}\nDTmp: ${DMMtmp}\nBackup: ${DMMbkp}\n\n";
	ui_pauseExit;
	return 0 ;;
   1)
	rm -R "${DMMrot}/zTmp";
	exit;
	return 0;; #Cancel pressed
   255)
	rm -R "${DMMrot}/zTmp";
	return 0;; # ESC pressed
   esac
   done
}

#
# START a series of functions to simulate the installer
#

toolkit () {
   # Math or Arithmetic? lets try old bc

   iNetCheck;
   echo "vNet:${vNet}" 2>>"${tFle}";

   # OS version will change these checks
   # recode may be required
   # lets think granulation for now

   bashCheck; # require version limitation
   if [ $(echo "${VerBash}*100 < 500" | bc) -eq 1 ]; then
	printf "%b \n" "\tRequires Bash version 5.0 or greater";
	exit;
   else
	echo "VerBash:${VerBash}" 2>>"${tFle}";
   fi

   CoreUtlCheck;
   if [ $(echo "${VerCoreUtl}*100 < 830" | bc) -eq 1 ]; then
	printf "%b \n" "\tRequires GNU CoreUtilities version 8.3 or greater";
	exit;
   else
	echo "VerCoreUtl:${VerCoreUtl}" 2>>"${tFle}";
   fi

   DialogCheck;
   if [ $(echo "${VerDialog}*100 < 130" | bc) -eq 1 ]; then
	printf "%b \n" "\tRequires Dialog version 1.3 or greater";
	exit;
   else
	echo "VerDialog:${VerDialog}" 2>>"${tFle}";
   fi

   siRun="end";
}

bashCheck () {
   VerBash=$(bash --version | cut -d'.' -f1,2);
   VerBash=$(echo "${VerBash}" | tr '\n' '|');
   VerBash=$(echo "${VerBash}" | cut -d'|' -f1);
   VerBash=$(echo "${VerBash}" | cut -d' ' -f4);
}

DialogCheck () {
   VerDialog=$(dialog --version | cut -d' ' -f2);
   VerDialog=$(echo "${VerDialog}" | cut -d'-' -f1);
}

CoreUtlCheck () {
   VerCoreUtl=$(echo $(dd --version | cut -d' ' -f3));
   VerCoreUtl=$(echo "${VerCoreUtl}" | cut -d' ' -f1);
}

iNetCheck () {
   ckver=0; # check version of tool aka inet
   ckver=$(ip -V | wc -l);
   if [ "${ckver}" -eq 0 ]; then
        # ifconfig is old
        vNet="ifconfig";
   else
        # return/check default
        vNet=$(ip -V);
        vNet=$(echo "${vNet}" | cut -d',' -f2);
        vNet=$(echo "${vNet}" | sed "s/ //");
        vNet=$(echo "${vNet}" | cut -d'-' -f1);
   fi

}

embedded_library () {
   elres="${1}"; src=""; rQ=""; rA=""; Action="";
   r="bash:Please+install+Bash+version+5.0+or+greater,";
   r="${r}dd:Please+install+GNU+CoreUtilities+version+8.3+or+greater,";
   r="${r}dialog:Please+install+Dialog+version+1.3+or+greater";

   # iterate through r for input
   # where input is the question $1.
   for src in $(echo "${r}" | tr ',' '\n'); do
	rQ=$(echo "${src}" | cut -d':' -f1);
	rA=$(echo "${src}" | cut -d':' -f2);
	rA=$(echo "${rA}" | sed "s/+/ /g");

	# if matched case in lib ret answer
	case "${elres}" in
	   *"${rQ}"*) printf "%b \n" "\t${rA}" 
	   Action="exit";
	   ;;
	   *) ;;
	   esac
   done

}

checkITlog () {
   # suppress err to log-file
   echo "Creating Temporary Log (checkITlog)";
   if [ ! -d "${tDir}" ]; then
	mkdir -p "${tDir}";
	printf "%b \n" "Directory Created: ${tDir}";
	touch "${tFle}";
	printf "%b \n" "\tFile Created: ${tFle}";
   else
	touch "${tFle}"
	printf "%b \n" "Directory Exists: ${tDir}";
	printf "%b \n" "\tRefresh File: ${tFle}";
   fi

   # catch what fails
   VerBash=$(bash --version | cut -d',' -f2) 2>>"${tFle}";
   VerCoreUtl=$(dd --version | cut -d' ' -f3) 2>>"${tFle}";
   VerDialog=$(dialog --version | cut -d' ' -f2) 2>>"${tFle}";

   tErr=$(cat "${tFle}");

   embedded_library "${tErr}";

   if [ "${Action}" = "exit" ]; then
	# some closing statement
	rm -R "${tDir}";
	echo ""; echo "";
	echo "After installing the required packages rerun this code again!";
	echo ""; echo ""; exit 1;
   else
	# keep checking versions
	printf "%b \n"  "Version have same QnA except inet\n\tToolKit:";
	toolkit;
   fi

}

simulate_installer () {
   DMMrot=$(echo $(pwd)); # confined to current directory
   tErr=""; # catch what fails in this temporary assignment
   tDir="${DMMrot}/zLog";
   tFle="${tDir}/aDInstall.ahr";

   siRun="start";

echo "Assuming bash package was not installed";
echo "the simulation changed the word bash with Xbash";
echo "in checkITlog functions"
echo ""; echo "";
echo "Same can be done by modifying the code";
echo "to check for a higher version than existing";
echo "in function toolkit";
echo ""; echo "";
echo "Pausing the code with fn_pauseExit in order";
echo "to cat/display the temporary log/file";
#
#

   fn_pauseExit;

   checkITlog;

   #display temp file prior finishing the program run
   echo ""; echo "";
   cat "${tFle}";
   fn_pauseExit;

   if [ "${siRun}" = "end" ]; then
	rm -R "${tDir}";
   fi
}

#
# END simulate the installer
#
