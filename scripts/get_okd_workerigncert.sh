#!/bin/bash

workerigncert=$(jq '.ignition.security.tls.certificateAuthorities[].source' ./install/worker.ign)

echo -n "{\"workerigncert\":${workerigncert}}"
