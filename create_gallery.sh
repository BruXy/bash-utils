#!/bin/bash
WIDTH=320
exec 3>gallery.html
IFS=$'\n'
for i in $(find . -type f | sort)
do
    echo "Processing image $i ..."
    new_name=$(sed -e 's:^./::' -e 's:/:_:g' -e 's/ /_/g' <<< $i)
    new_name=thumb-$new_name
    convert -thumbnail $WIDTH $i $new_name
    (
        echo "<a href='$i'>"
        echo "<img src='$new_name' alt='Thumbnail: $new_name' />"
        echo "</a>"
        echo
    ) >&3
done

exec 3>&-
