set(TARGET_NAME stm32_template_app)
add_executable(${TARGET_NAME}
    main.c
)
set_target_properties(${TARGET_NAME} PROPERTIES SUFFIX ".elf")

target_link_libraries(${TARGET_NAME} PRIVATE
    bsp::baremetal_linker
    bsp::startup
    bsp::driver
)
target_compile_options(${TARGET_NAME} PRIVATE
    -Wall                           # Enable all warnings
    -Wextra                         # Enable extra warnings
)
set(_map_file "$<TARGET_FILE_DIR:${TARGET_NAME}>/$<TARGET_PROPERTY:NAME>.map")
target_link_options(${TARGET_NAME} PRIVATE
    -Wl,--print-memory-usage
    "-Wl,-Map=${_map_file}"
)
set_property(TARGET ${TARGET_NAME} APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${_map_file}")
add_executable(stm32_template::app ALIAS ${TARGET_NAME})

stm32_add_hex_bin_targets(${TARGET_NAME})
