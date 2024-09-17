#!/bin/bash

set -eu

day=$(date +%d)

echo "It is day ${day} of the month. My backup journey will never end!"

# Check if Secrets are loaded
test -z "${SOURCE_URL}" && echo "SOURCE_URL is not set!" && exit 1
test -z "${SOURCE_ACCESSKEY}" && echo "SOURCE_ACCESSKEY is not set!" && exit 1
test -z "${SOURCE_SECRETKEY}" && echo "SOURCE_SECRETKEY is not set!" && exit 1
test -z "${SOURCE_BUCKET}" && echo "SOURCE_BUCKET is not set!" && exit 1

var_destination_url="BUCKET_${day}_ENDPOINT_URL"
test -z "${!var_destination_url}" && echo "${var_destination_url} is not set!" && exit 1
var_destination_accesskey="BUCKET_${day}_AWS_ACCESS_KEY_ID"
test -z "${!var_destination_accesskey}" && echo "${var_destination_accesskey} is not set!" && exit 1
var_destination_secretkey="BUCKET_${day}_AWS_SECRET_ACCESS_KEY"
test -z "${!var_destination_secretkey}" && echo "${var_destination_secretkey} is not set!" && exit 1

# Set the destination Bucket based on the day
var_destination_bucket="BUCKET_${day}_BUCKET_NAME"
test -z "${!var_destination_bucket}" && echo "${var_destination_bucket} is not set!" && exit 1
destination_bucket="${!var_destination_bucket}"

# Configure Source and Destination Bucket for minio cli
mc --config-dir /tmp/ alias set source "${SOURCE_URL}" "${SOURCE_ACCESSKEY}" "${SOURCE_SECRETKEY}" --api S3v4
mc --config-dir /tmp/ alias set destination "${!var_destination_url}" "${!var_destination_accesskey}" "${!var_destination_secretkey}" --api S3v4

# check if source bucket exists
mc --config-dir /tmp/ ls source | grep -q "${SOURCE_BUCKET}" || ( echo "Bucket ${SOURCE_BUCKET} does not exists!" && exit 1)

# check if destination bucket exists
mc --config-dir /tmp/ ls destination | grep -q "${destination_bucket}" || ( echo "Bucket ${destination_bucket} does not exists!" && exit 1)

# Mirror source bucket into the destination bucket
echo "Mirror ${SOURCE_BUCKET} bucket to ${destination_bucket} bucket"
mc --config-dir /tmp/ mirror "source/${SOURCE_BUCKET}" "destination/${destination_bucket}" --overwrite --remove
