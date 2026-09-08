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

# load BSP (Board Support Package) for the selected MCU family
add_subdirectory(bsp)

# load CMake helper functions for STM32 projects
include(stm32-utils)


# ======================================================================
# Create executable target
# ======================================================================
# add executable
add_executable(${PROJECT_NAME}
    src/main.c
)
set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".elf")

target_link_libraries(${PROJECT_NAME} PRIVATE
    bsp::baremetal_linker
    bsp::startup
    bsp::driver
)
target_include_directories(${PROJECT_NAME} PRIVATE src)
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall                           # Enable all warnings
    -Wextra                         # Enable extra warnings
)

stm32_add_hex_bin_targets(${PROJECT_NAME})
stm32_setup_compile_commands()

