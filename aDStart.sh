#!/bin/sh
#
# aDStart.sh
#

ui_etwo () { echo ""; echo ""; clear; clear; echo ""; }

run_app () {
   # this is easy if working
   ui_etwo;

   # start evaluation
   #
local ckFile='/zTest/Demo/aDConfig.ahr';
   ini_eval "${ckFile}";

   if [ "${ckEval}" = "pass" ]; then
local RunAPP='/zTest/Demo/aDApp.sh';
      sh "${RunAPP}";
   fi

}

ini_eval () {
   # Expecting a file to evaluate
   # the grep 'ini=' is hard coded to prevent accidental use
   #
   local mText=""; local mSrc="";
   local k=""; local v=""; local gStr="";
   local mEQ=""; local fName=$1; ckEval="";

   if [ -f "${fName}" ]; then

      # create index and extract -f2
      mText=$(cat "${fName}");
      gStr=$(echo "${mText}" | grep 'loc=' | cut -d'|' -f2);
      gStr=$(echo "${gStr}" | cut -d'=' -f2);

      # establish a foreach group
      for k in $(echo "${gStr}" | tr ',' '\n'); do

         # a matched k
         for mSrc in $(echo "${mText}" | cut -d'|' -f3); do
            mEQ=$(echo "${mSrc}" | cut -d'=' -f1);
            if [ "${mEQ}" = "${k}" ]; then
               # echo "Matched: ${mSrc}";
               # note the key value in loc
               v=$(echo "${mSrc}" | cut -d'=' -f2);
               eval $(echo "$k=$v");

               if [ "${v}" = "$(echo $(pwd))" ]; then
                        ckEval="pass";
               fi
            fi
         done
      done

   else
        echo "Failed evaluation! [file aDStart.sh] function [ini_eval]";
        exit 1;
   fi

}

ini_Dialog () {
   # the grep 'mma=' is hard coded to prevent accidental use
   # example and prior test function
   local mText=""; local mSrc="";
   local k=""; local v=""; local gStr="";
   local mEQ=""; local fName=$1; ckEval="";

   if [ -f "${fName}" ]; then
      # the point is mma=
      mText=$(cat "${fName}");
      gStr=$(echo "${mText}" | grep 'mma=' | cut -d'|' -f2);
      gStr=$(echo "${gStr}" | cut -d'=' -f2);

      # establish a foreach group
      for k in $(echo "${gStr}" | tr ',' '\n'); do

         # a matched k in a config file
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

run_app;
