#!/bin/bash
case `uname -s` in
    Darwin) 
           txtrst='\033[0m' # Color off
           txtbld='\033[1m' # Bold text
           txtred='\033[0;31m' # Red
           txtgrn='\033[0;32m' # Green
           txtblu='\033[0;34m' # Blue
	   txtwipe='\033[K' # Wipe entire line	
           ;;
    *)
           txtrst='\e[0m' # Color off
           txtbld='\e[1m' # Bold text
           txtred='\e[1;31m' # Red
           txtgrn='\e[1;32m' # Green
           txtblu='\e[1;36m' # Blue
	   txtwipe='\e[K' # Wipe entire line	
           ;;
esac

LOG=error.log
MAIN_DEVICE=razor
PYTHON=python2

rm -f $LOG
exec 2>> $LOG

mkdir -p $PWD/.cache

check_zip () {
echo -e "${txtblu}Checking zip${txtrst}"
if [ -e .cache/ROM/system/build.prop ]; then
	diff .cache/system/build.prop .cache/ROM/system/build.prop > .cache/zip.result
	if [ -s .cache/zip.result ]; then
		echo -e "${txtblu}Specified zip differs from current zip${txtrst}"
                extract_zip
        fi
else
     	extract_zip               
fi
}

extract_zip () {
if [ -d .cache ]; then
     	rm -rf .cache
fi

mkdir -p .cache/ROM

if [ -e $ZIP ]; then
     	cp $ZIP .cache/ROM/$ZIP
else
     	echo "Error: $ZIP not found"; exit
fi

echo -e "${txtblu}Extracting zip${txtrst}: $ZIP"
cd .cache/ROM; unzip -q $ZIP system/app/*.apk system/framework/*.apk system/priv-app/*.apk system/build.prop; cd ../..

tools/apktool if .cache/ROM/system/framework/framework-res.apk
}

extract_xmls () {
I=0
TOTAL=$(wc -l $TARGET_FILE | cut -d' ' -f1)
cat $TARGET_FILE | while read all_line; do
        I=$(expr $I + 1)
        PERCENT=$(echo "scale=2; $I/$TOTAL*100" | bc)
    	if [ -e .cache/ROM/system/app/$all_line ]; then
                echo -e "${txtblu}\nExtracting "$all_line" ${txtrst}: $PERCENT/100.00%"
    		tools/apktool d -f .cache/ROM/system/app/$all_line -o .cache/apk_wip
    		mkdir -p AOSP/$TARGET_DIR/$all_line/res/values$ISO
    		if [ -e .cache/apk_wip/res/values$ISO/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/strings.xml > .cache/apk_wip/res/values$ISO/strings.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/strings.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/arrays.xml > .cache/apk_wip/res/values$ISO/arrays.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/arrays.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/plurals.xml > .cache/apk_wip/res/values$ISO/plurals.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/plurals.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
    	elif [ -e .cache/ROM/system/priv-app/$all_line ]; then
                echo -e "${txtblu}\nExtracting "$all_line" ${txtrst}: $PERCENT/100.00%"
    		tools/apktool d -f .cache/ROM/system/priv-app/$all_line -o .cache/apk_wip
    		mkdir -p AOSP/$TARGET_DIR/$all_line/res/values$ISO
    		if [ -e .cache/apk_wip/res/values$ISO/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/strings.xml > .cache/apk_wip/res/values$ISO/strings.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/strings.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/arrays.xml > .cache/apk_wip/res/values$ISO/arrays.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/arrays.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/plurals.xml > .cache/apk_wip/res/values$ISO/plurals.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/plurals.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
    	elif [ -e .cache/ROM/system/framework/$all_line ]; then
                echo -e "${txtblu}\nExtracting "$all_line" ${txtrst}: $PERCENT/100.00%"
    		tools/apktool d -f .cache/ROM/system/framework/$all_line -o .cache/apk_wip
    		mkdir -p AOSP/$TARGET_DIR/$all_line/res/values$ISO_FW
		mkdir -p AOSP/$TARGET_DIR/$all_line/res/values$ISO
    		if [ -e .cache/apk_wip/res/values$ISO_FW/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO_FW/strings.xml > .cache/apk_wip/res/values$ISO_FW/strings.xml.new
			if [ -e .cache/apk_wip/res/values$ISO_FW/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO_FW/strings.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO_FW/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO_FW/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO_FW/arrays.xml > .cache/apk_wip/res/values$ISO_FW/arrays.xml.new
			if [ -e .cache/apk_wip/res/values$ISO_FW/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO_FW/arrays.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO_FW/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO_FW/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO_FW/plurals.xml > .cache/apk_wip/res/values$ISO_FW/plurals.xml.new
			if [ -e .cache/apk_wip/res/values$ISO_FW/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO_FW/plurals.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO_FW/plurals.xml
			fi
    		fi

    		if [ -e .cache/apk_wip/res/values$ISO/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/strings.xml > .cache/apk_wip/res/values$ISO/strings.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/strings.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/arrays.xml > .cache/apk_wip/res/values$ISO/arrays.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/arrays.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values$ISO/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values$ISO/plurals.xml > .cache/apk_wip/res/values$ISO/plurals.xml.new
			if [ -e .cache/apk_wip/res/values$ISO/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values$ISO/plurals.xml.new AOSP/$TARGET_DIR/$all_line/res/values$ISO/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
	fi
done
$PYTHON tools/sort.py AOSP/$TARGET_DIR
echo -e "${txtgrn}Extracted $TARGET_NAME XML's${txtrst}"
}

extract_xmls_all () {
I=0
TOTAL=$(wc -l $TARGET_FILE | cut -d' ' -f1)
cat $TARGET_FILE | while read all_line; do
        I=$(expr $I + 1)
        PERCENT=$(echo "scale=2; $I/$TOTAL*100" | bc)
	APK=$all_line
    	if [ -e .cache/ROM/system/app/$APK ]; then
                echo -e "${txtblu}\nExtracting "$APK" ${txtrst}: $PERCENT/100.00%"
    		tools/apktool d -f .cache/ROM/system/app/$APK -o .cache/apk_wip
    		mkdir -p AOSP/$TARGET_DIR/$APK/res/values
		cd .cache/apk_wip
   		find -iname "strings.xml" >> xml_targets
   		find -iname "plurals.xml" >> xml_targets
   		find -iname "arrays.xml" >> xml_targets
		cd ../..
		if [ -s .cache/apk_wip/xml_targets ]; then
			cat .cache/apk_wip/xml_targets | while read all_line; do
				BASE_NAME=$(basename $all_line)
				DIR_NAME=$(dirname $all_line | cut -d'.' -f2)
				mkdir -p AOSP/$TARGET_DIR/"$APK""$DIR_NAME"
				cp .cache/apk_wip"$DIR_NAME"/$BASE_NAME AOSP/$TARGET_DIR/"$APK""$DIR_NAME"/$BASE_NAME
			done
		fi
		echo -en "\r${txtwipe}"
    	elif [ -e .cache/ROM/system/priv-app/$APK ]; then
                echo -e "${txtblu}\nExtracting "$APK" ${txtrst}: $PERCENT/100.00%"
    		tools/apktool d -f .cache/ROM/system/priv-app/$APK -o .cache/apk_wip
    		mkdir -p AOSP/$TARGET_DIR/$APK/res/values
		cd .cache/apk_wip
   		find -iname "strings.xml" >> xml_targets
   		find -iname "plurals.xml" >> xml_targets
   		find -iname "arrays.xml" >> xml_targets
		cd ../..
		if [ -s .cache/apk_wip/xml_targets ]; then
			cat .cache/apk_wip/xml_targets | while read all_line; do
				BASE_NAME=$(basename $all_line)
				DIR_NAME=$(dirname $all_line | cut -d'.' -f2)
				mkdir -p AOSP/$TARGET_DIR/"$APK""$DIR_NAME"
				cp .cache/apk_wip"$DIR_NAME"/$BASE_NAME AOSP/$TARGET_DIR/"$APK""$DIR_NAME"/$BASE_NAME
			done
		fi
		echo -en "\r${txtwipe}"
    	elif [ -e .cache/ROM/system/framework/$APK ]; then
                echo -e "${txtblu}\nExtracting "$APK" ${txtrst}: $PERCENT/100.00%"
    		tools/apktool d -f .cache/ROM/system/framework/$APK -o .cache/apk_wip
    		mkdir -p AOSP/$TARGET_DIR/$APK/res/values
		cd .cache/apk_wip
   		find -iname "strings.xml" >> xml_targets
   		find -iname "plurals.xml" >> xml_targets
   		find -iname "arrays.xml" >> xml_targets
		cd ../..
		if [ -s .cache/apk_wip/xml_targets ]; then
			cat .cache/apk_wip/xml_targets | while read all_line; do
				BASE_NAME=$(basename $all_line)
				DIR_NAME=$(dirname $all_line | cut -d'.' -f2)
				mkdir -p AOSP/$TARGET_DIR/"$APK""$DIR_NAME"
				cp .cache/apk_wip"$DIR_NAME"/$BASE_NAME AOSP/$TARGET_DIR/"$APK""$DIR_NAME"/$BASE_NAME
			done
		fi
		echo -en "\r${txtwipe}"
	fi
done
$PYTHON tools/sort.py AOSP/$TARGET_DIR
echo -e "${txtgrn}Extracted $TARGET_NAME XML's${txtrst}"
}

start_extract_main_xmls () {
# Detect device
echo -e "${txtblu}Detecting device${txtrst}"
rm -rf system .cache/system
unzip -q $ZIP system/build.prop; mv system .cache/system
TARGET=$(grep ''ro.product.name'=' .cache/system/build.prop | cut -d"=" -f2)
if [ $TARGET == $MAIN_DEVICE ]; then
	check_zip
	TARGET_FILE="targets/aosp.apks"
	TARGET_DIR="main"
	TARGET_NAME="main"
	if [ "$ISO" == "all" ]; then
		extract_xmls_all
	else
		extract_xmls
	fi
else
	echo -e "${txtred}Device not a main device${txtrst}: $TARGET"; exit
fi  
}

start_extract_device_xmls () {
# Detect device
echo -e "${txtblu}Detecting device${txtrst}"
rm -rf system .cache/system
unzip -q $ZIP system/build.prop; mv system .cache/system
TARGET=$(grep ''ro.product.name'=' .cache/system/build.prop | cut -d"=" -f2)
if [ -e targets/$TARGET.apks ]; then
	check_zip
	TARGET_FILE=targets/$TARGET.apks
	TARGET_DIR=device/$TARGET
	TARGET_NAME=$TARGET
       	extract_xmls
else
	echo -e "${txtred}Device not supported${txtrst}: $TARGET"; exit
fi  
}

show_argument_help () { 
echo 
echo "Android XMLS extracter"
echo 
echo "Usage: extract.sh [--main|--device][--zip][zip_name]"
echo 
echo " [option]:"
echo " 		--help		-h		This help"
echo "		--main,	 	--zip		Extract main xmls from specified zip"
echo "		--device,	--zip		Extract device xmls from specified zip"
echo 
exit 
}

if [ $# -gt 0 ]; then
     	if [ $1 == "--help" ]; then
          	show_argument_help
	elif [ $1 == "--main" ]; then
                if [ "$2" != "" ]; then
     			if [ "$2" == "--zip" ] || [ $2 == "-z" ]; then
          			if [ -e $3 ]; then
               				ZIP=$3
          			else
               				echo "${txtred}WARNING:${txtrst} zip not specified or not found: aborting"; sleep 1
               		    		exit
          			fi
          			ISO=$4
				ISO_FW=$4
			fi
                else 
               		echo -e "zip not specified or not found, using default: update.zip"; sleep 1
               		ZIP=update.zip
                fi
                start_extract_main_xmls
	elif [ $1 == "--device" ]; then
                if [ "$2" != "" ]; then
     			if [ "$2" == "--zip" ] || [ $2 == "-z" ]; then
          			if [ -e $3 ]; then
               				ZIP=$3
          			else
               				echo "${txtred}WARNING:${txtrst} zip not specified or not found: aborting"; sleep 1
               		    		exit
          			fi
          			ISO=$4
				ISO_FW=$5
			fi
                else 
               		echo -e "zip not specified or not found, using default: update.zip"; sleep 1
               		ZIP=update.zip
                fi
                start_extract_device_xmls
	else
                show_argument_help
      	fi
fi
