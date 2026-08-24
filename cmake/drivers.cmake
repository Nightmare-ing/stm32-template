include(cmake/dependencies.cmake)

# ======================================================================
# Basic Registers: stm32::cmsis (CMSIS-6)
# ======================================================================
add_library(stm32_cmsis INTERFACE)
target_include_directories(stm32_cmsis INTERFACE
    ${cmsis_core_SOURCE_DIR}/CMSIS/Core/Include
    ${cmsis_device_SOURCE_DIR}/Include
)
add_library(stm32::cmsis ALIAS stm32_cmsis)

# ======================================================================
# LL Library: stm32::ll
# ======================================================================
add_library(stm32_ll INTERFACE)
target_link_libraries(stm32_ll INTERFACE stm32::cmsis)
target_include_directories(stm32_ll INTERFACE
    ${stm32_hal_driver_SOURCE_DIR}/Inc
    ${stm32_hal_driver_SOURCE_DIR}/Inc/Legacy
)
target_compile_definitions(stm32_ll INTERFACE
    ${MCU_MODEL}
    USE_FULL_LL_DRIVER
)
add_library(stm32::ll ALIAS stm32_ll)

# ======================================================================
# HAL Library: stm32::hal
# ======================================================================
add_library(stm32_hal INTERFACE)
target_link_libraries(stm32_hal INTERFACE stm32::cmsis)
target_include_directories(stm32_hal INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/bsp/hal_config
    ${stm32_hal_driver_SOURCE_DIR}/Inc
    ${stm32_hal_driver_SOURCE_DIR}/Inc/Legacy
)
target_compile_definitions(stm32_hal INTERFACE
    ${MCU_MODEL}
    USE_HAL_DRIVER
)
add_library(stm32::hal ALIAS stm32_hal)
