#!/bin/sh

python3 -m venv env
. ./env/bin/activate
pip install -r docs/requirements.txt
deactivate
