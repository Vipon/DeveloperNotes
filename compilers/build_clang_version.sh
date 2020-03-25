#!/bin/bash

TRUE="true"
FALSE="false"

USAGE="build_clang -j [NUM_THREADS] -llvm [PATH_TO_SOURCE] -build [WHERE_BUILD]"
NUM_THREADS=1

VERSION=7.0.1
LLVM_PATH=${PWD}/llvm
BUILD_PATH=${PWD}/build

DOWNLOAD_PATH=${PWD}/download
PUBLIC_KEY=tstellar-gpg-key.asc

LLD=${FALSE}
TEST=${FALSE}
LIBCXX=${FALSE}
COMP_RT=${FALSE}
BUILD_TYPE=Release
CROSSCOMPILING=False
LLVM_TARGETS_TO_BUILD=""

check_utils()
{
    # Check exesting of wget
    if [ `which wget` == "" ]; then
        echo "ERROR: There is no wget."
        exit -1
    fi

    # Check exesting of tar
    if [ `which tar` == "" ]; then
        echo "ERROR: There is no tar."
        exit -1
    fi

    # Check exesting of xz
    if [ `which xz` == "" ]; then
        echo "ERROR: There is no xz."
        exit -1
    fi

    # Check exesting of gpg
    if [ `which gpg` == "" ]; then
        echo "ERROR: There is no gpg."
        exit -1
    fi

    # Check exesting of cmake
    if [ `which cmake` == "" ]; then
        echo "ERROR: There is no cmake."
        exit -1
    fi

    # Check exesting of make
    if [ `which make` == "" ]; then
        echo "ERROR: There is no make."
        exit -1
    fi

    return 0
}


print_help()
{
    echo -e "$USAGE"
    echo
    echo -e "Available parameters:"
    echo -e "\t[-j NUM_THREADS]\t set number of threads for make."
    echo -e "\t[--debug]\t\t make debug build."
    echo -e "\t[--cross-compile]\t build compiler for cross-compiling."
    echo -e "\t[-llvm]\t\t\t path to llvm source code."
    echo -e "\t[-build]\t\t where whould be build."
    echo -e "\t[--full]\t\t build everything."
    echo -e "\t[-lld]\t\t\t built lld."
    echo -e "\t[-libcxx]\t\t built libcxx."
    echo -e "\t[--comp-rt]\t\t built compiler-rt."
    echo -e "\t[-t|--test]\t\t test clang."
    echo -e "\t[-h|--help]\t\t print this man."
}


arg_parse ()
{
    while (( "$#" )); do
        case "$1" in
            -j)
                NUM_THREADS=$2
                echo "NUM_THREADS:" $NUM_THREADS
                shift 2
                ;;

            --debug)
                echo "BUILD_TYPE=Debug"
                BUILD_TYPE=Debug
                shift 1
                ;;

            --cross-compile)
                echo "CROSSCOMPILING=True"
                CROSSCOMPILING=True
                LLVM_TARGETS_TO_BUILD="X86;PowerPC;ARM;AArch64;Mips"
                shift 1
                ;;

            -llvm)
                if [ "$2" == "" ]; then
                    echo "ERROR: there is no path to source code."
                    exit -1
                elif [ "${2:0:1}" == "/" ]; then
                    # absolute path
                    LLVM_PATH=$2
                else
                    # relative path
                    LLVM_PATH=${PWD}/$2
                fi
                echo "LLVM_PATH: " ${LLVM_PATH}
                shift 2
                ;;

            -build)
                if [ "$2" == "" ]; then
                    echo "ERROR: there is no path for build."
                    exit -1
                elif [ "${2:0:1}" == "/" ]; then
                    # absolute path
                    BUILD_PATH=$2
                else
                    # relative path
                    BUILD_PATH=${PWD}/$2
                fi
                echo "BUILD_PATH: " ${BUILD_PATH}
                shift 2
                ;;

            --full)
                LLD=${TRUE}
                LIBCXX=${TRUE}
                COMP_RT=${TRUE}
                shift
                ;;

            -lld)
                LLD=${TRUE}
                shift
                ;;

            -libcxx)
                LIBCXX=${TRUE}
                shift
                ;;

            --comp-rt)
                COMP_RT=${TRUE}
                shift
                ;;

            -t|--test)
                TEST=${TRUE}
                shift
                ;;

            -h|--help)
                print_help
                exit 0
                ;;

            *)
                shift
                ;;
        esac
    done

    return 0
}


download_public_key()
{
    if [ -f ${DOWNLOAD_PATH}/.download_public_key_success ]; then
        return 0
    fi

    wget http://releases.llvm.org/${VERSION}/${PUBLIC_KEY} -P ${DOWNLOAD_PATH}
    if [ "$?" != "0" ]; then
        PUBLIC_KEY=hans-gpg-key.asc
        wget http://releases.llvm.org/${VERSION}/${PUBLIC_KEY} -P ${DOWNLOAD_PATH}
        if [ "$?" != "0" ]; then
            echo "ERROR: cann't download public key."
            exit -1
        fi
    fi

    gpg --import ${DOWNLOAD_PATH}/${PUBLIC_KEY}
    if [ "$?" != "0" ]; then
        echo "ERROR: cann't import public key."
        exit -1
    fi

    touch ${DOWNLOAD_PATH}/.download_public_key_success
    return 0
}


