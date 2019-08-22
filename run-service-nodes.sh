#!/bin/bash
#
# Copyright ABC CO. All Rights Reserved
#

script_path_rel=$(dirname "$BASH_SOURCE")
script_path=`readlink -e -n ${script_path_rel}`

source ${script_path}/script/parse-options.sh

set -e

# start
if [ "$1" == 'start' ]; then
  cd ${script_path}/sns-service-runner
  bash docker-run.sh start

  cd ${script_path}/launcher-service-runner
  bash docker-run.sh start
  
  cd ${script_path}/svm-service-runner
  bash docker-run.sh start

  cd ${script_path}/panel-service-runner
  bash docker-run.sh start

  cd ${script_path}/explorer-service-runner
  bash docker-run.sh start

# stop
elif [ "$1" == 'stop' ]; then
  cd ${script_path}/sns-service-runner
  bash docker-run.sh stop

  cd ${script_path}/launcher-service-runner
  bash docker-run.sh stop

  cd ${script_path}/svm-service-runner
  bash docker-run.sh stop

  cd ${script_path}/panel-service-runner
  bash docker-run.sh stop

  cd ${script_path}/explorer-service-runner
  bash docker-run.sh stop

else
  echo "Usage : $0 [start/stop]"
  exit 1
fi


echo "##########################################################################"
echo "##                    successfully completed                            ##"
echo "##########################################################################"
