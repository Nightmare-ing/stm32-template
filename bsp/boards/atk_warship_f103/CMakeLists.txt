# Basic board initialization
add_library(bsp_atk_warship_f103_core STATIC)

target_sources(bsp_atk_warship_f103_core PRIVATE
    core/board_clock.c
)
target_sources(bsp_atk_warship_f103_core PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include
    FILES include/board/board.h
)

target_link_libraries(bsp_atk_warship_f103_core
    PRIVATE
        ${PROJECT_NAME}::project_options
        ${PROJECT_NAME}::compiler_warnings
        ${PROJECT_NAME}::target_abi
        stm32_hal
)

add_library(bsp::board_core ALIAS bsp_atk_warship_f103_core)

# Led adapter
add_library(board_atk_warship_f103_led STATIC)

target_sources(board_atk_warship_f103_led PRIVATE
    adapters/led.c
)
target_sources(board_atk_warship_f103_led PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include
    FILES include/board/led.h
)

target_link_libraries(board_atk_warship_f103_led
    PUBLIC
        ${PROJECT_NAME}::project_options
        ${PROJECT_NAME}::compiler_warnings
        ${PROJECT_NAME}::target_abi
        components::led
    PRIVATE
        stm32_hal
)

add_library(bsp::led ALIAS board_atk_warship_f103_led)

