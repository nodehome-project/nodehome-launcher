#!/bin/bash

nodem -x `date +\%Y\%m\%d\%H\%M\%S` &

/opt/tomcat/bin/catalina.sh run