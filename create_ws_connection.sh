#!/bin/bash

FREQUENCY=200

while [[ $# -gt 0 ]]; do
   case $1 in
      -f=*|--frequency=*)
         FREQUENCY="${1#*=}"
         shift
         ;;
      -n=*|--num-topics=*)
         NUM_TOPICS="${1#*=}"
         shift
         ;;
      *)
         echo "Unknown argument: $1"
         exit 1
         ;;
   esac
done

FREQUENCY=$FREQUENCY docker compose -f ./docker/docker-compose.yml up --build