#!/bin/bash

# Adapted from: https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
# Add local user and group
# Either use the LOCAL_USER_ID and LOCAL_GROUP_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-0}
GROUP_ID=${LOCAL_GROUP_ID:-0}

echo "Starting with UID / GID = $USER_ID / $GROUP_ID"
groupadd -g $GROUP_ID -o bgw
useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m bgw
export HOME=/home/bgw
echo 'ulimit -s unlimited' >> $HOME/.bashrc
ulimit -s unlimited

#exec /usr/local/bin/su-exec bgw "$@"
/usr/local/bin/su-exec bgw "$@"
