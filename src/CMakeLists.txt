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
set(_map_file "$<TARGET_FILE_DIR:${PROJECT_NAME}>/$<TARGET_PROPERTY:NAME>.map")
target_link_options(${PROJECT_NAME} PRIVATE
    -Wl,--print-memory-usage
    "-Wl,-Map=${_map_file}"
)
set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${_map_file}")

stm32_add_hex_bin_targets(${PROJECT_NAME})
