
#include "fansdisplay.h"
// #include "fansfonts.h"

#include <Arduino.h>
#include <SPI.h>

#define SPI_CS_PIN (2)

uint8_t display_init_array[5][8]= {
    {0xC,0x1,0xC,0x1,0xC,0x1,0xC,0x1},
    {0xB,0x7,0xB,0x7,0xB,0x7,0xB,0x7},
    {0xA,0x2,0xA,0x2,0xA,0x2,0xA,0x2},
    {0x9,0x0,0x9,0x0,0x9,0x0,0x9,0x0},
    {0xF,0x0,0xF,0x0,0xF,0x0,0xF,0x0}
};

uint8_t display_buffer[32] = {
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
    0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01,
    0x81, 0x81, 0x42, 0x42, 0x24, 0x24, 0x18, 0x18,
};

uint8_t display_cache[8];

void Display::spi_send(uint8_t* buffer, uint16_t size)
{
    digitalWrite(SPI_CS_PIN, 0);
    SPI.transfer(buffer, size);
    digitalWrite(SPI_CS_PIN, 1);
}

void Display::begin() {
    pinMode(SPI_CS_PIN, OUTPUT);
    digitalWrite(SPI_CS_PIN, 1);
    SPI.setClockDivider(SPI_CLOCK_DIV2);
    SPI.begin();
    for (uint8_t i = 0; i < 5; i++) {
        spi_send(display_init_array[i], 8);
    }
}

void Display::test() {
    memset(display_buffer, 0, sizeof(display_buffer));
    uint8_t var = 4;
    bool delta = false;
    for (uint8_t i = 0; i < 32; i++)
    {
        display_buffer[i] = var;
        this->update();
        delay(100);
        if(delta) {
            var >>= 1;
        } else {
            var <<= 1;
        }
        if(var==0) {
            if(delta) {
                var = 0x02;
            } else {
                var = 0x40;
            }
            delta = !delta;
        }
    }
}

void Display::update() {
    for (uint8_t i = 0; i < 8; i++) {
        for (uint8_t j = 0; j < 4; j++) {
            display_cache[j*2] = i+1;
            display_cache[j*2+1] = display_buffer[31-(i+j*8)];
        }
        spi_send(display_cache, 8);
    }
}
