#include "stm32f1xx_hal.h"

int main(void) {
    HAL_Init();

    // Enable GPIOA clock
    __HAL_RCC_GPIOB_CLK_ENABLE();

    // Configure PB5 as output
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = GPIO_PIN_5;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    while (1) {
        HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_5);
        HAL_Delay(500);
    }

    return 0;
}

// Interrupt handler for HAL lib
void SysTick_Handler(void) { HAL_IncTick(); }
