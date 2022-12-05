#!/bin/bash

#######################################################################################################################
# Copyright [2021] Renesas Electronics Corporation and/or its licensors. All Rights Reserved.
#
# The contents of this file (the "contents") are proprietary and confidential to Renesas Electronics Corporation
# and/or its licensors ("Renesas") and subject to statutory and contractual protections.
#
# Unless otherwise expressly agreed in writing between Renesas and you: 1) you may not use, copy, modify, distribute,
# display, or perform the contents; 2) you may not use any name or mark of Renesas for advertising or publicity
# purposes or in connection with your use of the contents; 3) RENESAS MAKES NO WARRANTY OR REPRESENTATIONS ABOUT THE
# SUITABILITY OF THE CONTENTS FOR ANY PURPOSE; THE CONTENTS ARE PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
# NON-INFRINGEMENT; AND 4) RENESAS SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, OR CONSEQUENTIAL DAMAGES,
# INCLUDING DAMAGES RESULTING FROM LOSS OF USE, DATA, OR PROJECTS, WHETHER IN AN ACTION OF CONTRACT OR TORT, ARISING
# OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THE CONTENTS. Third-party contents included in this file may
# be subject to different terms.
#######################################################################################################################

#######################################################################################################################
# Description: Shell script to build Linux HIL sample applications
# Version: 1.0.0             Initial version
# Version: 1.1.0  13.08.2021 Improvements
# Version: 1.2.0  11.11.2021 Improvements
# Version: 1.3.0  12.01.2022 Add option to build all applications in package
#######################################################################################################################

# Define the color
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

echo " "
echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo -e "${CYAN}                            How to use the script                              ${ENDCOLOR}"
echo -e "${CYAN}Usage 1:                                                                       ${ENDCOLOR}"
echo -e "${CYAN}    ./build_linux_dev_board.sh <app_name> <device_name> <build type>           ${ENDCOLOR}"
echo -e "${CYAN}    Eg:- ./build_linux_dev_board.sh acf_sample_app v3u release                 ${ENDCOLOR}"
echo -e "${CYAN}Usage 2:                                                                       ${ENDCOLOR}"
echo -e "${CYAN}    ./build_linux_dev_board.sh                                                 ${ENDCOLOR}"
echo -e "${CYAN}Usage 3:                                                                       ${ENDCOLOR}"
echo -e "${CYAN}    ./build_linux_dev_board.sh all <device_name> <build_type>                  ${ENDCOLOR}"
echo -e "${CYAN}===============================================================================${ENDCOLOR}"

# Define tool path
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    #Define tool path based on the SDK tool location
    CMAKE_PATH=${PWD}/../tools/cmake-3.18.4-Linux-x86_64/bin
    POKY_PATH=${PWD}/../tools/toolchains/poky/sysroots/x86_64-pokysdk-mingw32/usr/bin/aarch64-poky-linux
    CVE_PATH=${PWD}/../tools/ccimp/linux/bin

    export PATH=${CMAKE_PATH}:${POKY_PATH}:${CVE_PATH}:${PATH}
else
    #Define tool path based on the SDK tool location
    CMAKE_PATH=${PWD}/../tools/cmake-3.18.4-win64-x64/bin
    MAKE_PATH=${PWD}/../tools/make
    POKY_PATH=${PWD}/../tools/toolchains/poky/sysroots/x86_64-pokysdk-mingw32/usr/bin/aarch64-poky-linux
    CVE_PATH=${PWD}/../tools/ccimp/windows/bin

    export PATH=${CMAKE_PATH}:${MAKE_PATH}:${POKY_PATH}:${CVE_PATH}:${PATH}
fi

RCAR_SDK_ROOT=${PWD}


# Check CMake
echo -e "${CYAN}--------------- Start to check your PC already have CMake or not --------------${ENDCOLOR}"
{
    check_cmake=$(cmake --version 2> /dev/null)
} || {
        echo -e "${RED}This PC does not have CMake.${ENDCOLOR}"
        echo -e "${RED}Please install CMake before continue${ENDCOLOR}"
        exit 1
} && {
        echo -e "${GREEN}Already have CMake on your PC${ENDCOLOR}"
        echo -e "${YELLOW}${check_cmake}${ENDCOLOR}"
}
echo " "

# Check Make
echo -e "${CYAN}---------------- Start to check your PC already have Make or not --------------${ENDCOLOR}"
{
    check_make=$(make --version 2> /dev/null)
} || {
        echo -e "${RED}This PC does not have Make.${ENDCOLOR}"
        echo -e "${RED}Please install Make before continue${ENDCOLOR}"
        exit 1
} && {
        echo -e "${GREEN}Already have Make on your PC${ENDCOLOR}"
        echo -e "${YELLOW}${check_make}${ENDCOLOR}"
}
echo " "


