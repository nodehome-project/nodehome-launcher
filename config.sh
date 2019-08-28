#!/bin/bash
#
# Copyright ABC CO. All Rights Reserved
#

script_path_rel=$(dirname "$BASH_SOURCE")
script_path=`readlink -e -n ${script_path_rel}`

source ${script_path}/script/parse-options.sh

###################################################################################################################################
## config.sh
## Copyright (C) ABC
##
## bash config.sh [option] action(run)
##
## Options:
##      -h, --help                                      Show help
#           --network-type='dev'                        network type(dev/test/biz)
#           --chain-id='NHDEVNET08'                     chain id
##          --seed-ip=127.0.0.1                         seed server IP
##          --seed-port=7070                            seed port
##          --launcher-ip=127.0.0.1                     launcher IP
##          --launcher-port=7080                        launcher port
##          --launcher-nodem-port=18880                 launcher nodem port
##          --na-ip=127.0.0.1                           na server IP
##          --na-port=8050                              na server port
##          --nodehome-service-ip=127.0.0.1             nodehome service IP
##          --nodehome-service-port=7081                nodehome service port
##          --nodehome-nodem-port=18881                 nodehome nodem port
##
###################################################################################################################################
set -e

# Version
# nodehome=$(../nodehome-blockchain/bin/workbench-cli -cmd=execQuery -queryType=query -func=version -netName=dev -chainName=ecchain -svrURL=http://127.0.0.1:8050/chaincode_query)
# network_type=$(echo "${nodehome}" | jq --raw-output '.value.network')
# chain_id=$(echo "${nodehome}" | jq --raw-output '.value.chain_id')

network_type=$(cat ../nodehome-blockchain/.config | grep network_type | cut -d "=" -f2)
chain_id=$(cat ../nodehome-blockchain/.config | grep chain_id | cut -d "=" -f2)
create_date=`date +\%Y\%m\%d\%H\%M\%S`
seed_ip=127.0.0.1
seed_port=7070
launcher_ip=127.0.0.1
launcher_port=7080
launcher_nodem_port=18880
na_ip=127.0.0.1
na_port=8050
nodehome_service_ip=127.0.0.1
nodehome_service_port=7081
nodehome_nodem_port=18881
man300_key=$(cat ../nodehome-blockchain/wallets/prik/man300.key | grep key | cut -d ":" -f2)
manService_pubk_key=$(cat ../nodehome-blockchain/wallets/pubk/manService.key | grep key | cut -d ":" -f2)
issueWallet_pubk_key=$(cat ../nodehome-blockchain/wallets/pubk/issueWallet.key | grep key | cut -d ":" -f2)
issueWallet_prik_key=$(cat ../nodehome-blockchain/wallets/prik/issueWallet.key | grep key | cut -d ":" -f2)

# network type
if [ ${network_type} == "dev" ]; then
network_name=DEV
elif [ ${network_type} == "test" ]; then
network_name=TEST
elif [ ${network_type} == "biz" ]; then
network_name=BIZ
else
network_name=DEV
fi


