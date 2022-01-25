#!/bin/bash

set -e
set -x

# get release tarball for Common Azure Resource Modules Library

RELEASE_VERSION="0.3.1"
RESOURCE_MODULES_URL="https://github.com/Azure/ResourceModules/archive/refs/tags/v${RELEASE_VERSION}.tar.gz"

mkdir -p ./tmp
wget ${RESOURCE_MODULES_URL} -O ./tmp/download.tar.gz
tar zxvf ./tmp/download.tar.gz
rm -rf ./ResourceModules
mv ./ResourceModules-${RELEASE_VERSION} ./ResourceModules

# deploy

RGNAME="20220111-test-rg"
PASSWORD="ABCabc123456"

az deployment sub create \
    -l japaneast \
    --template-file main.bicep \
    --parameters resourceGroupName=${RGNAME} adminPassword=${PASSWORD}

exit 0
