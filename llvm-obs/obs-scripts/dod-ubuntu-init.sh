#!/bin/bash
# Generates dod repos for all supported Ubuntu versions in obs

SCRIPT=create-new-build-target.sh

bash $SCRIPT zesty http://archive.ubuntu.com/ubuntu/zesty/main
bash $SCRIPT yakkety http://archive.ubuntu.com/ubuntu/yakkety/main
bash $SCRIPT xenial http://archive.ubuntu.com/ubuntu/xenial/main
bash $SCRIPT wily http://archive.ubuntu.com/ubuntu/wily/main
bash $SCRIPT vivid http://archive.ubuntu.com/ubuntu/vivid/main
bash $SCRIPT utopic http://archive.ubuntu.com/ubuntu/utopic/main
bash $SCRIPT trusty http://archive.ubuntu.com/ubuntu/trusty/main
bash $SCRIPT precise http://archive.ubuntu.com/ubuntu/precise/main
bash $SCRIPT bionic http://archive.ubuntu.com/ubuntu/bionic/main
bash $SCRIPT artful http://archive.ubuntu.com/ubuntu/artful/main