# Service add
jsonRet=$(../nodehome-blockchain/bin/workbench-cli -cmd=execQuery -queryType=query -func=getServiceInfo -netName=${network_type} -chainID=${chain_id} -chainName=ecchain -prikFile=../nodehome-blockchain/wallets/prik/man300.key -svrURL=http://127.0.0.1:8050/chaincode_query -args="[\"PID\",\"10000\",\"nhlauncher\"]")
ec=$(echo ${jsonRet} | jq '.ec')
if [ $ec -ne 0 ]; then
  jsonRet2=$(../nodehome-blockchain/bin/workbench-cli -cmd=execQuery -queryType=invoke -func=registerService -netName=${network_type} -chainID=${chain_id} -chainName=ecchain -prikFile=../nodehome-blockchain/wallets/prik/manService.key -svrURL=http://127.0.0.1:8050/chaincode_query -args="[\"PID\",\"10000\",\"nhlauncher\",\"{\\\"stopMessage\\\":\\\"\\\",\\\"svrVersion\\\":\\\"0.9.1\\\",\\\"service_id\\\":\\\"nhlauncher\\\",\\\"serviceNm\\\":\\\"nhlauncher\\\",\\\"state\\\":\\\"A\\\",\\\"serviceId\\\":\\\"nhlauncher\\\"}\"]")
  ec2=$(echo ${jsonRet2} | jq '.ec')
  if [ $ec2 -ne 0 ]; then
    msg2=$(echo ${jsonRet2} | jq '.ref')
    echo "Chaincode error($ec2) : $msg2"
    exit 0
  fi
fi

jsonRet=$(../nodehome-blockchain/bin/workbench-cli -cmd=execQuery -queryType=query -func=getServiceInfo -netName=${network_type} -chainID=${chain_id} -chainName=ecchain -prikFile=../nodehome-blockchain/wallets/prik/man300.key -svrURL=http://127.0.0.1:8050/chaincode_query -args="[\"PID\",\"10000\",\"nodehome\"]")
ec=$(echo ${jsonRet} | jq '.ec')
if [ $ec -ne 0 ]; then
  jsonRet2=$(../nodehome-blockchain/bin/workbench-cli -cmd=execQuery -queryType=invoke -func=registerService -netName=${network_type} -chainID=${chain_id} -chainName=ecchain -prikFile=../nodehome-blockchain/wallets/prik/manService.key -svrURL=http://127.0.0.1:8050/chaincode_query -args="[\"PID\",\"10000\",\"nodehome\",\"{\\\"stopMessage\\\":\\\"\\\",\\\"svrVersion\\\":\\\"0.9.1\\\",\\\"service_id\\\":\\\"nodehome\\\",\\\"serviceNm\\\":\\\"nodehome\\\",\\\"state\\\":\\\"A\\\",\\\"serviceId\\\":\\\"nodehome\\\"}\"]")
  ec2=$(echo ${jsonRet2} | jq '.ec')
  if [ $ec2 -ne 0 ]; then
    msg2=$(echo ${jsonRet2} | jq '.ref')
    echo "Chaincode error($ec2) : $msg2"
    exit 0
  fi
fi


function set_config {
  #seed
  sed -i "s/SEED_PORT/${seed_port}/g" ${script_path}/sns-service-runner/docker-compose.yaml

  sed -i "s/NA_URL/${na_ip}:${na_port}/g" ${script_path}/sns-service-runner/config/props/globals.properties
  sed -i "s/CHAIN_ID/${chain_id}/g" ${script_path}/sns-service-runner/config/props/globals.properties
  
  sed -i "s/LAUNCHER_IP/${launcher_ip}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nhlauncher.properties
  sed -i "s/LAUNCHER_URL/${launcher_ip}:${launcher_port}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nhlauncher.properties
  sed -i "s/LAUNCHER_NODEM_PORT/${launcher_nodem_port}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nhlauncher.properties
  sed -i "s/LAUNCHER_NODEM_DATE/${create_date}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nhlauncher.properties

  sed -i "s/NODEHOME_IP/${nodehome_service_ip}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nodehome.properties
  sed -i "s/NODEHOME_URL/${nodehome_service_ip}:${nodehome_service_port}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nodehome.properties
  sed -i "s/NODEHOME_NODEM_PORT/${nodehome_nodem_port}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nodehome.properties
  sed -i "s/NODEHOME_NODEM_DATE/${create_date}/g" ${script_path}/sns-service-runner/config/hosts/hosts-nodehome.properties


  #launcher
  sed -i "s/LAUNCHER_PORT/${launcher_port}/g" ${script_path}/launcher-service-runner/docker-compose.yaml
  sed -i "s/LAUNCHER_NODEM_PORT/${launcher_nodem_port}/g" ${script_path}/launcher-service-runner/docker-compose.yaml

  sed -i "s/LAUNCHER_URL/${launcher_ip}:${launcher_port}/g" ${script_path}/launcher-service-runner/config/props/globals.properties
  sed -i "s/ISSUEWALLET_PUBK_KEY/${issueWallet_pubk_key}/g" ${script_path}/launcher-service-runner/config/props/globals.properties
  sed -i "s/ISSUEWALLET_PRIK_KEY/${issueWallet_prik_key}/g" ${script_path}/launcher-service-runner/config/props/globals.properties

  touch ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "//=============================" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "// NODEHOME KEY FILE" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "//=============================" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "ver:1.0" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "type:private" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "net:${network_type}net" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "key:${man300_key}" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "//=============================" >> ${script_path}/launcher-service-runner/config/props/man300-${chain_id}-${network_type}.key

  touch ${script_path}/launcher-service-runner/config/hosts/host-${chain_id}.properties
  echo "# `date +\%Y\%m\%d\%H\%M\%S`|${manService_pubk_key}|http://${seed_ip}:${seed_port}" >> ${script_path}/launcher-service-runner/config/hosts/host-${chain_id}.properties
  echo "http://${launcher_ip}:${launcher_port}|${launcher_ip}|${launcher_nodem_port}" >> ${script_path}/launcher-service-runner/config/hosts/host-${chain_id}.properties

  touch ${script_path}/launcher-service-runner/config/hosts/na-${chain_id}.properties
  echo "http://${na_ip}:${na_port}" >> ${script_path}/launcher-service-runner/config/hosts/na-${chain_id}.properties


  #nodehome-service
  sed -i "s/NODEHOME_PORT/${nodehome_service_port}/g" ${script_path}/svm-service-runner/docker-compose.yaml
  sed -i "s/NODEHOME_NODEM_PORT/${nodehome_nodem_port}/g" ${script_path}/svm-service-runner/docker-compose.yaml

  sed -i "s/NODEHOME_URL/${nodehome_service_ip}:${nodehome_service_port}/g" ${script_path}/svm-service-runner/config/props/globals.properties

  touch ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "//=============================" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "// NODEHOME KEY FILE" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "//=============================" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "ver:1.0" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "type:private" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "net:${network_type}net" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "key:${man300_key}" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key
  echo "//=============================" >> ${script_path}/svm-service-runner/config/props/man300-${chain_id}-${network_type}.key

  touch ${script_path}/svm-service-runner/config/hosts/host-${chain_id}.properties
  echo "# `date +\%Y\%m\%d\%H\%M\%S`|${manService_pubk_key}|http://${seed_ip}:${seed_port}" >> ${script_path}/svm-service-runner/config/hosts/host-${chain_id}.properties
  echo "http://${nodehome_service_ip}:${nodehome_service_port}|${nodehome_service_ip}|${nodehome_nodem_port}" >> ${script_path}/svm-service-runner/config/hosts/host-${chain_id}.properties

  touch ${script_path}/svm-service-runner/config/hosts/na-${chain_id}.properties
  echo "http://${na_ip}:${na_port}" >> ${script_path}/svm-service-runner/config/hosts/na-${chain_id}.properties
  
}

# 옵션 파싱
parse_options "$@"


# 파라메터가 없으면 종료
if [ ${#arguments[@]} -lt 1 ]; then
	parse_documentation
	echo "$documentation"
	exit 0
fi

action=${arguments[0]}

if [[ "$action" == 'run' ]]; then
  # ip check
  if [ ${seed_ip} == "127.0.0.1" ] || [ ${seed_ip} == "localhost" ]; then
    echo "seed ip '${seed_ip}' or 'localhost' not allowed"
    exit 1
  fi
  if [ ${launcher_ip} == "127.0.0.1" ] || [ ${launcher_ip} == "localhost" ]; then
    echo "launcher ip '${seed_ip}' or 'localhost' not allowed"
    exit 1
  fi
  if [ ${na_ip} == "127.0.0.1" ] || [ ${na_ip} == "localhost" ]; then
    echo "na ip '${seed_ip}' or 'localhost' not allowed"
    exit 1
  fi
  if [ ${nodehome_service_ip} == "127.0.0.1" ] || [ ${nodehome_service_ip} == "localhost" ]; then
    echo "nodehomeService ip '${seed_ip}' or 'localhost' not allowed"
    exit 1
  fi
  
  # runner rm
  if [ -d ${script_path}/sns-service-runner ]; then
    sudo rm -rf ${script_path}/sns-service-runner
  fi
  if [ -d ${script_path}/launcher-service-runner ]; then
    sudo rm -rf ${script_path}/launcher-service-runner
  fi
  if [ -d ${script_path}/svm-service-runner ]; then
    sudo rm -rf ${script_path}/svm-service-runner
  fi
  
  # runner cp
  cp -r ${script_path}/template/* ${script_path}/
  
  # run
  set_config
fi


echo "##########################################################################"
echo "##                    successfully completed                            ##"
echo "##########################################################################"
