#!/bin/bash

cd "local-runner"
./local-runner.sh

sleep 3

cd ../
ruby runner.rb

