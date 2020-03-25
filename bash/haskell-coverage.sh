#!/bin/bash

printUsage()
{
    echo "haskell-coverage.sh --dir DIRNAME --output FILENAME"
    echo -e "\t-t|--tix-dir: directory with *.tix files. Default $PWD."
    echo -e "\t-o|--output: output directory for html report. Default $PWD."
    echo -e "\t-r|--root: root directory with haskell project. Default $PWD."
}

makeAbsolutePath()
{
    realpath "$1"
}

ROOT="${PWD}"
OUTPUT="${PWD}"
TIXDIR="${PWD}"
parseArgs()
{
    opts=$(getopt -o t:r:o: --long tix-dir: --long root: --long output: -- "$@")
    if [ $? -ne 0 ]; then
        echo "Incorrect option provided"
        printUsage
        exit 1
    fi

    eval set -- "${opts}"
    while true; do
        case "$1" in
        -t|--tix-dir)
            shift;
            TIXDIR="$(makeAbsolutePath "$1")"
            ;;
        -r|--root)
            shift;
            ROOT="$(makeAbsolutePath "$1")"
            ;;
        -o|--output)
            shift;
            OUTPUT="$(makeAbsolutePath "$1")"
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done
}

createHpcHtmlReport()
{
    cd "${ROOT}" && stack hpc report "${TIXDIR}"/*.tix --destdir "${OUTPUT}"
}

main()
{
    parseArgs "$@"
    createHpcHtmlReport
}

main "$@"
