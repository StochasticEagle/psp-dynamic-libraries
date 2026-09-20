cmake_minimum_required(VERSION 3.20)

project(psp_dynamic_libraries VERSION 1.0 LANGUAGES C ASM)

if(NOT PSP)
    message(FATAL_ERROR
        "Configure this project with the PSP toolchain: "
        "-DCMAKE_TOOLCHAIN_FILE=$ENV{PSPDEV}/psp/share/pspdev.cmake")
endif()

execute_process(
    COMMAND psp-config --pspsdk-path
    OUTPUT_VARIABLE PSPSDK_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE PSP_CONFIG_RESULT
)

if(NOT PSP_CONFIG_RESULT EQUAL 0 OR PSPSDK_PATH STREQUAL "")
    message(FATAL_ERROR "Unable to locate the installed PSPSDK with psp-config")
endif()

if(NOT EXISTS "${PSPSDK_PATH}/include/systemctrl.h"
   OR NOT EXISTS "${PSPSDK_PATH}/lib/libpspsystemctrl_kernel.a")
    message(FATAL_ERROR
        "The installed PSPSDK does not contain the integrated CFW interfaces. "
        "Install the CFW portion of StochasticEagle/pspsdk before configuring "
        "psp-dynamic-libraries.")
endif()

remove_definitions("-D_PSP_FW_VERSION=600")
add_compile_definitions(_PSP_FW_VERSION=660)

function(psp_link_kernel_prx target)
    target_link_options(${target} PRIVATE -nostdlib)
    target_link_libraries(${target} PRIVATE
        ${ARGN}
        pspdebug
        pspdisplay_driver
        pspctrl_driver
        pspmodinfo
        pspsdk
        pspkernel
    )
endfunction()

function(psp_link_user_prx target)
    target_link_libraries(${target} PRIVATE
        ${ARGN}
        pspdebug
        pspdisplay
        pspge
        pspctrl
    )
endfunction()

add_subdirectory(idStorageRegen)
add_subdirectory(IOPrivileged)
add_subdirectory(IPL_Updater)
add_subdirectory(KBooti_Updater)
add_subdirectory(LibPNG)
add_subdirectory(PSPAV)
add_subdirectory(PSPFTP)
add_subdirectory(PSPIdentHelper)
add_subdirectory(Unarchiver)
add_subdirectory(USBDeviceDriver)

set(PSP_PREBUILT_PRXS
    intraFont-vlf.prx
    lflash_fdisk.prx
    libpsardumper.prx
    pspdecrypt.prx
    vlf.prx
)

set(PSP_PREBUILT_PRX_PATHS)
foreach(prx IN LISTS PSP_PREBUILT_PRXS)
    set(prx_path "${CMAKE_CURRENT_SOURCE_DIR}/pre-built/${prx}")
    if(NOT EXISTS "${prx_path}")
        message(FATAL_ERROR "Missing versioned pre-built PRX: ${prx}")
    endif()
    list(APPEND PSP_PREBUILT_PRX_PATHS "${prx_path}")
endforeach()

set(PSP_DIST_DIR "${CMAKE_BINARY_DIR}/dist/LIBS")

add_custom_target(package-prxs ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PSP_DIST_DIR}"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:idsregeneration>.prx"
        "${PSP_DIST_DIR}/idsregeneration.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:iop>.prx"
        "${PSP_DIST_DIR}/iop.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:ipl_update>.prx"
        "${PSP_DIST_DIR}/ipl_update.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:kbooti_update>.prx"
        "${PSP_DIST_DIR}/kbooti_update.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:libpng>.prx"
        "${PSP_DIST_DIR}/libpng.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:pspav>.prx"
        "${PSP_DIST_DIR}/pspav.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:pspftp>.prx"
        "${PSP_DIST_DIR}/pspftp.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:kpspident>.prx"
        "${PSP_DIST_DIR}/kpspident.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:unarchive>.prx"
        "${PSP_DIST_DIR}/unarchive.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:usbdevice>.prx"
        "${PSP_DIST_DIR}/usbdevice.prx"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/pre-built/intraFont-vlf.prx"
        "${PSP_DIST_DIR}/intraFont-vlf.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/pre-built/lflash_fdisk.prx"
        "${PSP_DIST_DIR}/lflash_fdisk.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/pre-built/libpsardumper.prx"
        "${PSP_DIST_DIR}/libpsardumper.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/pre-built/pspdecrypt.prx"
        "${PSP_DIST_DIR}/pspdecrypt.prx"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/pre-built/vlf.prx"
        "${PSP_DIST_DIR}/vlf.prx"

    DEPENDS
        idsregeneration
        iop
        ipl_update
        kbooti_update
        libpng
        pspav
        pspftp
        kpspident
        unarchive
        usbdevice
        ${PSP_PREBUILT_PRX_PATHS}
    COMMENT "Staging PSP dynamic-library PRXs"
)
