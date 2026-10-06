cmake_minimum_required(VERSION 3.25...4.4)
project(stm32-template
    VERSION 1.0
    DESCRIPTION "Template for STM32 projects"
    LANGUAGES C ASM)
set(STM32_LEARNING_NAMESPACE stm32-template)

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
# Load CMake Helpers
# ======================================================================
include(stm32-utils)


# ======================================================================
# Stable architecture interface
# ======================================================================
add_library(${PROJECT_NAME}_architecture INTERFACE)
add_library(${STM32_LEARNING_NAMESPACE}::architecture
    ALIAS ${PROJECT_NAME}_architecture
)


# ======================================================================
# Platform-independent Components
# ======================================================================
add_subdirectory(components/led)


# ======================================================================
# Platform-specific Targets
# ======================================================================
# load BSP (Board Support Package) and ELF App when cross-compiling
if(CMAKE_CROSSCOMPILING)
    # Create bsp::mcu_config and board adapters
    # Board adapters can now safely depend on component targets
    add_subdirectory(bsp)

    # Populate the previously empty architecture interface
    target_link_libraries(${PROJECT_NAME}_architecture INTERFACE
        bsp::mcu_config
    )

    # Final consumer
    add_subdirectory(src)
endif()

