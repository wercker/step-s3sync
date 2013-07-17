# s3sync

Synchronized a directory to a s3 bucket. It makes the bucket identical to the `source-dir`.
Note that this means that remote files that are not in the `source-dir` are deleted. 
The synchronized files will get an public access level.

You can use application and deployment variables in wercker.

## Options

* `key-id` (required) The Amazon Access key that will be used for authorization.
* `key-secret` (required) The Amazon Access secret that will be used for authorization.
* `bucket-url` (required) The url of the bucket to sync to, like: `s3://born2code.net`
* `source-dir` (optional, default: `./`) The directory to sync to the remote bucket.

## Example

    - s3sync:
        key-id: $KEY
        key-secret: $SECRET
        bucket-url: $BUCKET
        source-dir: $SOURCE
