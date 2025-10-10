#!/usr/bin/bash

set -e

. .env

echo "Environment: $RACK_ENV"

bundle --path=vendor/bundle
