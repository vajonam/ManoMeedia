#!/bin/bash

## MiniMeedia linux build script
##
## This script does the same as the Build.bat file
##
## Changelog:
##
##   29 Sep 2009:
##     - Created script based on Build.bat and (MediaStream build.sh)

clear

## Get program location. If we can't autofind it, ask the user
## First param is the program itself, second is the default location
## The result is stored in $VALUE
function get_program_location()
{
	echo -n "Checking for '$1': "
	VALUE=`which $1 2>/dev/null`

	if [ -z $VALUE ];
	then
		## which couldn't find the file or which wasn't installed
		if [ -f $2 ];
		then
			## found the file on the default location
			VALUE=$2
			echo "$VALUE"
		else
			echo "NOT FOUND!"
			
			echo "'$1' is not found in it's default location $2."
			echo -n "Please enter the full path to $1 or press CTRL+C to abort: "
			read -e VALUE
		fi
	else
		echo "$VALUE"
	fi
}

## Get the value of a tag in skin.xml and store it in $VALUE
## $VALUE is empty if the tag wasn't found
function get_tag()
{
	VALUE=`$EGREP "<$1>.*</$1>" skin.xml | $SED "s/<$1>//" | $SED "s/<\/$1>//" | $SED "s/\r//" | $AWK '{print $1}'`
}

function get_build()
{
BUILDNO=`cat $DIRNAME/buildnumber`
}

function increment_build()
{
BUILDNO=`expr $BUILDNO + 1`
}
function set_build()
{
echo $BUILDNO > $DIRNAME/buildnumber
}


DIRNAME=`dirname $0`

echo "======================================================================"
echo ""
echo "MiniMeedia Build Script"

## Check if we got all tools we need on the system.
## If not, ask for locations
get_program_location "egrep" "/bin/egrep"
EGREP=$VALUE

get_program_location "sed" "/bin/sed"
SED=$VALUE

get_program_location "awk" "/usr/bin/awk"
AWK=$VALUE

get_program_location "svnversion" "/usr/bin/svnversion"
SVNVERSION=$VALUE

get_program_location "XBMCTex" "./XBMCTex.bin"
XBMCTEX=$VALUE

echo ""

## Set skin name based on skin.xml setting, if doesn't work use current directory
get_tag "skinname"
SKINNAME=${VALUE}
if [ -z "$SKINNAME" ];
then
	NAME=$DIRNAME
fi

echo "Skin name: $SKINNAME"

## Get svn revision number
REVISION=`svnversion $DIRNAME`
REVISION=${REVISION%\M}
echo "Revision number: $REVISION"

## Extract Resolution and Version from skin.xml and SET the variables

get_tag "skinversion"
VERSION=$VALUE
echo "Skin version: $VERSION"

get_tag "defaultresolution"
DEFAULTRES=$VALUE
echo "Default resolution: $DEFAULTRES"

get_tag "defaultresolutionwide"
DEFAULTRESWIDE=$VALUE
echo "Default resolution widescreen: $DEFAULTRESWIDE"

echo ""
echo "======================================================================"
echo ""

echo -n "(Re)Creating BUILD/${SKINNAME}: "
if [ -d $DIRNAME/BUILD/$SKINNAME ];
then
	rm -rf "$DIRNAME/BUILD/$SKINNAME"
fi
mkdir "$DIRNAME/BUILD/$SKINNAME"
echo "done."

echo -n "Creating exclude.txt file: "
echo ".svn" > $DIRNAME/BUILD/exclude.txt
echo "Thumbs.db" >> $DIRNAME/BUILD/exclude.txt
echo "Desktop.ini" >> $DIRNAME/BUILD/exclude.txt
echo "done."

echo -n "Compressing images to .xbt: [standard] "
${XBMCTEX} -input media -output $DIRNAME/media/textures.xbt > /dev/null
# echo -n "[lite] "
# ${XBMCTEX} -input media-lite -output $DIRNAME/Media/lite.xbt >/dev/null
echo "done."

echo -n "Copying required files to BUILD/$SKINNAME folder: "
cp -r $DIRNAME/720p $DIRNAME/BUILD/$SKINNAME/720p 2>/dev/null
cp -r $DIRNAME/colors $DIRNAME/BUILD/$SKINNAME/colors 2>/dev/null
cp -r $DIRNAME/fonts $DIRNAME/BUILD/$SKINNAME/fonts 2>/dev/null
cp -r $DIRNAME/sounds $DIRNAME/BUILD/$SKINNAME/sounds 2>/dev/null
cp -r $DIRNAME/language $DIRNAME/BUILD/$SKINNAME/language 2>/dev/null
cp -r $DIRNAME/scripts $DIRNAME/BUILD/$SKINNAME/scripts 2>/dev/null
cp -r $DIRNAME/*.xml $DIRNAME/BUILD/$SKINNAME/. 2>/dev/null
cp -r $DIRNAME/*.txt $DIRNAME/BUILD/$SKINNAME/. 2>/dev/null
mkdir $DIRNAME/BUILD/$SKINNAME/media
cp -r $DIRNAME/media/*.xbt $DIRNAME/BUILD/$SKINNAME/media/. 2>/dev/null
rm find $DIRNAME/BUILD/$SKINNAME -name .svn -print0 | xargs -0 rm -r
echo "done."

get_build
increment_build
set_build

## Create revision include file
if [ ! -z "$DEFAULTRES" ];
then
	echo -n "Making $DEFAULTRES revision.xml include file: "
	echo "<!-- $SKINNAME skin revision: ${REVISION} - built with build.sh version 0.1 -->" > $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "<includes>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "<include name=\"Revision\">" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
 	# dont use svn any more git's version is way cooler	
	# echo "<label>$SKINNAME ${VERSION}, SVN - r${REVISION}</label>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "<label>$SKINNAME ${VERSION}.${BUILDNO} </label>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "</include>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "</includes>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "done."
fi

if [ ! -z "$DEFAULTRESWIDE" ];
then
	echo -n "Making $DEFAULTRESWIDE revision.xml include file: "
	echo "<!-- $SKINNAME skin revision: ${REVISION} - built with build.sh version 0.1 -->" > $DIRNAME/BUILD/$SKINNAME/${DEFAULTRESWIDE}/revision.xml
	echo "<includes>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRESWIDE}/revision.xml
	echo "<include name=\"Revision\">" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRESWIDE}/revision.xml
 	# dont use svn any more git's version is way cooler	
	# echo "<label>$SKINNAME ${VERSION}, SVN - r${REVISION}</label>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "<label>$SKINNAME ${VERSION}.${BUILDNO} </label>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRES}/revision.xml
	echo "</include>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRESWIDE}/revision.xml
	echo "</includes>" >> $DIRNAME/BUILD/$SKINNAME/${DEFAULTRESWIDE}/revision.xml
	echo "done."
fi

## Cleanup
echo -n "Cleaning up: "
rm -f $DIRNAME/BUILD/exclude.txt
rm -f $DIRNAME/media/textures.xbt
rm -f $DIRNAME/media/lite.xbt
echo "done."

cd $DIRNAME/BUILD
tar zcf $SKINNAME\ $VERSION.tar.gz $SKINNAME
cd $DINAME

echo "======================================================================"
echo ""
echo "Build Complete - Scroll up to check for errors."
echo ""
echo "Final build is located in $DIRNAME/BUILD."
echo ""
echo "Copy the $DIRNAME/BUILD/$SKINNAME folder"
echo "to your XBMC skin folder"
echo ""
echo "======================================================================"

