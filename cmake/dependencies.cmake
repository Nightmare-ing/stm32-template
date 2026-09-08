include(FetchContent)

# ======================================================================
# CMSIS Dependencies from both ARM and STMicroelectronics
# ======================================================================
# ARM CMSIS 6
FetchContent_Declare(
    arm_cmsis
    GIT_REPOSITORY https://github.com/ARM-software/CMSIS_6.git
    GIT_TAG v6.3.0
    GIT_SHALLOW TRUE
    # Because CMSIS lib doesn't have a CMakeLists.txt, those two following keywords won't work, but just put here for future reference
    SYSTEM
    EXCLUDE_FROM_ALL
)

# ST CMSIS Device F1
FetchContent_Declare(
    stm32_cmsis
    GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis-device-${MCU_FAMILY_SHORT}.git
    GIT_TAG v4.3.5
    GIT_SHALLOW TRUE
    SYSTEM
    EXCLUDE_FROM_ALL
)

# ST HAL Driver
FetchContent_Declare(
    stm32_hal_driver
    GIT_REPOSITORY https://github.com/STMicroelectronics/${MCU_FAMILY_LOWER}xx-hal-driver.git
    GIT_TAG v1.1.10
    GIT_SHALLOW TRUE
    SYSTEM
    EXCLUDE_FROM_ALL
)

FetchContent_MakeAvailable(arm_cmsis stm32_cmsis stm32_hal_driver)


# ======================================================================
# Targets
# ======================================================================
# CMSIS Dependencies from both ARM and STMicroelectronics
add_library(arm_cmsis INTERFACE)
target_include_directories(arm_cmsis SYSTEM INTERFACE
    ${arm_cmsis_SOURCE_DIR}/CMSIS/Core/Include
)
add_library(arm::cmsis ALIAS arm_cmsis)

add_library(stm32_cmsis INTERFACE)
target_include_directories(stm32_cmsis SYSTEM INTERFACE
    ${stm32_cmsis_SOURCE_DIR}/Include
)
add_library(stm32::cmsis ALIAS stm32_cmsis)

# LL Library: stm32::ll
add_library(stm32_ll STATIC)
target_link_libraries(stm32_ll PUBLIC stm32::cmsis arm::cmsis bsp::mcu_config)
# Headers might couple with each other, so not use File Set to avoid missing headers
target_include_directories(stm32_ll SYSTEM PUBLIC
    ${stm32_hal_driver_SOURCE_DIR}/Inc
    ${stm32_hal_driver_SOURCE_DIR}/Inc/Legacy
)
# Other consumers including those headers also need these macros
target_compile_definitions(stm32_ll PUBLIC
    ${MCU_MODEL}
    USE_FULL_LL_DRIVER
)
target_sources(stm32_ll PRIVATE
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_ll_gpio.c
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_ll_rcc.c
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_ll_usart.c
)
add_library(stm32::ll ALIAS stm32_ll)

# HAL Library: stm32::hal
add_library(stm32_hal STATIC)
target_link_libraries(stm32_hal PUBLIC stm32::cmsis arm::cmsis bsp::mcu_config)
target_include_directories(stm32_hal SYSTEM PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/bsp/hal_config
    ${stm32_hal_driver_SOURCE_DIR}/Inc
    ${stm32_hal_driver_SOURCE_DIR}/Inc/Legacy
)
target_compile_definitions(stm32_hal PUBLIC
    ${MCU_MODEL}
    USE_HAL_DRIVER
)
target_sources(stm32_hal PRIVATE
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal.c
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal_rcc.c
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal_gpio.c
    ${stm32_hal_driver_SOURCE_DIR}/Src/${MCU_FAMILY_LOWER}xx_hal_cortex.c
)
add_library(stm32::hal ALIAS stm32_hal)

