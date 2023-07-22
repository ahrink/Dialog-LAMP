#!/bin/sh
#
# aDInstall.sh
#
DMMrot=$(echo $(pwd)); # confined to current directory
tErr=""; # catch what fails in this temporary assignment
   tDir="${DMMrot}/zLog";
   tFle="${tDir}/aDInstall.ahr";

ui_etwo () { echo ""; echo ""; clear; clear; echo ""; }

ini_FileNdx () {
   local NdxFle="${1}";
   local varNdx=""; local tCnt=1; local NdxLne="";

   local fBak=$(echo "${NdxFle}" | sed -e "s:.ahr:.bak:");
   varNdx=$(cat "${NdxFle}");

   touch "${fBak}";

   for NdxLne in $(echo "${varNdx}"); do
        echo "${tCnt}|${NdxLne}" >> "${fBak}";

   tCnt=$(($tCnt + 1));
   done

   mv "${fBak}" "${NdxFle}";

}

run_Install () {
   ui_etwo;

   # app structure and initialization
   # local DMMrot=$(echo $(pwd));

   # Set defaults if not override
   if [ -z "${DMMwrk}" ]; then
	local DMMwrk="${DMMrot}/Demo";
   else
	local DMMwrk="${DMMrot}${DMMwrk}";
   fi
   if [ -z "${DMMtmp}" ]; then
	local DMMtmp="${DMMrot}/zDtmp";
   else
	local DMMtmp="${DMMrot}${DMMtmp}";
   fi
   if [ -z "${DMMbkp}" ]; then
	local DMMbkp="${DMMrot}/zBkup";
   else
	local DMMbkp="${DMMrot}${DMMbkp}";
   fi

   # files and path to file
   local DMMrun="${DMMrot}/aDStart.sh";    	# app_start.sh
   local DMMfle="${DMMtmp}/aDTmp.ahr";       	# mm_Temp.ahr
   local DMMapp="${DMMwrk}/aDApp.sh";       	# mm_app.sh
   local DMMini="${DMMwrk}/aDConfig.ahr";    	# ini_Demo.ahr
   local DMMcin="${DMMwrk}/xChineseQ.ahr";	# ChineseQ.ahr
   local DMMtxt="${DMMwrk}/xFuncLib.sh";   	# FuncLib.sh
   local DMMpni="${DMMwrk}/PNIfunc.sh";		# inetWorks

   # if not reserved_names
   # create workspace
   local dirNames="${DMMwrk},${DMMtmp},${DMMbkp}";
   ini_DirCre "${dirNames}";

   # create Dialog temporary file (DMMfle)
   echo "Dialog temporary file";
   if [ ! -f "${DMMfle}" ]; then
        touch "${DMMfle}";
        printf "%b \n" "\tCreated File: ${DMMfle}";
   else
	printf "%b \n" "\tFile Exists: ${DMMfle}";
   fi

   # mapping names k=v prospective (cumulate manipulate)
   if [ ! -f "${DMMini}" ]; then

     ## group ver
     local GverDsc="Bash Version,CoreUtil Version,Dialog Version";
     local GverVar="VerBash,VerCoreUtl,VerDialog";
     local k=""; local res="";

     # pack the key=val for further needs
     for k in $(echo "${GverVar}" | tr ',' '\n'); do
	###res=$(eval "res=\$$k");
	res=$(eval echo \${$k});
	rkey="${rkey}:${k}=${res}";
     done

     # call the config writer
     ini_Str2File "ver" "${rkey}" "${GverDsc}" "${DMMini}";

     ## group loc
     local k=""; local rkey=""; local res="";
     local GlocDsc="Directory Path,Configuration File";
     local GlocVar="DMMrot,DMMini";

     # loc-pack the key=val
     for k in $(echo "${GlocVar}" | tr ',' '\n'); do
        res=$(eval echo \${$k});
        ###res=$(eval "res=\$$k");
        rkey="${rkey}:${k}=${res}";
     done

     ini_Str2File "loc" "${rkey}" "${GlocDsc}" "${DMMini}";

     ## group mma
     local k=""; local rkey=""; local res="";
     local GmmaDsc="Dialog Work Space,Dialog TMP-Folder,Dialog TMP-File,Dialog Application";
     local GmmaVar="DMMwrk,DMMtmp,DMMfle,DMMapp";

     # mma-pack the key=val
     for k in $(echo "${GmmaVar}" | tr ',' '\n'); do
	###res=$(eval "res=\$$k");
	res=$(eval echo \${$k});
	rkey="${rkey}:${k}=${res}";
     done

     ini_Str2File "mma" "${rkey}" "${GmmaDsc}" "${DMMini}";

     # Group tool-kit
     #...iproute2, apache2, bind9, dnsutils etc
     local k=""; local rkey=""; local res="";
     local WebNic="${vNet}"; local WebSrv="N";
     local WebDns="N"; local WebUtl="N"; local WebOtr="N";
     local GkitDsc="Network Interfaces,HTTP Server,Bind9 DNS Server,Nameserver Utility,Other Web Server";
     local GkitVar="WebNic,WebSrv,WebDns,WebUtl,WebOtr";

     # kit-pack the key=val
     for k in $(echo "${GkitVar}" | tr ',' '\n'); do
	###res=$(eval "res=\$$k");
	res=$(eval echo \${$k});
	rkey="${rkey}:${k}=${res}";
     done

     ini_Str2File "kit" "${rkey}" "${GkitDsc}" "${DMMini}";

     ## reindex config file
     ini_FileNdx "${DMMini}";

     ## move files where they belong
     mv "${DMMrot}/aDApp.sh" "${DMMapp}"; 	# aDApp.sh
     mv "${DMMrot}/xChineseQ.ahr" "${DMMcin}"; 	# xChineseQ.ahr
     mv "${DMMrot}/xFuncLib.sh" "${DMMtxt}"; 	# xFuncLib.sh
     mv "${DMMrot}/PNIfunc.sh" "${DMMpni}";	# inetWork

     # copy components to backup
     cp "${DMMapp}" "${DMMbkp}/aDApp.sh";
     cp "${DMMrun}" "${DMMbkp}/aDStart.sh";
     cp "${DMMini}" "${DMMbkp}/aDConfig.ahr"
     cp "${DMMcin}" "${DMMbkp}/xChineseQ.ahr";
     cp "${DMMtxt}" "${DMMbkp}/xFuncLib.sh";
     cp "${DMMpni}" "${DMMbkp}/PNIfunc.sh";
     cp "${DMMrot}/aDInstall.sh" "${DMMbkp}/aDInstall.sh";

     rm "${DMMrot}/aDInstall.sh";
     chmod +x "${DMMapp}";
     chmod +x "${DMMrun}";

     echo ""; echo "Backup Complete to: ${DMMbkp}";

   fi

   echo "Display Config File: ${DMMini}";
   cat "${DMMini}";

   # D-only one file in DMMrot directory is aDStart.sh
   # ls -l;

   # three lines must be replaced
   # medical-surgery of code lines
   local orgFile="${DMMrot}/aDStart.sh";
   local srcLn='local ckFile=';
   local rplLn="local ckFile=\'${DMMini}\';";
   sed -i '/'"${srcLn}"'/'"c\\${rplLn}"'/' "${orgFile}";
   sleep 1;
   sed -i -e "s:;\/:;:" "${orgFile}";
   srcLn='local RunAPP=';
   rplLn="local RunAPP=\'${DMMwrk}/aDApp.sh\';";
   sed -i '/'"${srcLn}"'/'"c\\${rplLn}"'/' "${orgFile}";
   sleep 1;
   sed -i -e "s:;\/:;:" "${orgFile}";

   orgFile="${DMMapp}";
   srcLn='cfgFile=';
   rplLn="cfgFile=\'${DMMini}\';";
   sed -i '/'"${srcLn}"'/'"c\\${rplLn}"'/' "${orgFile}";
   sleep 1;
   sed -i -e "s:;\/:;:" "${orgFile}";

   # remove install tmp-log rm -R "${tDir}"
   rm -R "${tDir}";
   printf "%b \n" "\n...\n\tPlease run: sh ${DMMrun}";

}

