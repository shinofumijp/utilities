#!/usr/bin/env bash

if [ $# -eq 2 ]; then
    DATETIME=`date +%Y%m%d%H%M%S`
    TMPFILE_NAME="filter_scrapbox_import_json-$DATETIME-tmpfile.txt"
    TMPFILE_JSON="filter_scrapbox_import_json-$DATETIME-tmpfile.json"

    PAGES=`cat $1 | jq -r '[.pages[]]'`

    # Filter original pages by titles listed in a filfe, which is given by $2
    cat $2 | while read line
    do
        # NOTE: Make this procedure more efficient
        # e.g. O(M x N) loop (M=number of lines, N=number of pages)
        echo $PAGES | jq  "map(select( .title == $line))" | jq '.[0]' >> $TMPFILE_NAME
    done

    # Make JSON-like objects into an actual JSON
    cat $TMPFILE_NAME | jq -s . >> $TMPFILE_JSON

    # Replace `pages` array with filtered one
    cat $1| jq ".pages|=`cat $TMPFILE_JSON`"

    rm $TMPFILE_NAME
    rm $TMPFILE_JSON
else
    echo 'Error'
    echo 'Usage: filter_scrapbox_import_json.sh <original-scrapbox-output.json> <titles-file>'
    exit 1
fi
