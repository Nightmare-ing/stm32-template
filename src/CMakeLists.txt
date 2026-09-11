add_executable(${PROJECT_NAME}
    main.c
)
set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".elf")

target_link_libraries(${PROJECT_NAME} PRIVATE
    bsp::baremetal_linker
    bsp::startup
    bsp::driver
)
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall                           # Enable all warnings
    -Wextra                         # Enable extra warnings
)

stm32_add_hex_bin_targets(${PROJECT_NAME})
