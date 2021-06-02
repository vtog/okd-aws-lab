#!/bin/bash

if [[ ! -f ./openshift-install ]]; then
    tar -xzvf openshift-install-linux-4.7.0-0.okd-2021-04-24-103438.tar.gz --exclude='README.md'
else
    echo "openshift-install extracted!"
fi

if [[ -d ./install ]]; then
  rm -rf ./install/
  mkdir -p ./install
else
  mkdir -p ./install
fi

cp  ./okd/install/install-config.yaml ./install/install-config.yaml

printf '  ' >> ./install/install-config.yaml && cat ~/.ssh/id_rsa.pub >> ./install/install-config.yaml

./openshift-install create install-config --dir=install

./openshift-install create manifests --dir=install

rm -f install/openshift/99_openshift-cluster-api_master-machines-*.yaml

rm -f install/openshift/99_openshift-cluster-api_worker-machineset-*.yaml

./openshift-install create ignition-configs --dir=install


