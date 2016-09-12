#!/usr/bin/env bash

if [ ! -n "$WERCKER_BITBUCKET_DOWNLOAD_KEY" ]; then
  error 'Please specify key property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_DOWNLOAD_SECRET" ]; then
  error 'Please specify secret property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_DOWNLOAD_SOURCE_FILE" ]; then
  error 'Please specify source_file property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_DOWNLOAD_DEST_DIR" ]; then
  error 'Please specify dest_dir property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_DOWNLOAD_GIT_OWNER" ]; then
  error 'Please specify git_owner property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_DOWNLOAD_GIT_REPOSITORY" ]; then
  error 'Please specify git_repository property'
  exit 1
fi

pge=$WERCKER_BITBUCKET_DOWNLOAD_GIT_OWNER/$WERCKER_BITBUCKET_DOWNLOAD_GIT_REPOSITORY/downloads

urlDownload=https://api.bitbucket.org/2.0/repositories/$pge

secret_key=$WERCKER_BITBUCKET_DOWNLOAD_KEY:$WERCKER_BITBUCKET_DOWNLOAD_SECRET

response=$(curl -X POST -u "$secret_key" \
 https://bitbucket.org/site/oauth2/access_token \
  -d grant_type=client_credentials)

echo "$response"
regex="\"(access_token)\": \"([^\"]*)\""

if [[ $response =~ $regex ]]
then
    access_token="${BASH_REMATCH[2]}"
    echo "$access_token"
else
    error "$f doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
    exit 1
fi

response=$(curl -X GET "$urlDownload?access_token=$access_token")
echo "$response"
regex="\"(href)\": \"[^\"]*$WERCKER_BITBUCKET_DOWNLOAD_GIT_OWNER\/$WERCKER_BITBUCKET_DOWNLOAD_GIT_REPOSITORY\/downloads\/([^\"]*)\""

echo "find href by regexp: $regex"

source_file=$WERCKER_BITBUCKET_DOWNLOAD_SOURCE_FILE
i=0
while [[ $response =~ $regex ]];do
    filename="${BASH_REMATCH[2]}";
    echo "$filename"
    if [[ "$filename" = $(printf "%s" "${source_file}")  ]]; then
        echo "'$filename' contains '$source_file'"
        file_list[$i]=$filename
        i=$((i+1))
    else
        echo "'$filename' does not contain '$source_file'"
    fi
    response=${response#*"${BASH_REMATCH[0]}"}
done

fileListSize=${#file_list[*]}

echo "size: $fileListSize"

if [ "$fileListSize" == "0" ]; then
    error "Not found files"
    exit 1
fi

echo "download files:"

out_dir="$WERCKER_BITBUCKET_DOWNLOAD_DEST_DIR"

mkdir -p "$out_dir"

for index in "${!file_list[@]}"; do
    filename="${file_list[index]}"
    out_filename=$filename

    if [ -n "$WERCKER_BITBUCKET_DOWNLOAD_DEST_FILE" ]; then
        if [ "$index" -ne "0" ]; then
            echo "==================================================================="
            out_filename=${WERCKER_BITBUCKET_DOWNLOAD_DEST_FILE}_${index}
        else
            out_filename=${WERCKER_BITBUCKET_DOWNLOAD_DEST_FILE}
        fi
    fi

    curl -L "$urlDownload/$filename?access_token=$access_token" \
    --output "$out_dir/${out_filename}"

    echo "file downloaded to $out_dir/${out_filename}"
done
