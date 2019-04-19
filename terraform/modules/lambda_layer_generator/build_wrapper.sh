#!/bin/bash -e

build_type=$1
shift
packages_to_include=$@

if [[ "${build_type}" == "unix" ]]; then
  /build_unix_binary_lambda_layer_zip.sh $packages_to_include
elif [[ "${build_type}" == "python36" ]]; then
  /build_python36_modules_lambda_layer.sh $packages_to_include
elif [[ "${build_type}" == "terraform" ]]; then
  /build_terraform_lambda_layer_zip.sh
fi
