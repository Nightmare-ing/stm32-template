cmake_minimum_required(VERSION 3.25...4.4)
project(stm32-template
    VERSION 1.0
    DESCRIPTION "Template for STM32 projects"
    LANGUAGES C ASM)

# Use more efficient FetchContent_MakeAvailable() call, which is introduced in CMake 3.30.
set(CMAKE_POLICY_DEFAULT_CMP0168 NEW)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# ======================================================================
# Set default chip family and model (can be overridden by Presets or CLI)
# ======================================================================
set(MCU_FAMILY "STM32F1" CACHE STRING "MCU family, e.g. STM32F1, STM32F4")
set(MCU_MODEL "STM32F103xE" CACHE STRING "MCU model, e.g. STM32F103xE, STM32F401xE")
set(STM32_DRIVER_TYPE "LL" CACHE STRING "Driver type: LL, HAL, BARE, MIXED")

string(TOLOWER ${MCU_FAMILY} _mcu_family_lower)
set(MCU_FAMILY_LOWER ${_mcu_family_lower} CACHE INTERNAL "Lowercase MCU family")
string(SUBSTRING ${MCU_FAMILY_LOWER} 5 -1 _mcu_family_short) # e.g., extract "f1"
set(MCU_FAMILY_SHORT ${_mcu_family_short} CACHE INTERNAL "Short MCU family")

if(MCU_FAMILY STREQUAL "STM32F1")
    include(cmake/stm32f1.cmake)
    set(CHIP_FLAGS_LIB bsp::mcu_config)
elseif(MCU_FAMILY STREQUAL "STM32H7")
    include(cmake/stm32h7.cmake)
    set(CHIP_FLAGS_LIB bsp::mcu_config)
endif()

# load dependencies
include(cmake/dependencies.cmake)
include(cmake/stm32-utils.cmake)

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

# ======================================================================
# Configure libraries based on driver type and MCU family
# ======================================================================
if(STM32_DRIVER_TYPE STREQUAL "LL")
    set(DRIVER_LIB stm32::ll)
elseif(STM32_DRIVER_TYPE STREQUAL "HAL")
    set(DRIVER_LIB stm32::hal)
elseif(STM32_DRIVER_TYPE STREQUAL "BARE")
    message(STATUS "Configuring project for ${MCU_MODEL} with bare-metal / CMSIS only")
    set(DRIVER_LIB stm32::cmsis)
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
    stm32::f1_linker
)
target_include_directories(${PROJECT_NAME} PRIVATE src bsp)

target_link_options(${PROJECT_NAME} PRIVATE
    -T${LINKER_SCRIPT}
)
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall                           # Enable all warnings
    -Wextra                         # Enable extra warnings
)

stm32_add_hex_bin_targets(${PROJECT_NAME})
stm32_setup_compile_commands()

