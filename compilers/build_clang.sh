#!/bin/bash

TRUE="true"
FALSE="false"

USAGE="arg_parse -j [NUM_THREADS] -llvm [PATH_TO_SOURCE] -build [WHERE_BUILD]"
NUM_THREADS=1

LLVM_PATH=$PWD/llvm/
BUILD_PATH=$PWD/build/

LLD=$FALSE
TEST=$FALSE
LIBCXX=$FALSE
COMP_RT=$FALSE
BUILD_TYPE=Release

check_utils()
{
    # Check exesting of make
    if [ `which git` == "" ]; then
        echo "ERROR: There is no git."
        exit -1
    fi

    # Check exesting of make
    if [ `which make` == "" ]; then
        echo "ERROR: There is no make."
        exit -1
    fi

    # Check exesting of cmake
    if [ `which cmake` == "" ]; then
        echo "ERROR: There is no cmake."
        exit -1
    fi
}


print_help()
{
    echo -e "$USAGE"
    echo
    echo -e "Available parameters:"
    echo -e "\t[-j NUM_THREADS]\t set number of threads for make."
    echo -e "\t[--debug]\t\t make debug build."
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
                shift 2
                ;;

            --debug)
                BUILD_TYPE=Debug
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
                    LLVM_PATH=$PWD/$2
                fi
                echo "LLVM_PATH: " $LLVM_PATH
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
                    BUILD_PATH=$PWD/$2
                fi
                echo "BUILD_PATH: " $BUILD_PATH
                shift 2
                ;;

            --full)
                LLD=$TRUE
                LIBCXX=$TRUE
                COMP_RT=$TRUE
                shift
                ;;

            -lld)
                LLD=$TRUE
                shift
                ;;

            -libcxx)
                LIBCXX=$TRUE
                shift
                ;;

            --comp-rt)
                COMP_RT=$TRUE
                shift
                ;;

            -t|--test)
                TEST=$TRUE
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
}


download_llvm()
{
    if [ -f $LLVM_PATH/.git_success ]; then
        return 0
    fi

    mkdir -p $LLVM_PATH

    git clone https://git.llvm.org/git/llvm.git/ $LLVM_PATH
    if [ "$?" != "0" ]; then
        echo "ERROR: git clone https://git.llvm.org/git/llvm.git/."
        exit -1
    fi

    touch $LLVM_PATH/.git_success
}


download_clang()
{
    cd $LLVM_PATH/tools
    if [ -f clang/.git_success ]; then
        return 0
    fi

    git clone https://git.llvm.org/git/clang.git/ clang/
    if [ "$?" != "0" ]; then
        echo "ERROR: git clone https://git.llvm.org/git/clang.git/."
        exit -1
    fi

    touch clang/.git_success
}


download_libcxx()
{
    cd $LLVM_PATH/projects/
    if [ ! -f libcxx/.git_success ]; then
        git clone https://git.llvm.org/git/libcxx.git/ libcxx/
        if [ "$?" != "0" ]; then
            echo "ERROR: git clone https://git.llvm.org/git/libcxx.git/."
            exit -1
        fi
    fi

    touch libcxx/.git_success
    if [ -f libcxxabi/.git_success ]; then
        return 0
    fi

    git clone https://git.llvm.org/git/libcxxabi.git/ libcxxabi/
    if [ "$?" != "0" ]; then
        echo "ERROR: git clone https://git.llvm.org/git/libcxxabi.git/."
        exit -1
    fi

    touch libcxxabi/.git_success
}

download_compiler_rt()
{
    cd $LLVM_PATH/projects/
    if [ ! -f compiler-rt/.git_success ]; then
        git clone https://git.llvm.org/git/compiler-rt.git/ compiler-rt/
        if [ "$?" != "0" ]; then
            echo "ERROR: git clone https://git.llvm.org/git/compiler-rt.git/."
            exit -1
        fi
    fi

    touch compiler-rt/.git_success
}

download_lld()
{
    cd $LLVM_PATH/tools/
    if [ ! -f lld/.git_success ]; then
        git clone https://git.llvm.org/git/lld.git/ lld/
        if [ "$?" != "0" ]; then
            echo "ERROR: git clone https://git.llvm.org/git/lld.git/."
            exit -1
        fi
    fi

    touch lld/.git_success
}

download_source_code()
{
    download_llvm
    download_clang
    if [ $COMP_RT == $TRUE ]; then
    download_compiler_rt
    fi
    if [ $LLD == $TRUE ]; then
    download_lld
    fi
    if [ $LIBCXX == $TRUE ]; then
        download_libcxx
    fi
}


build_code()
{
    mkdir -p $BUILD_PATH
    cd $BUILD_PATH

    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE $LLVM_PATH
    if [ "$?" != "0" ]; then
        echo "ERROR: llvm cmake."
        exit -1
    fi

    make -j$NUM_THREADS
    if [ "$?" != "0" ]; then
        echo "ERROR: llvm make."
        exit -1
    fi
}


clang_test()
{
    if [ ! -d $BUILD_PATH ]; then
        build_code
    fi

    cd $BUILD_PATH
    make -j$NUM_THREADS check-clang
}


main()
{
    check_utils
    arg_parse $@
    download_source_code
    if [ $TEST == $TRUE ]; then
        clang_test
    else
        build_code
    fi

    exit 0
}

main $@
