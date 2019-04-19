#!/bin/bash -e

# Title:                    build_python36_modules_lambda_layer.sh
# Author:                   Justin Holcomb
# Created:                  January 26, 2019
# Version:                  0.0.2
# Description:              Ran from inside Amazon Linux docker/EC2 to generate
#                           zip package to be used as AWS Lambda Layer with
#                           Python 3.6 modules.

# https://aws.amazon.com/premiumsupport/knowledge-center/lambda-linux-binary-package/
# https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html
# https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html
# https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html#configuration-layers-path
# https://hub.docker.com/_/amazonlinux/

# docker run -it amazonlinux:2017.03 /bin/bash

list_of_pkgs_to_install="$@"
echo "List of Python 3.6 modules to include: ${list_of_pkgs_to_install}"

# Download tools needed to unpackage RPM files and repackage as zip.
yum install -y python36 python36-pip zip wget jq aws-cli

python3 -m pip install --user --no-cache-dir --compile ${list_of_pkgs_to_install}

# Make directory for final packaging.
# This structure conforms with the PATHs included in the Lambda environment.
mkdir -vp /tmp/lambda_final/python

# Copy Python packages to location to be zipped.
chmod -R 755 /root/.local/lib
mv -v /root/.local/lib /tmp/lambda_final/python/
#cp -Rv /root/.local/lib/python3.6/site-packages/* /tmp/lambda_final/python/lib/python3.6/dist-packages/
#cp -Rv /root/.local/lib64/python3.6/site-packages/* /tmp/lambda_final/python/lib/python3.6/dist-packages/
#cp -Rv /usr/lib/python3.6/dist-packages/* /tmp/lambda_final/python/lib/python3.6/dist-packages/
#cp -Rv /usr/lib64/python3.6/dist-packages/* /tmp/lambda_final/python/lib/python3.6/dist-packages/

# Capture unzipped filesize. Needs to be under 250MB for all layers per AWS specs.
unzipped_size=`du -h /tmp/lambda_final | tail -n1`
echo "unzipped size: ${unzipped_size}"

# Begin final packaging
cd /tmp/lambda_final
lambda_package_name="lambad_layer_python36_`date +%F-%H%M`.zip"
zip -r9 /$lambda_package_name *

echo "zipped size: `du -h $lambda_package_name | awk '{print $1}'`"
echo "unzipped size: ${unzipped_size}"
