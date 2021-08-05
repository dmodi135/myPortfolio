#include <MCP3XXX.h>

// adc pins definition
#define THROTTLE 1
#define BREAK 0

// pins definition
#define MISO 12
#define MOSI 13
#define SCK 14
#define ADCCS 4

// message definitions
byte message[] = {0x3A, 0x1A, 0x02, 0x30, 0x60, 0x72, 0x0D, 0x0A};
byte breakM[] = {0x3A, 0x1A, 0x02, 0x00, 0x43, 0x61, 0x0D, 0x0A};
//byte lockM[] = {0x3A, 0x1A, 0x02, 0x00, 0x43, 0x61, 0x0D, 0x0A};
const size_t messageSize = sizeof(message);

// SPI interfaces
MCP3002 adc;

byte throt = 0;
int brk = 0;



void setup() {
    Serial.begin(115200);
    adc.begin(ADCCS, MOSI, MISO, SCK);
    delay(100);
}

void loop() {
    brk = adc.analogRead(BREAK);
    if (brk < 400) {
        throt = map(constrain(adc.analogRead(THROTTLE), 266, 787), 265, 788, 0x72, 0xFF);
        message[3] = throt - 0x42;
        message[5] = throt;
        Serial.write(message, messageSize);
    } else if (brk < 500) {
        message[3] = 0x30;
        message[5] = 0x72;
        Serial.write(message, messageSize);
    } else {
        Serial.write(breakM, messageSize);
    }
    Serial.flush();
    delay(20);
}
