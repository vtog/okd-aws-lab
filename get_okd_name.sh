#!/bin/bash

name=$(jq .infraID ./install/metadata.json)

echo -n "{\"name\":${name}}"
