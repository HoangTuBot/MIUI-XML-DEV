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
MAIN_DEVICE=aries

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
     	echo "Error: no $ZIP found"; exit
fi

echo -e "${txtblu}Extracting zip${txtrst}: $ZIP"
cd .cache/ROM; unzip -q $ZIP system/app/*.apk system/framework/*.apk system/build.prop; cd ../..

tools/apktool if .cache/ROM/system/framework/framework-res.apk
tools/apktool if .cache/ROM/system/framework/framework-miui-res.apk
}

extract_xmls_main () {
I=0
TOTAL=$(wc -l targets/main.apks | cut -d' ' -f1)
cat targets/main.apks | while read all_line; do
        I=$(expr $I + 1)
        PERCENT=$(echo "scale=2; $I/$TOTAL*100" | bc)
    	if [ -e .cache/ROM/system/app/$all_line ]; then
                echo -en "${txtblu}Extracting main XML's${txtrst}: $PERCENT%\r"
    		echo >> $LOG; echo "Extracting $all_line" >> $LOG
    		tools/apktool d -f .cache/ROM/system/app/$all_line .cache/apk_wip
    		mkdir -p Dev/main/$all_line/res/values
    		if [ -e .cache/apk_wip/res/values/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/strings.xml > .cache/apk_wip/res/values/strings.xml.new
			if [ -e .cache/apk_wip/res/values/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values/strings.xml.new Dev/main/$all_line/res/values/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/arrays.xml > .cache/apk_wip/res/values/arrays.xml.new
			if [ -e .cache/apk_wip/res/values/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values/arrays.xml.new Dev/main/$all_line/res/values/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/plurals.xml > .cache/apk_wip/res/values/plurals.xml.new
			if [ -e .cache/apk_wip/res/values/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values/plurals.xml.new Dev/main/$all_line/res/values/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
    	elif [ -e .cache/ROM/system/framework/$all_line ]; then
                echo -en "${txtblu}Extracting main XML's${txtrst}: $PERCENT%\r"
    		echo >> $LOG; echo "Extracting $all_line" >> $LOG
    		tools/apktool d -f .cache/ROM/system/framework/$all_line .cache/apk_wip
    		mkdir -p Dev/main/$all_line/res/values
    		if [ -e .cache/apk_wip/res/values/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/strings.xml > .cache/apk_wip/res/values/strings.xml.new
			if [ -e .cache/apk_wip/res/values/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values/strings.xml.new Dev/main/$all_line/res/values/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/arrays.xml > .cache/apk_wip/res/values/arrays.xml.new
			if [ -e .cache/apk_wip/res/values/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values/arrays.xml.new Dev/main/$all_line/res/values/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/plurals.xml > .cache/apk_wip/res/values/plurals.xml.new
			if [ -e .cache/apk_wip/res/values/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values/plurals.xml.new Dev/main/$all_line/res/values/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
	fi
done
tools/sort.py Dev/main
echo -e "${txtgrn}Extracted main XML's${txtrst}"
}

extract_xmls_device () {
I=0
TOTAL=$(wc -l targets/$TARGET.apks | cut -d' ' -f1)
cat targets/$TARGET.apks | while read all_line; do
        I=$(expr $I + 1)
        PERCENT=$(echo "scale=2; $I/$TOTAL*100" | bc)
    	if [ -e .cache/ROM/system/app/$all_line ]; then
                echo -en "${txtblu}Extracting $TARGET XML's${txtrst}: $PERCENT%\r"
    		echo >> $LOG; echo "Extracting $all_line" >> $LOG
    		tools/apktool d -f .cache/ROM/system/app/$all_line .cache/apk_wip
    		mkdir -p Dev/device/$TARGET/$all_line/res/values
    		if [ -e .cache/apk_wip/res/values/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/strings.xml > .cache/apk_wip/res/values/strings.xml.new
			if [ -e .cache/apk_wip/res/values/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values/strings.xml.new Dev/device/$TARGET/$all_line/res/values/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/arrays.xml > .cache/apk_wip/res/values/arrays.xml.new
			if [ -e .cache/apk_wip/res/values/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values/arrays.xml.new Dev/device/$TARGET/$all_line/res/values/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/plurals.xml > .cache/apk_wip/res/values/plurals.xml.new
			if [ -e .cache/apk_wip/res/values/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values/plurals.xml.new Dev/device/$TARGET/$all_line/res/values/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
    	elif [ -e .cache/ROM/system/framework/$all_line ]; then
                echo -en "${txtblu}Extracting $TARGET XML's${txtrst}: $PERCENT%\r"
    		echo >> $LOG; echo "Extracting $all_line" >> $LOG
    		tools/apktool d -f .cache/ROM/system/framework/$all_line .cache/apk_wip
    		mkdir -p Dev/device/$TARGET/$all_line/res/values
    		if [ -e .cache/apk_wip/res/values/strings.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/strings.xml > .cache/apk_wip/res/values/strings.xml.new
			if [ -e .cache/apk_wip/res/values/strings.xml.new ]; then
         			cp .cache/apk_wip/res/values/strings.xml.new Dev/device/$TARGET/$all_line/res/values/strings.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/arrays.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/arrays.xml > .cache/apk_wip/res/values/arrays.xml.new
			if [ -e .cache/apk_wip/res/values/arrays.xml.new ]; then
         			cp .cache/apk_wip/res/values/arrays.xml.new Dev/device/$TARGET/$all_line/res/values/arrays.xml
			fi
    		fi
    		if [ -e .cache/apk_wip/res/values/plurals.xml ]; then
			grep -v ">@" .cache/apk_wip/res/values/plurals.xml > .cache/apk_wip/res/values/plurals.xml.new
			if [ -e .cache/apk_wip/res/values/plurals.xml.new ]; then
         			cp .cache/apk_wip/res/values/plurals.xml.new Dev/device/$TARGET/$all_line/res/values/plurals.xml
			fi
    		fi
		echo -en "\r${txtwipe}"
	fi
done
tools/sort.py Dev/device/$TARGET
echo -e "${txtgrn}Extracted $TARGET XML's${txtrst}"
}

start_extract_xmls () {
# Detect device
echo -e "${txtblu}Detecting device${txtrst}"
rm -rf system .cache/system
unzip -q $ZIP system/build.prop; mv system .cache/system
TARGET=$(grep ''ro.product.device'=' .cache/system/build.prop | cut -d"=" -f2)
if [ -e targets/$TARGET.apks ]; then
	check_zip
	if [ $TARGET == $MAIN_DEVICE ]; then
     		extract_xmls_main
        	extract_xmls_device
	else
        	extract_xmls_device
	fi 
else
	echo -e "${txtred}Device not supported${txtrst}: $TARGET"
	echo -e "Do you want to extract the main xmls?\n${txtred}WARNING:${txtrst} It's recommended to extract main xmls only from Xiaomi devices!"
        echo -n "(yes,no): "; read device_not_detected
     	case "$device_not_detected" in
               yes) extract_xmls_main; exit;;
		no) exit;;
        esac
fi  
}

show_argument_help () { 
echo 
echo "MIUIAndroid.com XMLS extracter"
echo 
echo "Usage: extract.sh --xmls --zip [zip_name]"
echo 
echo " [option]:"
echo " 		--help		-h			This help"
echo "		--xmls,		--zip			Extract xmls from specified zip"
echo 
exit 
}

if [ $# -gt 0 ]; then
     	if [ $1 == "--help" ]; then
          	show_argument_help
	elif [ $1 == "--xmls" ]; then
                if [ "$2" != "" ]; then
     			if [ "$2" == "--zip" ] || [ $2 == "-z" ]; then
          			if [ -e $3 ]; then
               				ZIP=$3
          			else
               				echo "${txtred}WARNING:${txtrst} zip not specified or not found: aborting"; sleep 1
               		    		exit
          			fi
			fi

                else 
               		echo "zip not specified or not found, using default: update.zip"; sleep 1
               		ZIP=update.zip
                fi
                start_extract_xmls
	else
                if [ "$1" != "" ]; then
     			if [ "$1" == "--zip" ] || [ $1 == "-z" ]; then
          			if [ -e $2 ]; then
               				ZIP=$2
          			else
               				echo "${txtred}WARNING:${txtrst} zip not specified or not found: aborting"; sleep 1
               		    		exit
          			fi
			fi

                else 
               		echo "zip not specified or not found, using default: update.zip"; sleep 1
               		ZIP=update.zip
                fi
                start_extract_xmls
      	fi
fi
