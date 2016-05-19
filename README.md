# s3sync

Synchronize a directory to a s3 bucket. It makes the bucket identical to the `source-dir`.
Note that this means that remote files that are not in the `source-dir` are deleted.
The synchronized files will get an public access level.

It is recommended that you use application and deployment variables in wercker, so you don't include any private keys in your code.

[![wercker status](https://app.wercker.com/status/2064379a8b583cd1b5da16de3faa5583/m "wercker status")](https://app.wercker.com/project/bykey/2064379a8b583cd1b5da16de3faa5583)

# What's new

- Always display s3cmd output

# Options

* `key-id` (required) The Amazon Access key that will be used for authorization.
* `key-secret` (required) The Amazon Access secret that will be used for authorization.
* `bucket-url` (required) The url of the bucket to sync to, like: `s3://wercker.com`, where `wercker.com` is the bucket name.
* `source-dir` (optional, default: `./`) The directory to sync to the remote bucket.
* `delete-removed` (optional, default: `true`) Add `--delete-remove` flag if this is `true`.
* `opts` (optional, default: `--acl-public`) Arbitrary options provided to s3cmd. See `s3cmd --help` for more.

# Example

```
deploy:
    steps:
        - s3sync:
            key-id: $KEY
            key-secret: $SECRET
            bucket-url: $BUCKET
            source-dir: $SOURCE
            opts: --acl-private
```

# Privacy

By default s3sync will make the files publicly available from your S3 bucket, but you can use the "opts" option to manually specify an ACL option to s3cmd. At the time of writing, these are:

```
  -P, --acl-public      Store objects with ACL allowing read for anyone.
  --acl-private         Store objects with default ACL allowing access for you
                        only.
  --acl-grant=PERMISSION:EMAIL or USER_CANONICAL_ID
                        Grant stated permission to a given amazon user.
                        Permission is one of: read, write, read_acp,
                        write_acp, full_control, all
```

# Permissions

It's a good idea to create a IAM user which just has enough permissions to be able to sync to the S3 buckets that it needs to. The IAM user needs the following permissions to be able to sync a bucket (replace `[bucket_name]` with the bucket name):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::[bucket_name]",
          "arn:aws:s3:::[bucket_name]/*"
      ]
    }
  ]
}
```

# License

The MIT License (MIT)

# Changelog

## 2.0.3

- Always display s3cmd output

## 2.0.2

- Fix `source-dir` bug

## 2.0.0

- Refactor run.sh
- Update s3cmd to 1.5.1.2
- Bundle s3cmd in step

## 1.1.0

- Add `delete-removed` parameter

## 1.0.0

- Add information about permissions to the README

## 0.0.3

- Initial release
