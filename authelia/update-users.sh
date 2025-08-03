#!/bin/sh
set -eu

root=$(dirname "$0")

cat /home/tug/members/htpasswd | \
    jq --raw-input --slurp --from-file $root/htpasswd-to-authelia.jq > \
    ~containers/authelia/conf/users_database.yml

setfacl --modify=group:containers:rw --modify=user:101000:rw ~containers/authelia/conf/users_database.yml
