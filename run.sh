#!/bin/sh
set -e
cd $HOME
if [ ! -n "$WERCKER_S3SYNC_KEY_ID" ]
then
    fail 'missing or empty option key_id, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3SYNC_KEY_SECRET" ]
then
    fail 'missing or empty option key_secret, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3SYNC_BUCKET_URL" ]
then
    fail 'missing or empty option bucket_url, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3SYNC_OPTS" ]
then
    export WERCKER_S3SYNC_OPTS="--acl-public"
fi

if [ -n "$WERCKER_S3SYNC_DELETE_REMOVED" ]; then
    if [ "$WERCKER_S3SYNC_DELETE_REMOVED" = "true" ]; then
        export WERCKER_S3SYNC_DELETE_REMOVED="--delete-removed"
    else
        unset WERCKER_S3SYNC_DELETE_REMOVED
    fi
else
    export WERCKER_S3SYNC_DELETE_REMOVED="--delete-removed"
fi

if ! type s3cmd &> /dev/null ;
then
    info 's3cmd not found, start installing it'
    wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add -
    sudo wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list
    sudo apt-get update && sudo apt-get install s3cmd
    success 's3cmd installed succesfully'
else
    info 'skip s3cmd install, command already available'
    debug "type s3cmd: $(type s3cmd)"
fi

if [ -e '.s3cfg' ]
then
    warn '.s3cfg file already exists in home directory and will be overwritten'
fi

echo '[default]' > '.s3cfg'
echo "access_key=$WERCKER_S3SYNC_KEY_ID" >> .s3cfg
echo "secret_key=$WERCKER_S3SYNC_KEY_SECRET" >> .s3cfg
debug "generated .s3cfg for key $WERCKER_S3SYNC_KEY_ID"

source_dir="$WERCKER_ROOT/$WERCKER_S3SYNC_SOURCE_DIR"
if cd "$source_dir" ;
then
    debug "changed directory $source_dir, content is: $(ls -l)"
else
    fail "unable to change directory to $source_dir"
fi

info 'starting s3 synchronisation'

set +e
SYNC="s3cmd sync $WERCKER_S3SYNC_OPTS $WERCKER_S3SYNC_DELETE_REMOVED --verbose ./ $WERCKER_S3SYNC_BUCKET_URL"
debug "$SYNC"
sync_output=$($SYNC)

if [[ $? -ne 0 ]];then
    warning $sync_output
    fail 's3cmd failed';
else
    success 'finished s3 synchronisation';
fi
set -e