run_aDialog () {
   local DMMrot=$(echo $(pwd));
   local iTmp="${DMMrot}/zTmp";
   local iFle="${iTmp}/fTemp.ahr";

   if [ ! -d "${iTmp}" ]; then
      mkdir -p "${iTmp}";
      echo "\tDirectory Created: ${iTmp}";
      touch "${iFle}";
   else
      echo "\tDirectory Exists: ${iTmp}";
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

	run_Install;
	return 0 ;;

   1)
	return 0;; #Cancel pressed

   255)
	return 0;; # ESC pressed
   esac
   done

}

ini_Str2File () {
   #
   local grpName="${1}"; local grpKey="${2}";
   local grpDsc="${3}"; local grpFile="${4}";
   local iDate=$(date +"%Y%m%d%H%M%S");

   # create ini file
   if [ ! -f "${grpFile}" ]; then
        printf "%b \n" "\nConfig File NOT found: ${grpFile}";
        touch "${grpFile}";
        printf "%b \n" "\t\tCreated File: ${grpFile}";
   fi

   # replace 1st occurance
   local grpKey=$(echo "${grpKey}" | sed "s/://");

   # Group is an array of keys  (pOne/Part One)
   # cumulate keys in a group
   local pOne=""; local k=""; local eqKey="";
   local pTwo=""; local eqVal=""; local dk="";

   for k in $(echo "${grpKey}" | tr ':' '\n'); do
        eqKey=$(echo "${k}" | cut -d'=' -f1);
        eqVal=$(echo "${k}" | cut -d'=' -f2);
        pOne="${pOne},${eqKey}";
        pTwo="${pTwo}:${eqKey}=${eqVal}";
   done

   pOne=$(echo "${pOne}" | sed "s/,//");
   pOne="${grpName}=${pOne}|";
   pTwo=$(echo "${pTwo}" | sed "s/://");

   # the last part is to combine pOne+pTwo+Description+Date
   local k=""; local outrCt=1;
   local grpDsc=$(echo "${grpDsc}" | sed "s/ /.+./g");

   for dk in $(echo "${grpDsc}" | tr ',' '\n'); do
        local inrCnt=1;
        for k in $(echo "${pTwo}" | tr ':' '\n'); do
           if [ "${inrCnt}" -eq "${outrCt}" ]; then
                echo "${pOne}${k}|${dk}|${iDate}" >> "${grpFile}";
                sleep 1;
                printf "%b \n" "\tAdd: ${pOne}${k}|${dk}|${iDate}";
           fi

        inrCnt=$(($inrCnt + 1));
        done

   outrCt=$(($outrCt + 1));
   done
}

ui_pauseExit () {
   local entr=""; echo "";
   printf "%b \n" "\tPress Enter to continue ...\n";
   read entr; echo ""; return 1;
}

ini_DirCre () {
   local MMdir="${1}"; local MMcnt=1;
   echo "Directory Structure";
   for v in $(echo "${MMdir}" | tr ',' '\n') ; do

        if [ ! -d "${v}" ]; then
                mkdir -p "${v}";
                echo "\t${MMcnt}. Created: ${v}";
        else
                echo "\t${MMcnt}. Directory Exists: ${v}";
        fi

   MMcnt=$(($MMcnt + 1));
   done
}

#
##### Above this line aDilaog Install Process #####
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

   run_aDialog; #aDInstall.sh

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

checkITlog;
