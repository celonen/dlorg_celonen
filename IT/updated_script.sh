#!/usr/bin/env bash

declare -A DIRECTORY_TREE

### Full path to the folder that's going to be monitored, automated and organized
DIRECTORY_ROOT="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/"

### Sorted files will be moved to these folders depending on their file extention
DIRECTORY_TREE["Audio"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/audio/"
DIRECTORY_TREE["Document"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/document/"
DIRECTORY_TREE["Image"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/image/"
DIRECTORY_TREE["Video"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/video/"
DIRECTORY_TREE["Scripts"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/IT/"
DIRECTORY_TREE["Other"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/other/"

### Pattern matchning depending on file extention
SEARCH_AUDIO_EXTENTION="mp3"
SEARCH_DOCUMENT_EXTENTION="docx|docm|doc|txt|md|pdf|xls|ods"
SEARCH_IMAGE_EXTENTION="png|jpg|jpeg|gif"
SEARCH_VIDEO_EXTENTION="mp4|mov"
SEARCH_SCRIPT_EXTENTION="sh|bat"

### Auto generated item number for created files
ITEM_ID=0

### Program that monitors files, triggered by an event
inotifywait -m -e close_write -e moved_to --format "%f" "$DIRECTORY_ROOT" |
while read -r filename; do
	echo ""
	### Create auto generated key id and add uniqe number to $id
        Id=$((ITEM_ID=ITEM_ID + 1))

	### Retrieve full file path from $filename and add value to $Fullpath
	Fullpath=$DIRECTORY_ROOT${filename}

	### Match file extention with SEARCH-variable to define category value and what folder it should be moved into
	### Determine filetype from file extention by matching $SEARCH_xxxx_EXTENTION with Fullpath value to set category value for Audio|Document|Image|Video|Other
	if [[ -f ${Fullpath} && ${Fullpath,,} =~ \.($SEARCH_AUDIO_EXTENTION)$ ]]; then
		Category="Audio"
        elif [[ -f ${Fullpath} && ${Fullpath,,} =~ \.($SEARCH_DOCUMENT_EXTENTION)$ ]]; then
		Category="Document"
        elif [[ -f ${Fullpath} && ${Fullpath,,} =~ \.($SEARCH_IMAGE_EXTENTION)$ ]]; then
		Category="Image"
	elif [[ -f ${Fullpath} && ${Fullpath,,} =~ \.($SEARCH_VIDEO_EXTENTION)$ ]]; then
                Category="Video"
	elif [[ -f ${Fullpath} && ${Fullpath,,} =~ \.($SEARCH_SCRIPT_EXTENTION)$ ]]; then
                Category="Scripts"
	else
                Category="Other"
	fi
	### Match category value to determine if suitable folder exist
	if [[ -d ${DIRECTORY_TREE["$Category"]} ]]; then

		### User message
		echo "Processing item id: $Id"
		echo "Processing item filename: $filename "
		echo ""
		echo "Moving file: $filename from: $DIRECTORY_ROOT to: ${DIRECTORY_TREE["$Category"]}"
		echo ""
		mv "$Fullpath" "${DIRECTORY_TREE["$Category"]}$filename"

	else
		### User message
		echo "Processing item id: $Id"
		echo "Processing item filename: $filename "
		echo ""
		echo "Creating missing directory: ${DIRECTORY_TREE["$Category"]}"
		### Creating missing directory
		mkdir "${DIRECTORY_TREE["$Category"]}"
		echo ""
		echo "Moving file: $filename from: $DIRECTORY_ROOT to: ${DIRECTORY_TREE["$Category"]}"
		echo ""
		mv "$Fullpath" "${DIRECTORY_TREE["$Category"]}$filename"

	fi 

done
