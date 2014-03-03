#!/bin/bash
# Copyright (c) 2014, Jake van der Putten (Redmaner)

case `uname -s` in
    Darwin) 
           txtrst='\033[0m' # Color off
           txtbld='\033[1m' # Bold text
           txtred='\033[0;31m' # Red
           txtblu='\033[0;34m' # Blue
           ;;
    *)
           txtrst='\e[0m' # Color off
           txtbld='\e[1m' # Bold text
           txtred='\e[1;31m' # Red
           txtblu='\e[1;36m' # Blue
           ;;
esac

merge_xml () {
mkdir -p merged_xml/$LANG/$APK
NEW_STRINGS=merged_xml/$LANG/$APK/strings.txt
rm -f $NEW_STRINGS; touch $NEW_STRINGS
NEEDS_TRANSLATION=merged_xml/$LANG/$APK/needs_translation.txt
rm -f $NEEDS_TRANSLATION
cp $ORIGINAL_STRINGS $NEW_STRINGS.orig.xml
echo -e "${txtblu}\nMerging $APK${txtrst}"
cat $ORIGINAL_STRINGS | while read all_line; do
	TARGET_LINE_STRIPPED=$(echo "$all_line" | grep "<string" | cut -d'>' -f1)
	if [ "$TARGET_LINE_STRIPPED" != "" ]; then
		if [ $(grep "$TARGET_LINE_STRIPPED" $TARGET_STRINGS | wc -l) -gt 0 ]; then
			NEW_LINE_NR=$(cat $TARGET_STRINGS | grep -ne "$TARGET_LINE_STRIPPED" | cut -d':' -f1)
			sed -n "$NEW_LINE_NR"p $TARGET_STRINGS
		else
			echo "$all_line"
			echo "$all_line" >> $NEEDS_TRANSLATION
		fi
	else
		echo "$all_line"
	fi
done > $NEW_STRINGS
xmllint --encode UTF-8 $NEW_STRINGS -o merged_xml/$LANG/$APK/strings.xml
}

needs_translation () {
mkdir -p compared_xml/$LANG/$APK
NEEDS_TRANSLATION=compared_xml/$LANG/$APK/needs_translation.txt
rm -f $NEEDS_TRANSLATION
echo -e "${txtblu}\nChecking $APK for new strings${txtrst}"
cat $ORIGINAL_STRINGS | while read all_line; do
	TARGET_LINE_STRIPPED=$(echo "$all_line" | grep "<string" | cut -d'>' -f1)
	if [ "$TARGET_LINE_STRIPPED" != "" ]; then
		if [ $(grep "$TARGET_LINE_STRIPPED" $TARGET_STRINGS | wc -l) == 0 ]; then
			echo "$all_line" >> $NEEDS_TRANSLATION
		fi
	fi
done
}

needs_removal () {
mkdir -p compared_xml/$LANG/$APK
NEEDS_REMOVAL=compared_xml/$LANG/$APK/needs_removal.txt
rm -f $NEEDS_REMOVAL
echo -e "${txtblu}Checking $APK for old strings${txtrst}"
cat $TARGET_STRINGS | while read all_line; do
	TARGET_LINE_STRIPPED=$(echo "$all_line" | grep "<string" | cut -d'>' -f1)
	if [ "$TARGET_LINE_STRIPPED" != "" ]; then
		if [ $(grep "$TARGET_LINE_STRIPPED" $ORIGINAL_STRINGS | wc -l) == 0 ]; then
			echo "$all_line" >> $NEEDS_REMOVAL
		fi
	fi
done
}

ORIGINAL_STRINGS=$1
TARGET_STRINGS=$2
APK=$3
LANG=$4

if [ -e $ORIG_PATH ]; then
	if [ -e $TARGET_PATH ]; then
		needs_translation
		needs_removal
	fi
fi
