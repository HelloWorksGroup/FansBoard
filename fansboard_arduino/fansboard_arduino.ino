
// these two lib is included in AutoConnect.h
// #include <ESP8266WiFi.h>
// #include <ESP8266WebServer.h>

#include <ESP8266mDNS.h>
#include <Scheduler.h>

// 因为CS pin使用了LED pin，所以需要修改LED pin避免与AutoConnect库冲突。
#define LED_BUILTIN (15)
#include <AutoConnect.h>
// require lib: pagebuilder, arduinoJSON
#include "fansdisplay.h"
#define LED_PIN (2)
#define FLASH_PIN (0)

ESP8266WebServer WEBSERVER;
AutoConnect PORTAL(WEBSERVER);
AutoConnectConfig Config("FansBoard-v1","1234qwer");
Display disp;

void testPage() {
    char jsonContent[] = "{""ret"":'0'}";
    WEBSERVER.send(200, "application/json", jsonContent);
}

class TimerTask : public Task {
protected:
    void setup() {
        count=0;
    }

    void loop() {
        count += 1;
        disp.show_num(count);
        delay(1000);
    }
private:
    uint16_t count;
} timer_task;

void setup() {
    Serial.begin(115200);
    Serial.println("");
    Serial.println("hello");
    disp.begin();
    disp.test();
    disp.update();

    WEBSERVER.on("/", testPage);
    Config.autoReconnect = true;
    Config.reconnectInterval = 7;
    PORTAL.config(Config);
    if (PORTAL.begin()) {
        Serial.println("WiFi connected: " + WiFi.localIP().toString());
        if (MDNS.begin("fansboard")) {
            MDNS.addService("http", "tcp", 80);
        }
    }
    Scheduler.start(&timer_task);
    Scheduler.begin();
}


void loop() {
    PORTAL.handleClient();
}
