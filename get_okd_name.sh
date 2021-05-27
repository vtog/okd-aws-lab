#!/bin/bash

name=$(jq .infraID /home/vince/OKD_v4/install/metadata.json)

echo -n "{\"name\":${name}}"
