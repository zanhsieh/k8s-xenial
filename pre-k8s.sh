#!/usr/bin/env bash
set -e
cd /vagrant
if [ ! -f "/vagrant/kubectl" ]; then
  curl -O https://storage.googleapis.com/kubernetes-release/release/v1.3.4/bin/linux/amd64/kubectl
fi
if [ ! -d "/vagrant/kube-deploy" ]; then
  git clone https://github.com/kubernetes/kube-deploy.git
fi
