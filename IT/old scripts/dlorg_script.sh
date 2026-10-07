#!/usr/bin/env bash

declare -A newfile
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

### list content in $DIRECTORY_ROOT to collect data into $newfile hash array
for file in "$DIRECTORY_ROOT"*; do

	### Create auto generate key id and add uniqe number to $id
        Id=$((ITEM_ID=ITEM_ID + 1))

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

	newfile[$Id,afilename]=$Filename
	newfile[$Id,apath]=$Path
	newfile[$Id,afullpath]=$Fullpath
	newfile[$Id,aextention]=$Extention
	newfile[$Id,aType]=$Type
	newfile[$Id,aCategory]=$Category

done

for ((n=0; n<"$Id"; n++)); do

	### Determine the file category of the file in folder $DIRECTORY_ROOT from file extention by matching $SEARCH_xxxx_EXTENTION and add file category to $Category for Audio|Document|Im>
        if [[ -d ${file} && ${file,,} =~ \.($SEARCH_AUDIO_EXTENTION)$ ]]; then
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

	### Determine the if the destination director exist before moving file to destination directory, if the directory don't exist it creates the destination directory before moving the file to directory 
	if [[ -d "${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}"  ]]; then

		### User message
		echo "Directory exists: ${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}"

		if [[ -f "${newfile["$n,afullpath"]}" ]] then

			echo "Moving file: ${newfile["$n,afilename"]} from: ${newfile["$n,apath"]} to: ${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}"
			### Moving file from source to destination directory
			echo "${newfile["$n,afullpath"]}" "${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}${newfile["$n,afilename"]}"
			mv "${newfile["$n,afullpath"]}" "${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}${newfile["$n,afilename"]}"

		fi

	else
		### User message
		echo "Directory don't exists: ${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}"
		echo "Creating missing directory: ${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}"

		### Creating missing directory
		mkdir ${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}

		if [[ -f "${newfile["$n,afullpath"]}" ]] then

			echo "Moving file: ${newfile["$n,afilename"]} from: ${newfile["$n,apath"]} to: ${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}"
			### Moving file from source to destination directory
			echo "${newfile["$n,afullpath"]}" "${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}${newfile["$n,afilename"]}"
			mv "${newfile["$n,afullpath"]}" "${DIRECTORY_TREE[${newfile["$n,aCategory"]}]}${newfile["$n,afilename"]}"

		fi

	fi

done
