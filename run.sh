if [ ! -n "$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_KEY" ]; then
  error 'Please specify key property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_SECRET" ]; then
  error 'Please specify secret property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_SOURCE_FILE" ]; then
  error 'Please specify source_file property'
  exit 1
fi

if [ ! -n "$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_DEST_DIR" ]; then
  error 'Please specify dest_dir property'
  exit 1
fi

pge=$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/downloads

urlDownload=https://api.bitbucket.org/2.0/repositories/$pge

secret_key=$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_KEY:$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_SECRET

response=$(curl -X POST -u "$secret_key" \
 https://bitbucket.org/site/oauth2/access_token \
  -d grant_type=client_credentials)

echo $response
regex="\"(access_token)\": \"([^\"]*)\""

if [[ $response =~ $regex ]]
then
    access_token="${BASH_REMATCH[2]}"
    echo $access_token
else
    error "$f doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
    exit 1
fi

response=$(curl -X GET $urlDownload?access_token=$access_token)
echo $response
regex="\"(href)\": \"[^\"]*$WERCKER_GIT_OWNER\/$WERCKER_GIT_REPOSITORY\/downloads\/([^\"]*)\""

source_file=$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_SOURCE_FILE
i=0
while [[ $response =~ $regex ]];do
    filename="${BASH_REMATCH[2]}";
    echo $filename
    if [[ "$filename" == $source_file ]]; then
        echo "'$filename' contains '$source_file'"
        file_list[$i]=$filename
        i=$((i+1))
    else
        echo "'$filename' does not contain '$source_file'"
    fi
    response=${response#*"${BASH_REMATCH[0]}"}
done

echo "size: ${#file_list[*]}"

echo "download files:"

mkdir -p $WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_DEST_DIR

for index in ${!file_list[@]}; do
    filename="${file_list[index]}"
    out_filename=$filename

    if [ -n "$WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_DEST_FILE" ]; then
        if [ "$index" -ne "0" ]; then
            echo "==================================================================="
            out_filename=${WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_DEST_FILE}_${index}
        else
            out_filename=${WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_DEST_FILE}
        fi
    fi

    wget $urlDownload/$out_filename?access_token=$access_token -O $WERCKER_BITBUCKET_UPLOAD_ASSET_WILDCARD_DEST_DIR/${out_filename}
done
