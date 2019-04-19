#!/bin/bash -e

# Title:                    build_unix_binary_lambda_layer_zip.sh
# Author:                   Justin Holcomb
# Created:                  April 14, 2019
# Version:                  0.0.3
# Description:              Ran from inside Amazon Linux docker/EC2 to generate
#                           zip package to be used as AWS Lambda Layer with
#                           unix binaries.

# https://aws.amazon.com/premiumsupport/knowledge-center/lambda-linux-binary-package/
# https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html
# https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html
# https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html#configuration-layers-path
# https://hub.docker.com/_/amazonlinux/

# docker run -it amazonlinux:2017.03 /bin/bash

mkdir /lambda_packages
cd /lambda_packages
list_of_pkgs_to_install="$@"
echo "List of packages to include: ${list_of_pkgs_to_install}"

if [[ "${list_of_pkgs_to_install}" == "" ]]; then
  exit 1
fi

# Get a list of dependencies need delta-ed from the base installation.
needed_deps=`yum install --assumeno $list_of_pkgs_to_install | grep -A 1000 "Installing for dependencies" | grep -B 1000 "Transaction Summary" | tail -n +1 | head -n -2 | awk '{print $1}' | tr '\n' ' '`

# Download tools needed to unpackage RPM files and repackage as zip.
yum install -y yum-utils rpmdevtools zip

# Download RPM files and dependencies
yumdownloader $list_of_pkgs_to_install $needed_deps

# Remove 32-bit packages
rm -v *i686.rpm

# Extract RPM packages
rpmdev-extract *.rpm

# Delete downloaded packages
rm -v *.rpm

# Make directory for final packaging.
# This structure conforms with the PATHs included in the Lambda environment.
mkdir -vp /tmp/lambda_final/{bin,lib}

# Copy files to final packaging directory.
# find /lambda_packages -type f | xargs -I {} mv -iv {} /tmp/lambda_final
set +e
cp -Rv /lambda_packages/*/usr/bin/* /tmp/lambda_final/bin/
cp -Rv /lambda_packages/*/usr/sbin/* /tmp/lambda_final/bin/
#cp -Rv /lambda_packages/*/usr/lib/* /tmp/lambda_final/lib/
cp -Rv /lambda_packages/*/usr/lib64/* /tmp/lambda_final/lib/
# Remove symlinks
find /tmp/lambda_final/bin -lname '../../usr/libexec/*/*' -type l | xargs rm -v
cp -Rv /lambda_packages/*/usr/libexec/*/* /tmp/lambda_final/bin/
set -e

# Capture unzipped filesize. Needs to be under 250MB for all applied layers per Lambda function per AWS specs.
unzipped_size=`du -h /tmp/lambda_final | tail -n1`

# Begin final packaging
cd /tmp/lambda_final
lambda_package_name="/lambda_layer_`date +%F-%H%M`.zip"
zip -r9 $lambda_package_name *

echo "zipped size: `du -h $lambda_package_name | awk '{print $1}'`"
echo "unzipped size: ${unzipped_size}"
