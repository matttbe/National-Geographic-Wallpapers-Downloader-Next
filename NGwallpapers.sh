#!/bin/bash

###########################################################
### NGwallpapers.sh by Matthieu Baerts (matttbe)
### (A fork of NGwallpapers by Morgan LEFIEUX)
### v0.1
### This file is under a GNU/GPLv3 licence
### http://www.gnu.org/licenses/
###########################################################

YEAR=$1
shift
MONTH_LIST=$@

MONTHS=( "1:january" "2:february" "3:march" "4:april" "5:may" "6:june" "7:july" "8:august" "9:september" "10:october" "11:november" "12:december" )
TMP="NGwallpapers_tmpfile"
BASE_NG="http://ngm.nationalgeographic.com"
NG_DIR="NGwallpapers"
MONTH=""

NORMAL="\\033[0;39m"
BLUE="\\033[1;34m"
GREEN="\\033[1;32m"
RED="\\033[1;31m"

if test ! -n "$YEAR" -a ! -n "$MONTH"; then
	echo -e "$BLUE""To download pictures of (a) specific month(s), use this command"
	echo -e "\t./NGwallpapers.sh 2011 10"
	echo -e "\t./NGwallpapers.sh 2011 10 11 12"
	echo -e "Press Enter to continue (Ctrl+C to stop)\n""$NORMAL"
	read
fi

test_month () {
	MONTH=$1
	if test $MONTH -gt 12 -o $YEAR -eq 2011 -a $MONTH -lt 10; then # $MONTH -gt `date +%m` -o  # works with the next MONTH...
		MONTH=`date +%m`
		echo -e "$RED""Wrong month, min 10/2011 (replaced by $MONTH)\n""$NORMAL"
	fi
	if test `echo $MONTH |wc -m` -eq 2; then
		MONTH="0$MONTH"
	fi
}

test_init () {
	if test ! -n "$YEAR"; then
		YEAR=`date +%Y`
		echo -e "$GREEN""We use the current year: $YEAR""$NORMAL"
	fi
	if test $YEAR -lt 2011 -o $YEAR -gt `date +%Y`; then
		YEAR=`date +%Y`
		echo -e "$RED""Wrong year, min 2011, max today (replaced by $YEAR)""$NORMAL"
	fi
	if test ! -n "$MONTH_LIST"; then
		MONTH_LIST=`date +%m`
		echo -e "$GREEN""We use the current month: $MONTH_LIST\n""$NORMAL"
	fi
}

download_month () {
	echo -e "$BLUE""Download wallpapers' list for $1 $YEAR\n""$NORMAL"
	wget -q $BASE_NG/wallpaper/$YEAR/$1-ngm-wallpaper -O $TMP
	WALL=`grep "_1600.jpg" $TMP |grep "Download" |grep $YEAR |grep $2 |cut -d\" -f2`
	rm -f $TMP
	for file in $WALL; do
		PICTURE="`echo $file |cut -d/ -f6`"
		SAVED_TO="$NG_DIR/$YEAR-$2-$PICTURE"
		if test -f "$SAVED_TO"; then
			echo -e "$RED""We already have this file: $PICTURE""$NORMAL"
		else
			echo -e "$GREEN""Downloading this picture: ""$BLUE""$PICTURE""$NORMAL"
			wget -q "$BASE_NG""$file" -O "$SAVED_TO"
		fi
	done
	echo
}

mkdir -p $NG_DIR

test_init

for i in $MONTH_LIST; do
	test_month $i
	MONTH_NAME=${MONTHS[$(($MONTH-1))]##*:} ## why -1 ?
	# MONTH_NUM=${MONTHS[$MONTH]%%:*}
	download_month $MONTH_NAME $MONTH
done

echo -e "$GREEN""Done! Please have a look to this directory: $NG_DIR""$NORMAL"
exit 0
