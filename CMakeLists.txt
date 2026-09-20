cmake_minimum_required(VERSION 3.20)

project(psp_dynamic_libraries VERSION 1.0 LANGUAGES C ASM)

execute_process(
    COMMAND psp-config --pspsdk-path
    OUTPUT_VARIABLE CFWSDK
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE PSP_CONFIG_RESULT
)

if(NOT PSP_CONFIG_RESULT EQUAL 0 OR CFWSDK STREQUAL "")
    message(FATAL_ERROR "Unable to locate PSPSDK with psp-config")
endif()

remove_definitions("-D_PSP_FW_VERSION=600")
add_definitions("-D_PSP_FW_VERSION=660")

add_subdirectory(idStorageRegen)
add_subdirectory(IOPrivileged)
add_subdirectory(IPL_Updater)
add_subdirectory(KBooti_Updater)
add_subdirectory(PSPAV)
add_subdirectory(PSPFTP)
add_subdirectory(PSPIdentHelper)
add_subdirectory(USBDeviceDriver)
