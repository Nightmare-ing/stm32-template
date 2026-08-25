# ======================================================================
# Automatically generate .hex and .bin files for STM32 targets after build
# ======================================================================
function(stm32_add_hex_bin_targets TARGET_NAME)
    set(HEX_FILE "$<TARGET_FILE_DIR:${TARGET_NAME}>/$<TARGET_FILE_BASE_NAME:${TARGET_NAME}>.hex")
    set(BIN_FILE "$<TARGET_FILE_DIR:${TARGET_NAME}>/$<TARGET_FILE_BASE_NAME:${TARGET_NAME}>.bin")

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${TARGET_NAME}> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${TARGET_NAME}> ${BIN_FILE}
        COMMAND ${CMAKE_SIZE} --format=berkeley $<TARGET_FILE:${TARGET_NAME}>
        COMMENT "Generating ${HEX_FILE} and ${BIN_FILE} and printed memory usage:"
    )
endfunction()

# ======================================================================
# Generate compile_commands.json and ln to root dir
# ======================================================================
function(stm32_setup_compile_commands)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON PARENT_SCOPE)
    if(EXISTS "${CMAKE_BINARY_DIR}/compile_commands.json")
        file(CREATE_LINK
            ${CMAKE_BINARY_DIR}/compile_commands.json
            ${CMAKE_SOURCE_DIR}/compile_commands.json
            SYMBOLIC
            COPY_ON_ERROR
        )
    endif()
endfunction()
        

