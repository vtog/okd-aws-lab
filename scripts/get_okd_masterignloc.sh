#!/bin/bash

masterignloc=$(jq '.ignition.config.merge[].source' ./install/master.ign)

echo -n "{\"masterignloc\":${masterignloc}}"