# Check Poky SDK
echo -e "${CYAN}------------- Start to check your PC already have Poky SDK or not -------------${ENDCOLOR}"
if [ "$SDKROOT" == "" ]; then
    echo -e "${YELLOW}This PC does not set SDK variable.${ENDCOLOR}"
    cd ../tools
    {
        check_poky=$(cd toolchains/poky 2> /dev/null)
    } || {
            echo -e "${RED}This PC does not have Poky SDK.${ENDCOLOR}"
            echo -e "${RED}Please install Poky SDK before continue${ENDCOLOR}"
            exit 1
    } && {
            echo -e "${GREEN}Already have Poky SDK on your PC${ENDCOLOR}"
            SDKROOT="$PWD/toolchains/poky"
    }
else
    echo -e "${GREEN}Already have Poky SDK on your PC${ENDCOLOR}"
fi
echo " "

# Move to root folder
cd ..
RCAR_SDK_ROOT="$PWD"

# Move to 'sample' folder
cd samples

echo -e "${CYAN}----------------------- All applications in this package ----------------------${ENDCOLOR}"
ls -d */ | awk -F/ '{print$1}'
echo " "

app=$1

if [ "$1" == "" ]; then
    # Select the application
    while true; do
        echo -e "${CYAN}Type \"all\" option to build all applications ${ENDCOLOR}"
        read -e -p "Select application in the list: " app
        if [ "$app" == "" ]; then
            echo -e "${YELLOW}The application name is required.${ENDCOLOR}"
        elif [ "$app" == "all" ] || [ "$app" == "ALL" ] || [ "$app" == "All" ]; then
            echo -e "${GREEN}Build all application.${ENDCOLOR}"
            echo " "
            break
        else
        {
            check_app=$(cd $app 2> /dev/null)
        } || {
                echo -e "${RED}Application name $app is not existed.${ENDCOLOR}"
                exit 1
        } && {
                break
        }
        fi
    done
fi

if [ "${app: -1}" == "/" ]; then
    app=${app::-1}
fi

soc=$2

if [ "$2" == "" ]; then
    # Select the SoC
    while true; do
        read -e -p "Select the SoC to build application (v3h1/v3h2/v3m2/v3u/v4h): " soc
        if [ "$soc" == "" ]; then
            echo -e "${YELLOW}The soc name is required.${ENDCOLOR}"
        else
            if [ "$soc" == "v3h1" ] || [ "$soc" == "v3h2" ] || [ "$soc" == "v3m2" ] || [ "$soc" == "v3u" ] || \
            [ "$soc" == "V3H1" ] || [ "$soc" == "V3H2" ] || [ "$soc" == "V3M2" ] || [ "$soc" == "V3U" ]; then
                break
            else
                echo -e "${RED}We only support v3h1, v3h2, v3m2, v3u.${ENDCOLOR}"
            fi
        fi
    done
fi

build_type=$3
if [ "$3" == "" ]; then
    # Select the build type
    while true; do
        read -e -p "Select the build type (release/debug): " build_type
        if [ "$build_type" == "" ]; then
            echo -e "${YELLOW}The build type is required.${ENDCOLOR}"
        else
            if [ "$build_type" == "debug" ] || [ "$build_type" == "release" ] || [ "$build_type" == "DEBUG" ] || \
            [ "$build_type" == "RELEASE" ]; then
                break
            else
                echo -e "${RED}We only support debug or release or DEBUG or RELEASE.${ENDCOLOR}"
            fi
        fi
    done
fi

# Start to build app
BUILD_TOOL="Unix Makefiles"

DEBUG_LEVEL="none"

CMAKE_COMMON="-DCMAKE_BUILD_TYPE=$build_type -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DRCAR_SOC=$soc -DSDKROOT=$SDKROOT -DCMAKE_PREFIX_PATH=$RCAR_SDK_ROOT/cmake"

echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo -e "${CYAN}              Generate the build files for Linux HIL sample app                ${ENDCOLOR}"
echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo " "

if [ "$app" == "all" ] || [ "$app" == "ALL" ] || [ "$app" == "All" ]; then
    rm -rf ../build_all_app
    mkdir ../build_all_app
    cd ../build_all_app
    unset RCAR_SDK_ROOT
    RCAR_SDK_ROOT=".."
else
    cd $app
    echo " "
    rm -rf build_linux_dev_board
    mkdir build_linux_dev_board
    cd build_linux_dev_board
fi

echo "cmake .. -G \"${BUILD_TOOL}\" $CMAKE_COMMON -DCMAKE_TOOLCHAIN_FILE=$RCAR_SDK_ROOT/cmake/toolchain_poky_3_1_3.cmake"
cmake .. -G "${BUILD_TOOL}" $CMAKE_COMMON -DCMAKE_TOOLCHAIN_FILE=$RCAR_SDK_ROOT/cmake/toolchain_poky_3_1_3.cmake

echo " "
echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo -e "${CYAN}                        Build the Linux HIL sample app                         ${ENDCOLOR}"
echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo " "
cmake --build . -v
make clean
