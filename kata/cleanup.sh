#!/bin/bash

docker kill $(docker ps -q) &>/dev/null
