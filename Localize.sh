#!/bin/bash

# ##########################################################
# Author: Neil Burchfield
# Purpose: Localization Script
# Date: Nov 16, 2013
# ##########################################################

# ##########################################################
# Vars
# ##########################################################

SOURCE_LANGUAGE="en"
DESTINATION_LANGUAGE="en-au"
LANGUAGE_CODES=("en-au" "de" "ru" "sv" "en-ca" "it" "zh-sg" "fr-ch" "zh-hk" "ja" "ko" "en-gb" "fr" "nl" "es")
LANGUAGE_STRINGS=("Australia" "Germany" "Russia" "Sweden" "Canada" "Italy" "Singapore" "Switzerland" "China" "Japan" "South Korea" "United Kingdom" "France" "Netherlands" "Spain")
CURRENT_LANG=0
LOCALIZED_FILENAME="Localizable.strings"
CURRENT_DIRECTORY_NAME="${PWD##*/}/Localized"
CURRENT_DIRECTORY_PATH="${PWD}/Localized"

# ############################
# Most Popular App Countries:
# Australia
# Germany
# Russia
# Sweden
# Canada
# Italy
# Singapore
# Switzerland
# China
# Japan
# South Korea
# United Kingdom
# France
# Netherlands
# Spain
# ############################

# ##########################################################
# Merge English Localization
# ##########################################################

merge_en () {
    
	echo lang: "en"
    
    ldir=${CURRENT_DIRECTORY_PATH}/${SOURCE_LANGUAGE}".lproj"
    lfile=${ldir}/${LOCALIZED_FILENAME}

    if [ ! -d "$ldir" ] ; then
        mkdir "$ldir"
    else
        rm -r "$ldir"
        mkdir "$ldir"
    fi

    if [ ! -f "$lfile" ] ; then
        touch "$lfile"
    else
        rm "$lfile"
        touch "$lfile"
    fi
    
	cp $LOCALIZED_FILENAME "$ldir"
}

# ##########################################################
# Iterate through each specified country code
# ##########################################################

for lang in "${LANGUAGE_CODES[@]}"
do
echo lang: $lang
NEW_PATH=${CURRENT_DIRECTORY_PATH}/${lang}".lproj"
mkdir -p $NEW_PATH

lfile=${NEW_PATH}/${LOCALIZED_FILENAME}

if [ ! -f "$lfile" ] ; then
touch "$lfile"
else
rm "$lfile"
touch "$lfile"
fi

while read p; do

# ##########################################################
# Parse .strings Content
# ##########################################################

KEY=`echo $p | cut -d'"' -f 2`
VALUE=`echo $p | cut -d'"' -f 4`

set +o histexpand

# ##########################################################
# Fetch Translated
# ##########################################################

TRANSLATED=$(curl -s -A "Chrome" "http://translate.google.com.br/translate_a/t?client=t&text=${VALUE// /%20}&hl=pt-BR&sl=$SOURCE_LANGUAGE&tl=$lang&multires=1&ssel=0&tsel=0&sc=1" | iconv -f iso8859-1 -t utf-8 | awk -F'"' '{print $2}')

TRANSLATED_FORMATTED=$(echo \"$KEY\" " = " \"$TRANSLATED\")

# ##########################################################
# Append to proper file
# ##########################################################

echo $TRANSLATED_FORMATTED >> ${NEW_PATH}/${LOCALIZED_FILENAME}

done < $LOCALIZED_FILENAME

done

merge_en

# ###
# ### Begin File Copying into Bundle
# ###

# ##########################################################
# Author: Neil Burchfield
# Purpose: Copy Assets into Bundle
# Date: Nov 16, 2013
# ##########################################################

# ##########################################################
# Vars
# ##########################################################

SRC_DIR="Localized/"
DST_DIR="$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/Localized"
COPY_HIDDEN=
ORIG_IFS=$IFS
IFS=$(echo -en "\n\b")

if [[ ! -e "$SRC_DIR" ]]; then
echo "Path does not exist: $SRC_DIR"
exit 1
fi

if [[ -n $COPY_HIDDEN ]]; then
alias do_find='find "$SRC_DIR"'
else
alias do_find='find -L "$SRC_DIR" -name ".*" -prune -o'
fi

time (

# ##########################################################
# Code signing files must be removed or else there are
# resource signing errors.
# ##########################################################

rm -rf "$DST_DIR" \
"$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/_CodeSignature" \
"$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/PkgInfo" \
"$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/embedded.mobileprovision"

# ##########################################################
# Directories
# ##########################################################

for p in $(do_find -type d -print); do
subpath="${p#$SRC_DIR}"
mkdir "$DST_DIR$subpath" || exit 1
done

# ##########################################################
# Symlinks
# ##########################################################

for p in $(do_find -type l -print); do
subpath="${p#$SRC_DIR}"
source=$(readlink $SRC_DIR$subpath)
sourcetype=$(stat -f "%HT%SY" $source)
if [ "$sourcetype" = "Directory" ]; then
mkdir "$DST_DIR$subpath" || exit 2
else
rsync -a "$source" "$DST_DIR$subpath" || exit 3
fi
done

# ##########################################################
# Files
# ##########################################################

for p in $(do_find -type f -print); do
subpath="${p#$SRC_DIR}"
if ! ln "$SRC_DIR$subpath" "$DST_DIR$subpath" 2>/dev/null; then
rsync -a "$SRC_DIR$subpath" "$DST_DIR$subpath" || exit 4
fi
done

)
IFS=$ORIG_IFS
