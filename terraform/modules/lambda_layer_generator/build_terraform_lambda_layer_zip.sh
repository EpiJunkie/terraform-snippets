#!/bin/bash

# Title:                    build_terraform_lambda_layer_zip.sh
# Author:                   Justin Holcomb
# Created:                  April 18, 2019
# Version:                  0.0.1
# Description:              Ran from inside Amazon Linux docker/EC2 to generate
#                           zip package to be used as AWS Lambda Layer with
#                           terraform binay.

# Download tools needed to unpackage RPM files and repackage as zip.
yum install -y jq unzip wget zip

# Make directory for final packaging.
# This structure conforms with the PATHs included in the Lambda environment.
mkdir -vp /tmp/lambda_final/bin

# Retrieve latest terraform version and generate URL.
latest_version="$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')"
echo "Latest terraform version: ${latest_version}"
latest_version_url="https://releases.hashicorp.com/terraform/${latest_version}/terraform_${latest_version}_linux_amd64.zip"
echo "Latest terraform download URL: ${latest_version_url}"

# Download terraform
wget ${latest_version_url} -O /tmp/terraform_latest.zip

# Unzip archive
unzip -d /tmp/ /tmp/terraform_latest.zip

# Move terraform to folder for zipping.
mv -v /tmp/terraform /tmp/lambda_final/bin/

# Capture unzipped filesize. Needs to be under 250MB for all applied layers per Lambda function per AWS specs.
unzipped_size=`du -h /tmp/lambda_final | tail -n1`

# Begin final packaging
cd /tmp/lambda_final
lambda_package_name="/lambda_layer_`date +%F-%H%M`.zip"
zip -r9 $lambda_package_name *

echo "zipped size: `du -h $lambda_package_name | awk '{print $1}'`"
echo "unzipped size: ${unzipped_size}"
