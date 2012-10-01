#!/bin/bash
set -o errexit

echo 'activating virtual env'
source ~/work/rb/bin/activate

echo 'adding settings_local to PYTHONPATH'
export PYTHONPATH=/home/rciorba/work/rb/site/conf:$PYTHONPATH

echo 'starting gunicorn'
gunicorn_django --workers=4 reviewboard.settings --bind=0.0.0.0:8080 --daemon

echo 'done'
