#######################################################################################################################
# Copyright [2020-2021] Renesas Electronics Corporation and/or its licensors. All Rights Reserved.
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
# This file helps to identify which SoCs and OS's are supported by the application/module. RCar-Environment will check
# this file to enable this application/module for building.
#######################################################################################################################


#######################################################################################################################
# SUPPORTED_SOC
#
# This variable specifies which SoCs are supported
#
#   Possible values can be:
#               any
#               V3M2
#               V3H1
#               <future SoCs>
#
#   Example1: set(SUPPORTED_SOC    any)   --> will enable the Application for all SoCs
#   Example2: set(SUPPORTED_SOC    V3M) --> will enable V3M2 and all revisions for V3H
#   Example3: set(SUPPORTED_SOC    V3M2 V3H1) --> will enable V3M2 and V3H1
#
#######################################################################################################################
set(SUPPORTED_SOC   V3H1 V3H2 V3U V3M2 V4H)

#######################################################################################################################
# SUPPORTED_OS
#
# This variable specifies which OSs are supported
#
#   Possible values can be:
#               any
#               freeRTOS
#               linux
#               <future OSs>
#
#   Example1: set(SUPPORTED_OS      any)   --> will enable the Application for all OSs
#   Example2: set(SUPPORTED_OS      freeRTOS linux) --> will enable freeRTOS and linux
#   Example3: set(SUPPORTED_OS      freeRTOS) --> will enable only for freeRTOS
#
#######################################################################################################################
set(SUPPORTED_OS    LINUX WINDOWS QNX EMCOS)

#######################################################################################################################
# SUPPORTED_XIL
#
# This variable specifies which XIL are supported
#
#   Possible values can be:
#               any
#               HIL
#               SIL
#
#   Example1: set(SUPPORTED_XIL      any)   --> will enable the Application for all environments
#   Example2: set(SUPPORTED_XIL      HIL)   --> will enable HIL (be aware this will limit the OSs supporting
#                                                          HIL environments only)
#   Example3: set(SUPPORTED_XIL      HIL SIL) --> will enable HIL and SIL environments
#
#######################################################################################################################
set(SUPPORTED_XIL   any)

set(SUPPORTED_SOC_OS_XIL
       V3H1_LINUX_HIL V3H2_LINUX_HIL V3M2_LINUX_HIL V3U_LINUX_HIL
       V3H2_QNX_HIL V3M2_QNX_HIL
       V3U_EMCOS_HIL
       V3H2_LINUX_SIL V3U_LINUX_SIL V4H_LINUX_SIL
       V3H1_WINDOWS_SIL V3H2_WINDOWS_SIL V3M2_WINDOWS_SIL V3U_WINDOWS_SIL V4H_WINDOWS_SIL
)