download_and_check()
{
    TOOL=$1
    if [ -f ${DOWNLOAD_PATH}/.download_${TOOL}_success ]; then
        return 0
    fi

    wget http://releases.llvm.org/${VERSION}/${TOOL}-${VERSION}.src.tar.xz -P ${DOWNLOAD_PATH}
    if [ "$?" != "0" ]; then
        echo "ERROR: cann't download $TOOL."
        exit -1
    fi

    wget http://releases.llvm.org/${VERSION}/${TOOL}-${VERSION}.src.tar.xz.sig -P ${DOWNLOAD_PATH}
    if [ "$?" != "0" ]; then
        echo "ERROR: cann't download signature for $TOOL."
        exit -1
    fi

    gpg --verify ${DOWNLOAD_PATH}/${TOOL}-${VERSION}.src.tar.xz.sig ${DOWNLOAD_PATH}/${TOOL}-${VERSION}.src.tar.xz
    if [ "$?" != "0" ]; then
        echo "ERROR: cann't verify $TOOL."
        exit -1
    fi

    touch ${DOWNLOAD_PATH}/.download_${TOOL}_success
    return 0
}


download_source_code()
{
    mkdir -p ${DOWNLOAD_PATH}

    download_public_key
    download_and_check llvm
    #clang
    download_and_check cfe
    if [ ${COMP_RT} == ${TRUE} ]; then
    download_and_check compiler-rt
    fi
    if [ ${LLD} == ${TRUE} ]; then
    download_and_check lld
    fi
    if [ ${LIBCXX} == ${TRUE} ]; then
    download_and_check libcxx
    download_and_check libcxxabi
    fi

    return 0
}


extract_to_dir()
{
    TOOL=$1
    DIR=$2

    if [ ! -f ${DIR}/.extract_${TOOL}_success ]; then
        tar -xJvf ${DOWNLOAD_PATH}/${TOOL}-${VERSION}.src.tar.xz
        if [ -d ${DIR} ]; then
            rm -rf ${DIR}
        fi
        mv ${TOOL}-${VERSION}.src ${DIR}
        touch ${DIR}/.extract_${TOOL}_success
    fi

    return 0
}


extract_source_code()
{
    extract_to_dir llvm ${LLVM_PATH}
    # clang
    extract_to_dir cfe ${LLVM_PATH}/tools/clang
    if [ ${COMP_RT} == ${TRUE} ]; then
    extract_to_dir compiler-rt ${LLVM_PATH}/projects/compiler-rt
    fi
    if [ ${LLD} == ${TRUE} ]; then
    extract_to_dir lld ${LLVM_PATH}/tools/lld
    fi
    if [ ${LIBCXX} == ${TRUE} ]; then
    extract_to_dir libcxx ${LLVM_PATH}/projects/libcxx
    extract_to_dir libcxxabi ${LLVM_PATH}/projects/libcxxabi
    fi

    return 0
}


build_code()
{
    mkdir -p ${BUILD_PATH}
    cd ${BUILD_PATH}

    # Set up LDFLAGS, CFLAGS and CXXFLAGS, beacuse they must be empty.
    OLD_LDFLAGS=$LDFLAGS
    echo "OLDLDFLAGS: $LDFLAGS"
    LDFLAGS=""
    export LDFLAGS
    echo "NEWLDFLAGS: $LDFLAGS"

    OLD_CFLAGS=$CFLAGS
    echo "OLDCFLAGS: $CFLAGS"
    CFLAGS=""
    export CFLAGS
    echo "NEWCFLAGS: $CFLAGS"

    OLD_CXXFLAGS=$CXXFLAGS
    echo "OLDCXXFLAGS: $CXXFLAGS"
    CXXFLAGS=""
    export CXXFLAGS
    echo "NEWCXXFLAGS: $CXXFLAGS"

    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DCMAKE_CROSSCOMPILING=${CROSSCOMPILING} -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD} ${LLVM_PATH}
    if [ "$?" != "0" ]; then
        echo "ERROR: llvm cmake."
        exit -1
    fi

    make -j${NUM_THREADS}
    if [ "$?" != "0" ]; then
        echo "ERROR: llvm make."
        exit -1
    fi

    # Restore LDFLAGS, CFLAGS and CXXFLAGS.
    LDFLAGS=$OLD_LDFLAGS
    export LDFLAGS
    echo "LDFLAGS: $LDFLAGS"
    CFLAGS=$OLD_CFLAGS
    export CFLAGS
    echo "CFLAGS: $CFLAGS"
    CXXFLAGS=$OLD_CXXFLAGS
    export CXXFLAGS
    echo "CXXFLAGS: $CXXFLAGS"
    return 0
}


clang_test()
{
    if [ ! -d ${BUILD_PATH} ]; then
        build_code
    fi

    cd ${BUILD_PATH}
    make -j${NUM_THREADS} check-clang
    return $?
}


main()
{
    check_utils
    arg_parse $@
    download_source_code
    extract_source_code
    if [ ${TEST} == ${TRUE} ]; then
        clang_test
    else
        build_code
    fi

    exit $?
}

main $@

