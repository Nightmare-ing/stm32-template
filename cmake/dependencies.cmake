include(FetchContent)

# ARM CMSIS 6
FetchContent_Declare(
    cmsis_core
    GIT_REPOSITORY https://github.com/ARM-software/CMSIS_6.git
    GIT_TAG v6.3.0
    GIT_SHALLOW TRUE
)

string(TOLOWER ${MCU_FAMILY} MCU_FAMILY_LOWER)
string(SUBSTRING ${MCU_FAMILY_LOWER} 5 -1 FAMILY_SHORT) # e.g., extract "f1"

# ST CMSIS Device F1
FetchContent_Declare(
    cmsis_device
    GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis-device-${FAMILY_SHORT}.git
    GIT_TAG v4.3.5
    GIT_SHALLOW TRUE
)

# ST HAL Driver
FetchContent_Declare(
    stm32_hal_driver
    GIT_REPOSITORY https://github.com/STMicroelectronics/${MCU_FAMILY_LOWER}xx-hal-driver.git
    GIT_TAG v1.1.10
    GIT_SHALLOW TRUE
)

FetchContent_MakeAvailable(cmsis_core cmsis_device stm32_hal_driver)
