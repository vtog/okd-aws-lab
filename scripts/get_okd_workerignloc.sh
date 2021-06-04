#!/bin/bash

workerignloc=$(jq '.ignition.config.merge[].source' ./install/worker.ign)

echo -n "{\"workerignloc\":${workerignloc}}"
