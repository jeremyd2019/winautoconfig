#!/bin/bash

mkdir -p updates && cd updates
curl https://github.com/jeremyd2019/winautoconfig/wiki/Windows-11-22H2-ARM64-updates | grep -Eo 'https://catalog\.(s\.download\.windowsupdate|sf\.dl\.delivery\.mp\.microsoft)\.com/.*\.msu' | wget -i -
cd ..
genisoimage -iso-level 4 -J -o updates.iso updates/

