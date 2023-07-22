#!/bin/sh
#
# Physical Network Interfaces PNI
#

pmi4Reindex () {
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

delGRPrecords () {
   # expects file pattern
   local inFle="${1}"; local patt="${2}";

   # create tmp file
   tpFle=$(echo "${inFle}" | sed -e "s:.bak:.tmp:");
   touch "${tpFle}";

   grep -v "${patt}" "${inFle}" > "${tpFle}";
   mv "${tpFle}" "${inFle}";
}

defaultLO () {
   local modWrt="${1}"; local bakFle="${2}";
   # prep a group header and content
   local lo4Header=""; local lo4Content=""; local vLine="";
   local lDate=$(date +"%Y%m%d%H%M%S");
   local LoDsc=$(getIFDsc "lo");
   vLine="Lo4=iL0,Lip0,LCidr0,LMask0,LGate0,LDNS0,LSrvc0,LPort0";
   Lo4Header="${vLine}|iL0=lo|${LoDsc}|${lDate}"

   local LSrc=$(echo "${vLine}" | cut -d',' -f1);
   local Sarr=$(echo "${vLine}" | sed "s/${LSrc},//");

   # description lib.
   local dDsc="";
   dDsc="Lo.+.IP0|Lo.+.CIDR0|Lo.+.Mask0";
   dDsc="${dDsc}|Lo.+.Gate0|Lo.+.DNS0";
   dDsc="${dDsc}|Lo.+.Sys.+.Service0|Lo.+.Sys.+.Port0";

   # content
   local Lcmd="";
   Lcmd=$(ip -br address show dev lo | xargs);
   Lcmd=$(echo "${Lcmd}" | sed "s/ /|/g");

   local LState=$(echo "${Lcmd}" | cut -d '|' -f2);
   local Lo4=$(echo "${Lcmd}" | cut -d '|' -f3);
   local Lip0=$(echo "${Lo4}" | cut -d '/' -f1);
   local LCidr0=$(echo "${Lo4}" | cut -d '/' -f2);
   local LMask0="";
   if [ -z "${LCidr0}" ]; then
	LMask0="";
   else
	LMask0=$(cdr2mask "${LCidr0}");
   fi

   # Sys Gateway
   LGate0=$(ip route | grep default | cut -d' ' -f3);

   # DNS Ubuntu Server 22.04 server
   LDNS0=$(resolvectl status lo);
   LDNS0=$(echo "${LDNS0}" | sed "s/ //g" | grep "CurrentDNSServer:");
   LDNS0=$(echo "${LDNS0}" | cut -d':' -f2);

   # sys related
   LSrvc0="AHR";
   LPort0="87021";

   if [ "${modWrt}" = "delete" ]; then
        # remove group
	delGRPrecords "${bakFle}" "${LSrc}";
        ###sed -i "/${LSrc}/d" "${bakFle}";

        # remove empty lines
        sed '/^\s*$/d' "${bakFle}";

   fi

   if [ "${modWrt}" = "write" ]; then
	echo "${Lo4Header}" >> "${bakFle}";
	local kv=""; local k=""; local v="";
	local dr=""; local c=1; local Lr="";

	for kv in $(echo "${Sarr}" | tr ',' '\n'); do
	   dr=$(echo "${dDsc}" | cut -d'|' -f"${c}");
	   k=$(echo "${kv}");
	   v=$(eval echo \${$kv});
	   Lr="${vLine}|${k}=${v}|${dr}|${lDate}"
	   echo "${Lr}" >> "${bakFle}";

	c=$(($c + 1));
	done
   fi
}


PNIcfgWriter () {
   local pcw="${1}"; local pkv="${2}"; local src="";
   local pcDate=$(date +"%Y%m%d%H%M%S");
   # create backup file
   local fBak=$(echo "${DMMini}" | sed -e "s:.ahr:.bak:");
   if [ -f "${fBak}" ]; then
	rm "${fBak}";
	sleep 1;
	touch "${fBak}";
   else
	touch "${fBak}";
   fi

   # create tmp config var
   tCfg=$(cat "${DMMini}");

   # formulate record search string
   src=$(echo "${pcw}" | cut -d',' -f4);

   # remove index field and update backup file
   local ndx=""; local br=""; local ck=""; local n=1;

   for ndx in $(echo "${tCfg}"); do
	ck=$(echo "ndx" | cut -d'|' -f2);
	if [ "$src" = "$ck" ]; then
		n=$(($n + 1));
	fi
	br=$(echo "${ndx}" | cut -d'|' -f2,3,4,5);
	echo "${br}" >> "${fBak}";
   done
   # prepare records
   local hdr=""; local dsc="";
   local en=""; local den="";
   hdr="${src},inet0,Cidr0,Mask0,Gate0,DNS0,Srvc0,Port0";
   en=$(echo "${pcw}" | cut -d',' -f1);
   den=$(echo "${pcw}" | cut -d',' -f3);

   # description content lib
   dsc="PNI.+.IP0|PNI.+.CIDR0|PNI.+.Mask0";
   dsc="${dsc}|PNI.+.Gate0|PNI.+.DNS0";
   dsc="${dsc}|PNI.+.Sys.+.Service0|PNI.+.Sys.+.Port0";

   # delete first, if records found
   if [ "${n}" -gt 0 ]; then
	defaultLO "delete" "${fBak}";

	# remove group
	delGRPrecords "${fBak}" "${src}";
   fi

   # write header and content
   local ak=""; local ar=""; local an=1;
   echo "${hdr}|Nme0=${en}|${den}|${pcDate}" >> "${fBak}";
   for ak in $(echo "${pkv}" | tr '|' '\n'); do
	ar=$(echo "${dsc}" | cut -d'|' -f"${an}");
	echo "${hdr}|${ak}|${ar}|${pcDate}" >> "${fBak}";
   an=$(($an + 1));
   done
   # write default
   defaultLO "write" "${fBak}";

   # move and reindex
   mv "${fBak}" "${DMMini}";

   pmi4Reindex "${DMMini}";
}

PNIinfo () {
   local selPNI="${1}"; local hlp="";
   hlp=$(printf "%b \n" "\n\n");
   hlp=$(printf "%b \n" "${hlp}PNI Selected: ${selPNI}\n\n");
   hlp=$(printf "%b \n" "${hlp}Virtual or Wireless Interfaces are not covered:\n\n");

   hlp=$(printf "%b \n" "${hlp}Example: \n");
   hlp=$(printf "%b \n" "${hlp}- ‘lo’ is a reserved name for internal applications\n\n");

   hlp=$(printf "%b \n" "${hlp}Please use a wired PNI for configuration\n\n");

   hlp=$(printf "%b \n" "${hlp}Data collected by this code is saved");
   hlp=$(printf "%b \n" "${hlp}in file: ${DMMini}\n\n");
   hlp=$(printf "%b \n" "${hlp}This will further help to configure");
   hlp=$(printf "%b \n" "${hlp} a static and persistent network script");


   pHLP="${pHLP=dialog}"; # w/o do while button/case

   Pmsg=$("${pHLP}" --stdout \
        --title "Physical Network Interfaces PNI" \
        --backtitle "Net Experiment" \
        --msgbox "${hlp}" 20 64);

   # pPbtn="$?"; # is 0 echo "B: ${pPbtn}";
}

ShowPNIform () {
   local ain="${1}"; local sv="";
   local key=""; local val="";

   for sv in $(echo "${ain}" | tr '|' '\n'); do
	key=$(echo "${sv}" | cut -d':' -f1);
	val=$(echo "${sv}" | cut -d':' -f2);
	eval "$key=$val";
   done

   CCR="${CCR=dialog}"; # w/o do while button/case

   frmPNI=$("${CCR}" --stdout \
   --title "Physical Network Interfaces PNI" \
   --backtitle "Net Experiment" \
   --ok-label "SAVE" \
   --form "Create Configuration Record: ${Nme0} ${State} ${Ddsc}" 16 64 10 \
	"Header(DO Not Change)" 1 1 "${Nme0},${State},${Ddsc}" 1 25 25 0 \
	"IP inet:" 2 1 "${inet0}" 2 25 25 0 \
	"CIDR:" 3 1 "${Cidr0}" 3 25 25 0 \
	"Mask:" 4 1 "${Mask0}" 4 25 25 0 \
	"Sys-Gateway:" 5 1 "${Gate0}" 5 25 25 0 \
	"Sys-DNS-cdf:" 6 1 "${DNS0}" 6 25 25 0 \
	"Sys-Service:" 7 1 "${Srvc0}" 7 25 25 0 \
	"Sys-Port:" 8 1 "${Port0}" 8 25 25 0);

   local pniForm=""; local sl=""; local See="";
   local pniData=""; local SFld=""; local sSub=""; 
   local kAry=""; local kF="";
   if [ ! -z "${frmPNI}" ]; then
        for sl in "${frmPNI}"; do
           pniForm=$(echo "${sl}" | tr '\n' '|');
        done
	# remove last occurance
	pniForm=$(echo "${pniForm}" | sed "s/|$//");

	# show other prompts if virtual or wireless
	See=$(echo "${Nme0},${State},${Ddsc}" | sed "s/ //g");
	SFld=$(echo "${pniForm}" | cut -d'|' -f1 | sed "s/ //g");
	sSub=$(echo "${Nme0}" | awk '{print substr($0,1,2)}');

	if [ "$See" != "$SFld" ] || [ "$sSub" != "en" ]; then
	   PNIinfo "${Nme0},${State},${Ddsc},${sSub}";
	   return 1; # back to pni-loop
	fi
	# Strip header data from content
	pniData=$(echo "${pniForm}" | sed "s/${See}|//");

        # add the form k v to string
        local vF=""; local pniKV="";
	local y=1; local x=1;
        kAry="inet0,Cidr0,Mask0,Gate0,DNS0,Srvc0,Port0";
        for kF in $(echo "${kAry}" | tr ',' '\n'); do
	   y=1;
           for vF in $(echo "${pniData}" | tr '|' '\n'); do
		if [ "${x}" -eq "${y}" ]; then
                   pniKV=$(echo "${pniKV}${kF}"="${vF}|");
		fi
	   y=$(($y + 1));
           done
	x=$(($x + 1));
        done
	# remove last occurance
	pniKV=$(echo "${pniKV}" | sed "s/|$//");

	# either one should work but prefer
	# orig Head(See) rather than(SFld)
	# concluding a step by step process to REM
	# a config writer
	See="${See},pni4=Nme0";
	PNIcfgWriter "${See}" "${pniKV}";
   fi
}

mask2cdr () {
   # Assumes there's no "255." after a non-255 byte in the mask
   local x=${1##*255.}
   set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
   x=${1%%$3*}
   echo $(( $2 + (${#x}/4) ))
}

cdr2mask () {
   # Number of args to shift, 255..255, first non-255 byte, zeroes
   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift
   echo ${1-0}.${2-0}.${3-0}.${4-0}
}

PNIdevice () {
   local Dnme="${1}";
   local Ddsc=$(getIFDsc "${Dnme}");
   local Drz="";

   # use --brief or -br
   Drz=$(printf "%b \n" $(ip -br address show dev "${Dnme}" | xargs));
   Drz=$(echo "${Drz}" | tr '\n' '|' | sed "s/ //g");

   # remove last occurrence
   Drz=$(echo "${Drz}" | sed "s/|$//");

   # definition: Group-Header, Group-Data
   local Nme0=""; local inet0="";
   local Cidr0=""; local Mask0=""; local Gate0="";
   local DNS0=""; local Srvc0="AHR"; local Port0="87021";

   Group="pmi4";
   Nme0="${Dnme}";
   State=$(echo "${Drz}" | cut -d '|' -f2);
   aIP=$(echo "${Drz}" | cut -d '|' -f3);
   inet0=$(echo "${aIP}" | cut -d '/' -f1);
   Cidr0=$(echo "${aIP}" | cut -d '/' -f2);
   if [ -z "${Cidr0}" ]; then
	Mask0="";
   else
	Mask0=$(cdr2mask "${Cidr0}");
   fi

   Gate0=$(ip route | grep default | cut -d' ' -f3);

   # DNS Ubuntu Server 22.04 server
   DNS0=$(resolvectl status "${Dnme}");
   DNS0=$(echo "${DNS0}" | sed "s/ //g" | grep "CurrentDNSServer:");
   DNS0=$(echo "${DNS0}" | cut -d':' -f2);

   local dArr="Group,Ddsc,State,Nme0,inet0,Cidr0,Mask0,Gate0,DNS0,Srvc0,Port0";
   local rw=""; local k=""; local v="";

   for rw in $(echo "${dArr}" | tr ',' '\n'); do
	k=$(echo "${rw}");
	v=$(eval echo \${$k});
	snd="${snd}${k}:${v}|";
   done

   ShowPNIform "${snd}";
}

ui_pauseExit () {
   local entr=""; echo "";
   printf "%b \n" "\n\tPress Enter to continue ...";
   read entr; echo ""; return 1;
}

getIFDsc () {
   local nif="${1}"; local libD=""; local Sub="";
   local gd=""; local ds="";
   libD="en=Ethernet-Wired|wl=WLAN-Wireless|";
   libD="${libD}ww=WWAN-WirelessWide|lo=Loopback-Virtual-Interface";

   Sub=$(echo "${nif}" | awk '{print substr($0,1,2)}');
   for gd in $(echo "${libD}" | tr '|' '\n'); do
        ds=$(echo "${gd}" | cut -d'=' -f1);
        gd=$(echo "${gd}" | cut -d'=' -f2);
        if [ "${ds}" = "${Sub}" ]; then
           echo "${gd}";
        fi
   done
}

listPNI () {
   local NicD=""; local nd=""; local Qd=""; local Dr="";
   local Dbutton=""; local Dpni="";
   NicD=$(ls /sys/class/net);
   for nd in $(echo "${NicD}" | tr ' ' '\n'); do
	Qd=$(getIFDsc "${nd}");
	Dr=$(printf "%b \n" "${Dr} \n${nd}\t\t${Qd}");
	Dr=$(echo "${Dr}" | sed "s/ $//");
   done

   while true ; do
	DBOX="${DBOX=dialog}"; #quotes here will do while button/case

	Dpni=$("${DBOX}" --clear --stdout \
	--title "Physical Network Interfaces PNI" \
	--backtitle "Net Experiment" \
	--menu "Select-PNI with arrow-keys -- Confirm with space-bar/enter -- Exit with Cancel/ESC/Ctrl-C" \
	32 64 16 $(echo "${Dr}"));

	Dbutton="$?";
	case "${Dbutton}" in
	   0)
		# get details via PNIdevice
		PNIdevice "${Dpni}";
	   ;;
	   1) return 1;; # Cancel pressed
	   255) return 1;; # ESC pressed
	esac
   done
   clear;
}

listPNI;
