#!/bin/bash
###############################################################################
#                                                                             # 
#    Martin Bruchanov, bruxy at regnet dot cz                                 #
#                                                                             # 
#    http://bruxy.regnet.cz/                                                  #
#                                                                             # 
#    Version: 1.2 (Fri Jul 20 13:17:18 CEST 2012)                             #
#                                                                             # 
###############################################################################

## Defaults
DEFAULT_DPI=300    # default output dpi
GS_DPI=300         # gs will rasterize to this size, before resizing
UNSHARP_RADIUS=1.0 # bitmap enhancing with unsharp mask
COLORS=16777216    # default num. of colors, use 16, 256,...

## Global variables
PAGE_START=1       
PAGE_STOP=1
WIDTH=0
HEIGHT=0
PAGE=0
ALL=0

## Help
print_help(){
	echo "PDF2PNG"
	echo "Usage: " `basename $0` [OPTIONS] FILE
	echo
	echo "Options:"	
	echo "	-h   ... this help"
	echo "	-a   ... convert all pages"
	echo "	-f N ... from page number N"
	echo "	-t N ... to page number N"
	echo "	-p N ... only page N (default N = 1)"
	echo "	-d N ... resolution in dpi (default N = $DEFAULT_DPI)"
	echo "	-x N ... bitmap  width in pixel (if y not given, save aspect ratio)"
	echo "	-y N ... bitmap height in pixel (if x not given, save aspect ratio)"
	echo "	-u N ... unsharp radius (default N = $UNSHARP_RADIUS)"
    echo "	-c N ... number of colors (default N = $COLORS)"
	echo 
}

# definition of color escape sequences for ANSI terminal
RED="\033[01;31m"
GREEN="\033[01;32m"

color_echo(){
# 1 -- color escape sequncy
# 2 -- string
# \033[0m -- reset color settings
  echo -e "$1 $2 \033[0m"
}


test_return(){
# 1 -- return code $?
# 2 -- description of operation
echo -e -n $2:
COL=40
# move cursor to column $COL 
echo -en "\033[${COL}G"
if [ $1 -eq 0 ] 
then
	color_echo $GREEN OK
else
	color_echo $RED FALSE
	exit 1
fi
}

if [ $# -lt 1 ] # print help
then
    print_help
    exit 1
fi

## Process CLI

while getopts "af:t:d:hx:y:w:u:p:c:" name
do
	case $name in
	a)	ALL=1
	;;
	f)	PAGE_START=$OPTARG
	;;
	t)	PAGE_STOP=$OPTARG
	;;
	p)	PAGE=$OPTARG
	;;
	d) 	DEFAULT_DPI=$OPTARG
	;;
	x)	WIDTH=$OPTARG
	;;
	y)	HEIGHT=$OPTARG
	;;
	u)	UNSHARP_RADIUS=$OPTARG
	;;
	c)	COLORS=$OPTARG
	;;
	h)	# help
		print_help
		exit 0
	;;
	\?)
		echo "Invalid option!"
		exit 1
	;;
	esac
done


shift $(($OPTIND - 1));

INPUT=$1

OUTPUT=$(basename $INPUT .pdf)

echo "Input file: $INPUT"

## Check all input parameters and set options

if [ -z "$INPUT" ]
then
	echo "No input file!"
	exit 1
fi

# All pages processing

MAX_PAGE=`pdfinfo "$INPUT" | grep Pages | awk '{ print $2}'`

if [ -z $MAX_PAGE ]; then exit; fi

if [ $ALL -eq 1 ]
then
	PAGE_START=1
	PAGE_STOP=$MAX_PAGE
fi

# Page range processing

if [ $PAGE_START -gt 1 ]
then
	if [ $PAGE_STOP -eq 1 ]
	then
		PAGE_STOP=$MAX_PAGE
	fi
fi

if [ $PAGE_STOP -gt 1 ]
then
	if [ $PAGE_START -eq 1 ]
	then
		PAGE_START=1
	fi
fi

if [ $PAGE -gt 0 ]
then
	PAGE_START=$PAGE
	PAGE_STOP=$PAGE
fi

# Image size

if [ $WIDTH -gt 0 ]
then
	if [ $HEIGHT -gt 0 ]
	then
		RESIZE=${WIDTH}x${HEIGHT}\!
	else
		RESIZE=${WIDTH}x
	fi
	DEFAULT_DPI=0
fi

if [ $HEIGHT -gt 0 ]
then
	if [ $WIDTH -gt 0 ]
	then
		RESIZE=${WIDTH}x${HEIGHT}\!
	else
		RESIZE=x${HEIGHT}
	fi
	DEFAULT_DPI=0
fi

if [ $DEFAULT_DPI -gt 0 ]
then
	RESIZE=$(((DEFAULT_DPI*100)/GS_DPI))"%"
fi

echo $RESIZE
#exit

##############################################################################

echo "Rasterizing pages from $PAGE_START to $PAGE_STOP."
echo "Output image size: $RESIZE"

j=1
N=$((PAGE_STOP-PAGE_START+1))
for i in `seq $PAGE_START $PAGE_STOP`
do
	i=`printf %04u $i`
	echo "Processing page no. $i ($j/$N)"
	TMP=/tmp/tmp-${i}.png
	gs -q -sDEVICE=png16m -dBATCH -dNOPAUSE \
		-dFirstPage=$i -dLastPage=$i -r$GS_DPI \
		 -sOutputFile=$TMP "$INPUT" > /dev/null 2>&1

	test_return $? "GhostScript conversion"	

	convert \
		-unsharp "$UNSHARP_RADIUS" \
		-resize "${RESIZE}" \
		-colors $COLORS +dither \
		$TMP png:${OUTPUT}_${i}.png 

	rm -f $TMP
	: $((j++))
done


