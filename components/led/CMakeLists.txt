add_library(led STATIC)

target_sources(led PRIVATE
    src/led.c
)

target_sources(led PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include
    FILES include/led/led.h
)

target_link_libraries(led
    PRIVATE
        ${PROJECT_NAME}_architecture)

add_library(components::led ALIAS led)
