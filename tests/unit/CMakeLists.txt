# Build unit tests for the led component
add_executable(test_led
    test_led.c
)

target_link_libraries(test_led PRIVATE
    ${PROJECT_NAME}::project_options
    ${PROJECT_NAME}::compiler_warnings
    ${PROJECT_NAME}::target_abi
    components::led
)

add_test(NAME test_led COMMAND test_led)

