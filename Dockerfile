# Copyright 2017 The Gardener Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# --- ATTENTION ---
# This needs to be run with the surrounding git image mounted
# example: docker run -it -v $(pwd):/home/gardener/ <IMAGE_NAME>

FROM ubuntu:16.04

RUN apt-get update && apt-get install -y jq gnupg2 python python-mako curl \
    zip unzip git iputils-ping python-pip apache2-utils vim bash-completion && \
    curl -L "https://github.com/bronze1man/yaml2json/raw/master/builds/linux_amd64/yaml2json" -o /usr/local/bin/yaml2json && \
    curl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o /usr/local/bin/cfssl && \
    curl https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o /usr/local/bin/cfssljson && \
    curl https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin && rm terraform.zip && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    mv kubectl /usr/local/bin && \
    git clone https://github.com/yaml/pyyaml.git pyyaml && cd pyyaml && \
    python setup.py --without-libyaml install && \
    cd .. && rm -rf pyyaml && \
    curl -O https://kubernetes-helm.storage.googleapis.com/helm-v2.8.2-linux-amd64.tar.gz && \
    tar xfv helm-*linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin && rm -rf linux-amd64 && \
    chmod 755 /usr/local/bin/*
