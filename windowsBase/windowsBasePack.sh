#!/bin/bash -e

set -o pipefail

export CURR_JOB=$1
export RES_AWS_CREDS=$2
export SHIPPABLE_RELEASE_VERSION="master"

# Now get AWS keys
export RES_AWS_CREDS_UP=$(echo $RES_AWS_CREDS | awk '{print toupper($0)}')
export RES_AWS_CREDS_INT=$RES_AWS_CREDS_UP"_INTEGRATION"

set_context(){

  # now get the AWS keys
  export AWS_ACCESS_KEY_ID=$(eval echo "$"$RES_AWS_CREDS_INT"_ACCESSKEY")
  export AWS_SECRET_ACCESS_KEY=$(eval echo "$"$RES_AWS_CREDS_INT"_SECRETKEY")

  echo "CURR_JOB=$CURR_JOB"
  echo "REGION=$REGION"
  echo "WINRM_USERNAME=${#WINRM_USERNAME}" #print only length not value
  echo "WINRM_PASSWORD=${#WINRM_PASSWORD}" #print only length not value
  echo "AWS_ACCESS_KEY_ID=${#AWS_ACCESS_KEY_ID}" #print only length not value
  echo "AWS_SECRET_ACCESS_KEY=${#AWS_SECRET_ACCESS_KEY}" #print only length not value
}

build_ami() {
  echo "-----------------------------------"
  echo "validating AMI template"
  echo "-----------------------------------"

  packer validate -var aws_access_key=$AWS_ACCESS_KEY_ID \
    -var aws_secret_key=$AWS_SECRET_ACCESS_KEY \
    -var REGION=$REGION \
    -var RES_IMG_VER_NAME_DASH=$SHIPPABLE_RELEASE_VERSION \
    -var WINRM_USERNAME=$WINRM_USERNAME \
    -var WINRM_PASSWORD=$WINRM_PASSWORD \
    windowsBaseAMI.json

  echo "building AMI"
  echo "-----------------------------------"

  packer build -machine-readable -var aws_access_key=$AWS_ACCESS_KEY_ID \
    -var aws_secret_key=$AWS_SECRET_ACCESS_KEY \
    -var REGION=$REGION \
    -var RES_IMG_VER_NAME_DASH=$SHIPPABLE_RELEASE_VERSION \
    -var WINRM_USERNAME=$WINRM_USERNAME \
    -var WINRM_PASSWORD=$WINRM_PASSWORD \
    windowsBaseAMI.json 2>&1 | tee output.txt
}

main() {
  set_context
  build_ami
}

main