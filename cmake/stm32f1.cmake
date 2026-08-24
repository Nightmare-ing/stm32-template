add_library(stm32_f1_flags INTERFACE)

# Cortex-M3 core and FPU configs
set(CPU_FLAGS
    "-mcpu=cortex-m3"
    "-mthumb"
    "-mfloat-abi=soft"
)

# Bare-metal common flags for optimization
set(COMMON_FLAGS
    -Wall                           # Enable all warnings
    -Wextra                         # Enable extra warnings
    -fdata-sections                 # Prepare for GC optimization
    -ffunction-sections
)
target_compile_options(stm32_f1_flags INTERFACE
    ${CPU_FLAGS}
    ${COMMON_FLAGS}
)

# Linker flags
set(LINKER_FLAGS
    --specs=nano.specs
    -Wl,--gc-sections
    -Wl,--print-memory-usage
)
target_link_options(stm32_f1_flags INTERFACE
    ${CPU_FLAGS}
    ${LINKER_FLAGS}
)

add_library(stm32::f1_flags ALIAS stm32_f1_flags)
