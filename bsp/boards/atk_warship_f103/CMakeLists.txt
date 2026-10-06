add_library(bsp_atk_warship_f103_led STATIC)

target_sources(bsp_atk_warship_f103_led PRIVATE
    adapters/led.c
)
target_sources(bsp_atk_warship_f103_led PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include
    FILES include/board/led.h
)

target_link_libraries(bsp_atk_warship_f103_led
    PUBLIC
        components::led
    PRIVATE
        stm32_hal
)

add_library(bsp::led ALIAS bsp_atk_warship_f103_led)


