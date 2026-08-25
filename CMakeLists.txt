cmake_minimum_required(VERSION 3.20)
project(stm32-template C ASM)

# ======================================================================
# Set default chip family and model (can be overridden by Presets or CLI)
# ======================================================================
set(MCU_FAMILY "STM32F1" CACHE STRING "MCU family, e.g. STM32F1, STM32F4")
set(MCU_MODEL "STM32F103xE" CACHE STRING "MCU model, e.g. STM32F103xE, STM32F401xE")
set(STM32_DRIVER_TYPE "LL" CACHE STRING "Driver type: LL, HAL, BARE, MIXED")

# load dependencies
include(cmake/drivers.cmake)
include(cmake/stm32-helpers.cmake)

# ======================================================================
# Set startup file and linker script based on MCU model
# ======================================================================
string(TOLOWER ${MCU_MODEL} MCU_MODEL_LOWER)
set(STARTUP_FILE "${CMAKE_CURRENT_SOURCE_DIR}/bsp/startup/startup_${MCU_MODEL_LOWER}.s")
set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/bsp/ldscripts/${MCU_MODEL}_FLASH.ld")

string(TOLOWER ${MCU_FAMILY} MCU_FAMILY_LOWER)
set(PROJECT_SOURCES
    src/main.c
    bsp/system_${MCU_FAMILY_LOWER}xx.c
    ${STARTUP_FILE}
)

if(STM32_DRIVER_TYPE STREQUAL "LL")
    message(STATUS "Configuring project for ${MCU_MODEL} with LL driver")
    list(APPEND PROJECT_SOURCES
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_ll_gpio.c
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_ll_rcc.c
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_ll_usart.c
    )
    set(DRIVER_LIB stm32::ll)

elseif(STM32_DRIVER_TYPE STREQUAL "HAL")
    message(STATUS "Configuring project for ${MCU_MODEL} with HAL driver")
    list(APPEND PROJECT_SOURCES
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal.c
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal_rcc.c
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal_gpio.c
        ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal_cortex.c
    )
    set(DRIVER_LIB stm32::hal)

elseif(STM32_DRIVER_TYPE STREQUAL "BARE")
    message(STATUS "Configuring project for ${MCU_MODEL} with bare-metal / CMSIS only")
    set(DRIVER_LIB stm32::cmsis)
endif()

if(MCU_FAMILY STREQUAL "STM32F1")
    include(cmake/stm32f1.cmake)
    set(CHIP_FLAGS_LIB stm32::f1_flags)
elseif(MCU_FAMILY STREQUAL "STM32H7")
    include(cmake/stm32h7.cmake)
    set(CHIP_FLAGS_LIB stm32::h7_flags)
endif()

# ======================================================================
# Create executable target and linking
# ======================================================================
# add executable
add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})
set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".elf")

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${CHIP_FLAGS_LIB}
    ${DRIVER_LIB}
)
target_include_directories(${PROJECT_NAME} PRIVATE src bsp)

target_link_options(${PROJECT_NAME} PRIVATE
    -T${LINKER_SCRIPT}
)

stm32_add_hex_bin_targets(${PROJECT_NAME})
stm32_setup_compile_commands()

