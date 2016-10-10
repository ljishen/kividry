#!/bin/bash -e

if [ "$#" -lt 1 ]; then
    cat <<-ENDOFMESSAGE
Please specify at least the output file, the test name and command.
Usage: ./run.sh <output file> --test=<test-name> [options]... <command>

You can use `./sysbench help` (without --test) to display the brief usage summary and the list of available test modes.
ENDOFMESSAGE
    exit
fi

FOLDER_NAME=${FOLDER_NAME:-sysbench}
VERSION=${VERSION:-1.0}
if [ ! -f ${FOLDER_NAME}-${VERSION}/$FOLDER_NAME/sysbench ]; then
    while true; do
        read -p "Do you wish to install SysBench ($VERSION)? [y/n] " yn
        case $yn in
            [Yy]* )
                wget https://github.com/ljishen/kividry/raw/master/benchmark-suite/sysbench/${VERSION}.zip
                unzip ${VERSION}.zip && rm ${VERSION}.zip
                cd ${FOLDER_NAME}-${VERSION}
                ./autogen.sh
                ./configure --without-mysql
                make
                cd ..
                break
                ;;
            [Nn]* )
                exit
                ;;
            *     )
                echo "Please answer yes or no."
                ;;
        esac
    done
fi

out_file="$1"
if [[ "$1" != /* ]]; then
    out_file="../$1"
fi

mkdir -p $(dirname "$1") workdir
cd workdir && ../${FOLDER_NAME}-${VERSION}/$FOLDER_NAME/sysbench "${@:2}" | tee "$out_file" 

# Navigate back to the original path in case people call this script using `source` command.
cd ..
