#!/bin/bash

masterigncert=$(jq '.ignition.security.tls.certificateAuthorities[].source' ./install/master.ign)

echo -n "{\"masterigncert\":${masterigncert}}"
