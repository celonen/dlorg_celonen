#!/bin/bash

declare -A NEWFILE
declare -A DIRECTORY_TREE

DIRECTORY_ROOT="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/"
DIRECTORY_TREE["Audio"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/audio/"
DIRECTORY_TREE["Document"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/document/"
DIRECTORY_TREE["Image"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/image/"
DIRECTORY_TREE["Video"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/video/"
DIRECTORY_TREE["Other"]="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download/other/"

SEARCH_AUDIO_EXTENTION="mp3"
SEARCH_DOCUMENT_EXTENTION="docx|docm|doc|txt|md|pdf|xls|ods"
SEARCH_IMAGE_EXTENTION="png|jpg|jpeg|gif"
SEARCH_VIDEO_EXTENTION="mp4|mov"

ITEM_ID=0

inotifywait -m -e close_write -e moved_to -e create --format "%f" "$DIRECTORY_ROOT" |
while read -r filename; do
	
	### list content in $DIRECTORY_ROOT to collect data into $NEWFILE hash array
	for file in "$DIRECTORY_ROOT"*; do
		[[ -f "$file" ]] || continue

		### Create auto generate key id and add uniqe number to $id
		Id=$((ITEM_ID=ITEM_ID+1))

		### Retrieve filename from $file and add value to $Filename
		Filename=$(basename "$file")

		### Retrieve file extention from $file and add value to $Extention
		Extention="${file##*.}"

		### Retrieve full file path from $file and add value to $Fullpath
		Fullpath=${file} ## korrigering

		### Retrieve file path from $file and ignore value with . and att the path to the file in $Path
		if [[ "$(dirname "$file")" != "." ]]; then
			Path="$(dirname "$file")"
		else
			Path=""
		fi

		### Determine the file type in the folder $DIRECTORY_ROOT and add the value to $Type for Directory|Executeble|File|Other
		if [[ -d "$file" ]]; then
	    		Type="Directory"
		elif [[ -f "$file" && -x "$file" ]]; then
	    		Type="Executable"
		elif [[ -f "$file" ]]; then
	    		Type="File"
		else
	    		Type="Other"
		fi

		### Determine the file category of the file in folder $DIRECTORY_ROOT from file extention by matching $SEARCH_xxxx_EXTENTION and add file category to $Category for Audio|Document|Image|Video|Other
		if [[ -f ${file} && ${file,,} =~ \.($SEARCH_AUDIO_EXTENTION)$ ]]; then
			Category="Audio"
		elif [[ -f ${file} && ${file,,} =~ \.($SEARCH_DOCUMENT_EXTENTION)$ ]]; then
			Category="Document"
		elif [[ -f ${file} && ${file,,} =~ \.($SEARCH_IMAGE_EXTENTION)$ ]]; then
			Category="Image"
		elif [[ -f ${file} && ${file,,} =~ \.($SEARCH_VIDEO_EXTENTION)$ ]]; then
		        Category="Video"
		else
		        Category="Other"
		fi
		
		NEWFILE[$Id,afilename]="$Filename"
		NEWFILE[$Id,apath]="$Path"
		NEWFILE[$Id,afullpath]="$Fullpath"
		NEWFILE[$Id,aextention]="$Extention"
		NEWFILE[$Id,aType]="$Type"
		NEWFILE[$Id,aCategory]="$Category"		
		
		### "Array adding item id: $Id"
		### "Array adding filename: $Filename"
		#echo ""
		#echo "id: $Id"
		#echo "filename: $Filename"
		#echo "path: $Path"
		#echo "fullpath: $Fullpath"
		#echo "extention: $Extention"
		#echo "type: $Type"
		#echo "category: $Category"
		#echo ""

	done

	ITEM_ID=0
	
	for i in $(printf '%s\n' "${!NEWFILE[@]}" | cut -d',' -f1 | sort -nu); do
	    	
	    	#echo "Index: "$i
	   	#echo ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}
	    	
	    	if [[ -d ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]} ]]; then

			### User message
			### echo "Directory exists: ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}"
			echo "Processing item id: $i"
			echo "Processing item filename: ${NEWFILE["$i,afilename"]} "
			echo "Moving file: ${NEWFILE["$i,afilename"]} from: ${NEWFILE["$i,apath"]}/ to: ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}"
			echo ""
			mv "${NEWFILE["$i,afullpath"]}" "${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}${NEWFILE["$i,afilename"]}"

		else
			### User message
			echo "Processing item id: $i"
			echo "Processing item filename: ${NEWFILE["$i,afilename"]} "
			### echo "Directory don't exists: ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}"
			echo "Creating missing directory: ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}"
			
			### Creating missing directory
			mkdir "${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}"
			
			echo "Moving file: ${NEWFILE["$i,afilename"]} from: ${NEWFILE["$i,apath"]}/ to: ${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}"
			echo ""
			mv "${NEWFILE["$i,afullpath"]}" "${DIRECTORY_TREE[${NEWFILE["$i,aCategory"]}]}${NEWFILE["$i,afilename"]}"

		fi 
		
		### remove item $i from NEWFILE
		unset NEWFILE[$i,afilename]
		unset NEWFILE[$i,apath]
		unset NEWFILE[$i,afullpath]
		unset NEWFILE[$i,aextention]
		unset NEWFILE[$i,aType]
		unset NEWFILE[$i,aCategory]
	     
	done

done
