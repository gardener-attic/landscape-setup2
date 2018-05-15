#!/bin/bash -eu

cd components
./deploy.sh kubify
cd ..

echo "Cluster successfully set up!"