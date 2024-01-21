#!/bin/sh

./create_runner.py
xorrisofs -r -J -o ../setup.iso ../setupscripts/
powershell -File hyperv.ps1 $1 $2
