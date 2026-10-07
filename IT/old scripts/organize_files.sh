#Steg1: 
#!/bin/bash

declare -A NEWFILE
declare -A DIRECTORY_TREE

#(måste läggas ovanför inotifywait)
DIRECTORY_ROOT="/home/oracle_linux10_user/Documents/github/dlorg_celonen/download1/"
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

		### Create auto generate key id and add nu uniq number to $id
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
		echo ""
		echo "id: $Id"
		echo "filename: $Filename"
		echo "path: $Path"
		echo "fullpath: $Fullpath"
		echo "extention: $Extention"
		echo "type: $Type"
		echo "category: $Category"
		echo ""


	done
	
	ITEM_ID=0


done



