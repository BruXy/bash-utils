#!/bin/bash
#%A
#
# SVG to PNG Batch convertor
#
# Usage:
#
# svg2png.sh [FILE] ...
#
#%B
OUT_DPI=300
INPUT=$*

function print_help() {
    sed -ne '/^#%A/,/^#%B/{s/\(^#\|^#%[AB]\)//p}' $0
}

# Display help
if [ $# -eq 0 ] ; then print_help 1>&2; exit 1; fi
if [[ "$1" =~ ^-?-h(elp)?$ ]] ; then print_help; exit 0; fi

# Batch for file conversion
for ifile in $INPUT
do
    ofile=${ifile/svg/png}
    inkscape -d $OUT_DPI -z -e $ofile $ifile
done

