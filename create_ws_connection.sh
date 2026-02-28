#!/bin/bash

FREQUENCY=100

show_help() {
    echo "Usage:
       bash create_ws_connection.sh -f <frequency> -n <num_topics>

Options:
       -f, --frequency    Frequency of messages in Hz (default: 100)
       -n, --num-topics   Number of topics to publish (not implemented yet)
       -h, --help         Show this help message and exit
    "
}

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
      -h|--help)
         show_help
         exit 0
         ;;
      *)
         echo "Unknown argument: $1"
         exit 1
         ;;
   esac
done

FREQUENCY=$FREQUENCY docker compose -f ./docker/docker-compose.yml up --build