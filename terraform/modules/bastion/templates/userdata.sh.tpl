#!/bin/bash
set -o errexit
set -o nounset

apt-get -q update
apt-get -qy install awscli
