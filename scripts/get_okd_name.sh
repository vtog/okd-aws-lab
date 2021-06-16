#!/bin/bash

name=$(jq .infraID ./ignition/metadata.json)

echo -n "{\"name\":${name}}"
