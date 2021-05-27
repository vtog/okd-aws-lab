#!/bin/bash

mkdir -p ./install

printf '  ' >> install-config.yaml && cat ~/.ssh/id_rsa.pub >> install-config.yaml

cp ./install-config.yaml ./install

./openshift-install create install-config --dir=install

./openshift-install create manifests --dir=install

rm -f install/openshift/99_openshift-cluster-api_master-machines-*.yaml

rm -f install/openshift/99_openshift-cluster-api_worker-machineset-*.yaml

./openshift-install create ignition-configs --dir=install


