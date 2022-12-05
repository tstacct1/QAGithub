/***********************************************************************************************************************
 * DISCLAIMER
 * This software is supplied by Renesas Electronics Corporation and is only intended for use with Renesas products. No
 * other uses are authorized. This software is owned by Renesas Electronics Corporation and is protected under all
 * applicable laws, including copyright laws.
 * THIS SOFTWARE IS PROVIDED "AS IS" AND RENESAS MAKES NO WARRANTIES REGARDING
 * THIS SOFTWARE, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. ALL SUCH WARRANTIES ARE EXPRESSLY DISCLAIMED. TO THE MAXIMUM
 * EXTENT PERMITTED NOT PROHIBITED BY LAW, NEITHER RENESAS ELECTRONICS CORPORATION NOR ANY OF ITS AFFILIATED COMPANIES
 * SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES FOR ANY REASON RELATED TO THIS
 * SOFTWARE, EVEN IF RENESAS OR ITS AFFILIATES HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 * Renesas reserves the right, without notice, to make changes to this software and to discontinue the availability of
 * this software. By using this software, you agree to the additional terms and conditions found by accessing the
 * following link:
 * http://www.renesas.com/disclaimer
 *
 * Copyright (C) 2020 Renesas Electronics Corporation. All rights reserved.
 ***********************************************************************************************************************/
/***********************************************************************************************************************
 * File Name    : helloworld.c
 * Version      : 0.7.0
 * Product Name : Hello application
 * Device(s)    : V3H1, V3H2, V3M2, V3U, V4H
 * Description  : -
 ***********************************************************************************************************************/
/***********************************************************************************************************************
 * History   Version   DD.MM.YYYY    Description
 *           0.4.0     02.07.2021    Add doxygen comment
 *           0.5.0     15.07.2021    Add eMCOS support
 *           0.6.0     14.10.2021    Fix cast issue
 *           0.7.0     08.11.2021    Update helloworld thread_id, remove eMCOS specific code
***********************************************************************************************************************/

/* Includes */
#include "rcar-xos/rcar_xos_config.h"
#include "stdio.h"
#include "rcar-xos/osal/r_osal.h"
/*******************************************************************************************************************//**
 * @defgroup Helloworld_Private_Defines Private macro definitions
 *
 * @{
 **********************************************************************************************************************/
/*******************************************************************************************************************//**
 * @def PRINT_ERROR
 * Print error macro follow template ERROR: <function_name> (<line>) : <message>
***********************************************************************************************************************/

#define PRINT_ERROR(...) { printf("ERROR: %s (%d): ", __func__, __LINE__); printf(__VA_ARGS__);}
/** @} */

/******************************************************************************************************************//**
 * @defgroup Helloworld_Private_Functions Private function definitions
 *
 * @{
*********************************************************************************************************************/

/*******************************************************************************************************************//**
 * @brief     Print build information which makes use of definition from rcar_xos_config.h
 *  - Compile date, time
 *  - RCar xOS information: OS, SoC, Git information (origin, tag, branch, hash)
 * @param[in] app_name Application name.
***********************************************************************************************************************/

/* Get rcar xos information */
void print_build_info(char *app_name)
{
    printf("/******************************************************************/\n");
    printf(" * Application information: %s\n", app_name);
    printf(" *   Build Date:    " __DATE__ " at " __TIME__ "\n");
    printf(" *\n");
    printf(" * R-Car xOS information:\n");
    printf(" *   OS:            " RCAR_XOS_OS "\n");
    printf(" *   Target:        " RCAR_XOS_TARGET "\n");
    printf(" *   Git Origin:    " RCAR_XOS_GIT_ORIGIN_URL "\n");
#ifdef RCAR_XOS_GIT_TAG_NAME
#ifndef RCAR_XOS_GIT_TAG_IS_AHEAD
    printf(" *   Git Tag:       " RCAR_XOS_GIT_TAG_NAME "\n");
#else
    printf(" *   Git Tag:       " RCAR_XOS_GIT_TAG_NAME
           " (" RCAR_XOS_GIT_NO_COMMITS_HEAD_OF_TAG " commits ahead)" "\n");
#endif
#endif
    printf(" *   Git Branch:    "  RCAR_XOS_GIT_BRANCH "\n");
    printf(" *   Git Hash:      "  RCAR_XOS_GIT_COMMIT_HASH "\n");
    printf(" *\n");
    printf("/******************************************************************/\n");
}

int64_t repeat_tsk(void * user_arg)
{
    (void)user_arg;
    for (uint8_t i = 0; i < 5; i++)
    {
        printf("Repeat RamKumar %u\n", i);
        R_OSAL_ThreadSleepForTimePeriod(1000);
    }
    return 0;
}

/******************************************************************************************************************//**
 * @brief    Helloworld main function which show how to use simple OSAL API
 * @return   0 on success
 * @return   !0 on failure
***********************************************************************************************************************/
int main(int argc, char * argv[])
{
    (void)argc; /* unused */
    (void)argv; /* unused */

    print_build_info("Hello World");
    /* OSAL "Blinky" */
    e_osal_return_t osal_ret = R_OSAL_Initialize();
    if (OSAL_RETURN_OK != osal_ret)
    {
        PRINT_ERROR("OSAL Initialization failed with error %d\n", osal_ret);
        return -1;
    }
    /* Create a thread */
    osal_thread_handle_t    thrd_hndl         = OSAL_THREAD_HANDLE_INVALID;
    int64_t                 thrd_return_value = -1;
    st_osal_thread_config_t thrd_cfg;
    thrd_cfg.func       = repeat_tsk;
    thrd_cfg.priority   = OSAL_THREAD_PRIORITY_TYPE0;
    thrd_cfg.stack_size = 0x2000;
    thrd_cfg.task_name  = "repeat_tsk";
    thrd_cfg.userarg    = NULL;

    /* start thread */
    osal_ret = R_OSAL_ThreadCreate(&thrd_cfg, 0xf000, &thrd_hndl);
    if (OSAL_RETURN_OK != osal_ret)
    {
        PRINT_ERROR("OSAL thread creation failed with error %d\n", osal_ret);
        R_OSAL_Deinitialize();
        return (int)osal_ret;
    }
    /* wait until thread finished */
    osal_ret = R_OSAL_ThreadJoin(thrd_hndl, &thrd_return_value);
    if (OSAL_RETURN_OK != osal_ret)
    {
        PRINT_ERROR("OSAL thread join failed with error %d\n", osal_ret);
        R_OSAL_Deinitialize();
        return (int)osal_ret;
    }

    printf("repeat thread ended with return value %ld\n", (long)thrd_return_value);

    osal_ret = R_OSAL_Deinitialize();
    if (OSAL_RETURN_OK != osal_ret)
    {
        PRINT_ERROR("OSAL de-initialize failed with error %d\n", osal_ret);
        return (int)osal_ret;
    }
    /* Final return code */
    return (int)thrd_return_value;
}
/** @} */
