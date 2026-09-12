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
