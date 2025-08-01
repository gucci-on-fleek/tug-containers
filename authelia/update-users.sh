#!/bin/sh
set -eu

root=$(dirname "$0")

cat /home/tug/members/htpasswd | \
    jq --raw-input --slurp --from-file $root/htpasswd-to-authelia.jq > \
    /home/containers/authelia/conf/users_database.yml
