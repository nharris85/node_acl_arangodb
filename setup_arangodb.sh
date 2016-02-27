#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

VERSION=2.8.3
NAME=ArangoDB-$VERSION

if [ ! -d "$DIR/$NAME" ]; then
  # download ArangoDB
  wget https://www.arangodb.com/repositories/travisCI/$NAME.tar.gz
  tar zxf $NAME.tar.gz
fi

PID=$(echo $PPID)
TMP_DIR="/tmp/arangodb.$PID"
PID_FILE="/tmp/arangodb.$PID.pid"
ARANGODB_DIR="$DIR/$NAME"

# create database directory
mkdir ${TMP_DIR}

${ARANGODB_DIR}/bin/arangod \
    --database.directory ${TMP_DIR}  \
    --log.file ${TMP_DIR}/arangodb.log \
    --javascript.app-path ${ARANGODB_DIR}/js/apps \
    --server.endpoint tcp://127.0.0.1:8529 \
    --database.maximal-journal-size 1048576  \
    --server.disable-authentication true \
    --javascript.gc-interval 1 &

echo "Waiting until ArangoDB is ready on port 8529"
while [[ -z `curl -s 'http://127.0.0.1:8529/_api/version' ` ]] ; do
  echo -n "."
  sleep 2s
done

echo "ArangoDB is up"
