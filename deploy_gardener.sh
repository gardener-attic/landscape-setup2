#!/bin/bash -eu

# This is the automated part of the gardener installation. 
# It deploys certificates, helm-tiller, gardener, sets the garden clusters as seed cluster, and installs identity and the gardener dashboard
# Prerequesites: kubify cluster

echo "Setting up the cluster ..."

# should already have happened
# source setup/init.sh

cd components

# kubify - not yet automated
#./deploy.sh kubify

# certificates
./deploy.sh cert

# helm-tiller
./deploy.sh helm-tiller

# gardener
./deploy.sh gardener

# register garden cluster as seed cluster
./deploy.sh seed-config

# identity
./deploy.sh identity

# dashboard 
./deploy.sh dashboard

# certmanager - there's an extra script for that
#./deploy.sh certmanager

cd ..
echo "Gardener successfully deployed!"