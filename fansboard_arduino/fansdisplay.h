

#ifndef _FANSDISPLAY_H_
#define _FANSDISPLAY_H_

#include <stdint.h>
#include <memory>
#include <Arduino.h>

class Display {
public:
    Display() {}
    void begin();
    void update();
    void clear();
    void test();
    void show_num(uint32_t num);
    void show_str(String str);
    virtual ~Display() {}

private:
    void spi_send(uint8_t* buffer, uint16_t size);
    void set_asc_shift(uint8_t pos, char chr, int8_t shift);
    void bitr(int8_t n);
    void wr_str_to_buffer(String str, uint8_t* buffer);
};

#endif
