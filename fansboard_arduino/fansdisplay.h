

#ifndef _FANSDISPLAY_H_
#define _FANSDISPLAY_H_

#include <stdint.h>
#include <memory>

class Display {
public:
    Display() {}
    void begin();
    void update();
    void test();
    virtual ~Display() {}

private:
    void spi_send(uint8_t* buffer, uint16_t size);
};

#endif
