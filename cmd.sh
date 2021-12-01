#!/bin/bash

export JAVA_HOME="/etc/alternatives/java_sdk_1.8.0_openjdk"

function atlasSetup(){
  echo "Atlas setup executing ⏳"
  cd /opt/atlas
  ./bin/atlas_start.py -setup
  sleep 600 # allow setup to complete
  echo "Atlas setup completed ✅"
}
function atlasRun(){
  echo "Atlas starting 🚀"
  cd /opt/atlas
  ./bin/atlas_start.py
  echo "Atlas finished ⌛"
}
function sleepLoop(){
  echo "Entering sleep loop 😴"
  while true
    do
      sleep 3600
    done
}

#atlasSetup && atlasRun && sleepLoop;

# currently atlas setup/startup only successfully completes from attached shell
sleepLoop;
