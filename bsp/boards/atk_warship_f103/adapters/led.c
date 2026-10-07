#include "board/led.h"
#include <stm32f1xx_hal.h>

struct led_context {
    GPIO_TypeDef *port;
    uint16_t pin;
    bool active_low;
};

static void led_hal_set(void *context, bool status) {
    struct led_context *led_ctx = (struct led_context *)context;
    GPIO_PinState pin_state = led_ctx->active_low ? !status : status;
    HAL_GPIO_WritePin(led_ctx->port, led_ctx->pin,
                      pin_state ? GPIO_PIN_SET : GPIO_PIN_RESET);
}

const struct led_io board_led0_io = {
    .context =
        &(struct led_context){
            .port = GPIOB,
            .pin = GPIO_PIN_5,
            .active_low = true,
        },
    .set = led_hal_set,
};

void board_led_init() {
    __HAL_RCC_GPIOB_CLK_ENABLE();

    // turn off the led during config
    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_5, GPIO_PIN_SET);

    GPIO_InitTypeDef config = {
        .Pin = GPIO_PIN_5,
        .Mode = GPIO_MODE_OUTPUT_PP,
        .Pull = GPIO_NOPULL,
        .Speed = GPIO_SPEED_FREQ_LOW,
    };
    HAL_GPIO_Init(GPIOB, &config);
}
