#!/bin/bash

USAGE="arg_parse [-h|--help]"

print_help()
{
    echo "[PROGRAM_NAME] - [INFO ABOUT PROGRAM]"
    echo -e "\t$USAGE"
    echo
    echo -e "\tAvailable parameters:"
    echo -e "\t\t[-h|--help]\t print this man."
}

arg_parse ()
{
    if [ "$#" == "0" ]; then
        echo "$USAGE"
        exit 1
    fi

    while (( "$#" )); do
        case "$1" in
            -h|--help)
                print_help
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

arg_parse $@
