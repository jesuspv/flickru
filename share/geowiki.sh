#!/usr/bin/env bash

###########
# Globals #
###########

APP_NAME=`basename $0`
PAGE=`echo "$1" | tr ' ' '_'`

#############
# Functions #
#############

function usage() {
   echo "$APP_NAME - find coordinates of a place described by Wikipedia"
   echo "usage: $APP_NAME <place Wikipedia page>"
   echo "example: $APP_NAME 'Mille-Isles, Quebec'"
}

function error() {
   echo -e "\033[31m$APP_NAME:$1: $2\033[0m" 1>&2
}

#################
# Preconditions #
#################

if ! `hash wget 2> /dev/null`; then
   error $LINENO "wget command not found"
   exit 1
fi

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
   usage
   exit
elif [[ $# -ne 1 ]]; then
   usage
   error $LINENO "wrong number of arguments"
   exit 1
fi

#########
# Setup #
#########

# temporal file management
if [[ -d /tmp ]]; then
   TMP="/tmp/$PAGE.tmp.$$.$RANDOM.html"
else
   TMP="$PAGE.tmp.html"
fi
function clean_up() {
        rm -f "$TMP"
        exit $1
}
trap clean_up SIGHUP SIGINT SIGTERM

########
# Main #
########

wget -o /dev/null -O "$TMP" "https://en.wikipedia.org/wiki/$PAGE"

   if [[ $? -ne 0 ]]; then
      error $LINENO "Wikipedia page '$PAGE' not found"
      clean_up 1
   fi

URL=`cat "$TMP" | tr '"' '\n' | grep geohack | head -n 1 | sed -e 's|^//||' -e 's|&amp;|\&|'`

   if [[ -z "$URL" ]]; then
      error $LINENO "location not found in Wikipedia page '$PAGE'"
      clean_up 1
   fi

curl "$URL" -o "$TMP" 2> /dev/null

   if [[ $? -ne 0 ]]; then
      error $LINENO "GeoHack URL '$URL' not found"
      clean_up 1
   fi

cat "$TMP" | grep '<span class="geo"' \
| sed -e 's|^.*"Latitude">\([^<]*\)</span>, .*"Longitude">\([^<]*\)</span>.*$|\1, \2|'

clean_up
