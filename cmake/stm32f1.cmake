# ======================================================================
# Flags for all static libraries and ELF
# ======================================================================
add_library(bsp_stm32f1_mcu_config INTERFACE)
# Cortex-M3 core and FPU configs
set(CPU_FLAGS
    -mcpu=cortex-m3
    -mthumb
    -mfloat-abi=soft
)

# Bare-metal common flags for optimization
set(ARCH_OPT_FLAGS
    -Wall                           # Enable all warnings
    -Wextra                         # Enable extra warnings
    -fdata-sections                 # Prepare for GC optimization
    -ffunction-sections
)
target_compile_options(bsp_stm32f1_mcu_config INTERFACE
    ${CPU_FLAGS}
    ${ARCH_OPT_FLAGS}
)
target_link_options(bsp_stm32f1_mcu_config INTERFACE
    ${CPU_FLAGS}
)

add_library(bsp::mcu_config ALIAS bsp_stm32f1_mcu_config)

# ======================================================================
# Flags for final ELF target
# ======================================================================
add_library(stm32_f1_linker INTERFACE)
target_link_libraries(stm32_f1_linker INTERFACE bsp::mcu_config)
set(LINKER_FLAGS
    --specs=nano.specs
    -Wl,--gc-sections
    -Wl,--print-memory-usage
    "-Wl,-Map=$<TARGET_PROPERTY:NAME>.map"
)
target_link_options(stm32_f1_linker INTERFACE
    ${LINKER_FLAGS}
)

add_library(stm32::f1_linker ALIAS stm32_f1_linker)
