#!/bin/bash

# set -ex

## run the server
# plackup --reload -MDevel::SimpleTrace --server Starman --workers 2 --port "$DANCER_PORT"

db_file="${TODO_APP_ROOT}/db/${TODO_DB_FILE_ENV}.db"

if [[ ! -e db_file ]]; then
    mkdir -p "${TODO_APP_ROOT}/db"
    touch db_file
fi

var=`date +"%FORMAT_STRING"`
now=`date +"%Y-%m-%d"`

api_log_file="${TODO_APP_ROOT}/log/${now}_api.log"

if [[ ! -e "${api_log_file}" ]]; then
    mkdir -p "${TODO_APP_ROOT}/log"
    touch "${api_log_file}"
fi

access_error_log_file="${TODO_APP_ROOT}/log/${now}_access.log"

if [[ ! -e "${access_error_log_file}" ]]; then
    mkdir -p "${TODO_APP_ROOT}/log"
    touch "${access_error_log_file}" || echo "Failed to create file "
fi

psgi_file="$TODO_APP_ROOT/bin/app.psgi"

echo "Starting server on port $DANCER_PORT"
nohup plackup --reload --server Starman --workers 10 --max-requests 30 --port "$DANCER_PORT" --access-log "$access_error_log_file" --error-log "$access_error_log_file" "$psgi_file" &

tail -f "${api_log_file}" "${access_error_log_file}"