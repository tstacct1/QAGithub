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
# Description: Shell script to build and execute SIL sample applications
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
echo -e "${CYAN}    ./build_simulator.sh <app_name> <device_name> <build type> <run_type>      ${ENDCOLOR}"
echo -e "${CYAN}    Eg:- ./build_simulator.sh acf_sample_app v3u release run                   ${ENDCOLOR}"
echo -e "${CYAN}Usage 2:                                                                       ${ENDCOLOR}"
echo -e "${CYAN}    ./build_simulator.sh                                                       ${ENDCOLOR}"
echo -e "${CYAN}Usage 3:                                                                       ${ENDCOLOR}"
echo -e "${CYAN}    ./build_simulator.sh all <device_name> <build_type> <run_type>             ${ENDCOLOR}"
echo -e "${CYAN}===============================================================================${ENDCOLOR}"

# Define tool path
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    #Define tool path based on the SDK tool location
    CMAKE_PATH=${PWD}/../tools/cmake-3.18.4-Linux-x86_64/bin
    CVE_PATH=${PWD}/../tools/ccimp/linux/bin
    DLL_SIMU_PATH=${PWD}/../sw/x86_64-gnu-linux/lib

    export PATH=${CMAKE_PATH}:${CVE_PATH}:${DLL_SIMU_PATH}:${PATH}
    export LD_LIBRARY_PATH=${PWD}/../sw/x86_64-gnu-linux/lib:${LD_LIBRARY_PATH}
else
    #Define tool path based on the SDK tool location
    CMAKE_PATH=${PWD}/../tools/cmake-3.18.4-win64-x64/bin
    MAKE_PATH=${PWD}/../tools/make
    MINGW64_PATH=${PWD}/../tools/toolchains/mingw64/bin
    CVE_PATH=${PWD}/../tools/ccimp/windows/bin
    DLL_SIMU_PATH=${PWD}/../sw/amd64-gnu-windows/bin

    export PATH=${CMAKE_PATH}:${MAKE_PATH}:${MINGW64_PATH}:${CVE_PATH}:${DLL_SIMU_PATH}:${PATH}
fi

RCAR_SDK_ROOT=${PWD}

# Check Ubuntu version
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo -e "${CYAN}------------------------ Start to check Ubuntu version ------------------------${ENDCOLOR}"
    ubuntu_version=$(cat /etc/lsb-release | cut -f1 -d. | grep "DISTRIB_RELEASE" | sed "s/DISTRIB_RELEASE=//")
    echo -e "${GREEN}You are using Ubuntu version $ubuntu_version.${ENDCOLOR}"
    if [[ "$ubuntu_version" -lt "20" ]]; then
        echo -e "${YELLOW}We require Ubuntu version >= 20 for Build Linux SIL.${ENDCOLOR}"
        exit 1
    fi
fi
echo " "

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

# Check GCC
echo -e "${CYAN}---------------- Start to check your PC already have GCC or not ---------------${ENDCOLOR}"
{
    check_gcc=$(gcc --version 2> /dev/null)
} || {
        echo -e "${RED}This PC does not have GCC.${ENDCOLOR}"
        echo -e "${RED}Please install GCC before continue${ENDCOLOR}"
        exit 1
} && {
        echo -e "${GREEN}Already have GCC on your PC${ENDCOLOR}"
        echo -e "${YELLOW}${check_gcc}${ENDCOLOR}"
}
echo " "

# Check mingw (For build Windows SIL)
if [[ "$OSTYPE" != "linux-gnu" ]]; then
    echo -e "${CYAN}----------------- Start to check your PC already have mingw or not ------------${ENDCOLOR}"
    {
        check_gcc=$(x86_64-w64-mingw32-g++.exe --version 2> /dev/null)
    } || {
            echo -e "${RED}This PC does not have mingw.${ENDCOLOR}"
            echo -e "${RED}Please install mingw before continue${ENDCOLOR}"
            exit 1
    } && {
            echo -e "${GREEN}Already have mingw on your PC${ENDCOLOR}"
            echo -e "${YELLOW}${check_gcc}${ENDCOLOR}"
    }
    echo " "
fi

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

CMAKE_COMMON="-DCMAKE_BUILD_TYPE=$build_type -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DRCAR_SOC=$soc -DCMAKE_PREFIX_PATH=$RCAR_SDK_ROOT/cmake"

echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo -e "${CYAN}                  Generate the build files for SIL sample app                  ${ENDCOLOR}"
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
    rm -rf build_simulator
    mkdir build_simulator
    cd build_simulator
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "cmake .. -G \"${BUILD_TOOL}\" $CMAKE_COMMON"
    cmake .. -G "${BUILD_TOOL}" $CMAKE_COMMON
else
    echo "cmake .. -G \"${BUILD_TOOL}\" $CMAKE_COMMON -DCMAKE_TOOLCHAIN_FILE=$RCAR_SDK_ROOT/cmake/toolchain_x86_64-w64-mingw32.cmake"
    cmake .. -G "${BUILD_TOOL}" $CMAKE_COMMON -DCMAKE_TOOLCHAIN_FILE=$RCAR_SDK_ROOT/cmake/toolchain_x86_64-w64-mingw32.cmake
fi

echo " "
echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo -e "${CYAN}                           Build the SIL sample app                            ${ENDCOLOR}"
echo -e "${CYAN}===============================================================================${ENDCOLOR}"
echo " "
cmake --build . -v

# Select the application to test
if [ "$app" == "all" ] || [ "$app" == "ALL" ] || [ "$app" == "All" ]; then
    echo " "
    cd bin
    echo -e "${CYAN}------------------- All valid test applications in this package ------------------${ENDCOLOR}"
    ls -p | grep -v /
    echo " "
    while true; do
        read -e -p "Select application to test: " test_app
        if [ "$test_app" == "" ]; then
            echo -e "${YELLOW}The test application name is required.${ENDCOLOR}"
        elif [[ ! -f $test_app ]]; then
            echo -e "${RED} Test application name $test_app is not existed.${ENDCOLOR}"
            exit 1
        else
            break
        fi
    done
else
    cd ../..
fi

if [ "${app: -1}" == "/" ]; then
  app=${app::-1}
fi

run_type=$4
echo " "
if [ "$4" == "" ]; then
    # Select the build type
    while true; do
        echo -e "${CYAN}===============================================================================${ENDCOLOR}"
        read -e -p "Do you want to run the sample application (run/no)? " run_type
        break
    done
fi

# Derive sample application name from the user input
if [ "$app" != "all" ] && [ "$app" != "ALL" ] && [ "$app" != "All" ]; then
    cd ${app}/build_simulator
    if [ "$build_type" == "debug" ] || [ "$build_type" == "DEBUG" ]; then
        app_name=./${app}_${soc}_d
    else
        app_name=./${app}_${soc}
    fi
    if [[ "$OSTYPE" != "linux-gnu" ]]; then
        app_name=${app_name}.exe
    fi
else
    app_name=./${test_app}
fi

if [ $run_type == "run" ]; then
	echo -e "${CYAN}===============================================================================${ENDCOLOR}"
	echo " "
	echo "Executing the application $app_name"
	$app_name
    if [ "$app" == "all" ] || [ "$app" == "ALL" ] || [ "$app" == "All" ]; then
        cd ..
    fi
    make clean
	echo -e "${CYAN}===============================================================================${ENDCOLOR}"
fi