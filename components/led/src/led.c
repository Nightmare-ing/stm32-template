#include "led/led.h"
#include <assert.h>
#include <stddef.h>

void led_init(struct led *led, const struct led_io *io) {
    assert(led != NULL);
    assert(io != NULL);
    assert(io->context != NULL);
    assert(io->set != NULL);

    led->io = *io;
    led->is_on = false;

    led->io.set(led->io.context, led->is_on);
}

void led_on(struct led *led) {
    led->io.set(led->io.context, true);
    led->is_on = true;
}

void led_off(struct led *led) {
    led->io.set(led->io.context, false);
    led->is_on = false;
}

void led_toggle(struct led *led) {
    led->io.set(led->io.context, !led->is_on);
    led->is_on = !led->is_on;
}

bool led_is_on(const struct led *led) { return led->is_on; }
