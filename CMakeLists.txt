cmake_minimum_required(VERSION 3.25...4.4)
project(stm32-template
    VERSION 1.0
    DESCRIPTION "Template for STM32 projects"
    LANGUAGES C ASM)

# Use more efficient FetchContent_MakeAvailable() call, which is introduced in CMake 3.30.
set(CMAKE_POLICY_DEFAULT_CMP0168 NEW)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Create compile_commands.json in the build directory and link it to the source directory
file(CREATE_LINK
    ${CMAKE_BINARY_DIR}/compile_commands.json
    ${CMAKE_SOURCE_DIR}/compile_commands.json
    SYMBOLIC
    COPY_ON_ERROR
)


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
string(TOLOWER ${MCU_MODEL} _mcu_model_lower)
set(MCU_MODEL_LOWER ${_mcu_model_lower} CACHE INTERNAL "Lowercase MCU model")


# ======================================================================
# Load Dependencies, BSP, and CMake Helpers
# ======================================================================
# load dependencies
include(dependencies.cmake)

# load CMake helper functions for STM32 projects
include(stm32-utils)

# load BSP (Board Support Package) and ELF App when cross-compiling
if(CMAKE_CROSSCOMPILING)
    add_subdirectory(bsp)
    add_subdirectory(src)
endif()

