#include <SPI.h>
#include <MFRC522.h>
#include <MCP3XXX.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

// adc pins definition
#define THROTTLE 1
#define BREAK 0

// pins definition
#define MISO 12
#define MOSI 13
#define SCK 14
#define RFID_RST 16
#define RFID_CS 2
#define ADCCS 4
#define ENLIGHT 5

// network credentials
const char* ssid       = "ssid";
const char* password   = "password";
const char* softAPssid = "TheFlock";
const char* softAPpass = "teslascootersinc";
bool joinedNetwork = true;
ESP8266WebServer server(80);

// message definitions
byte message[] = {0x3A, 0x1A, 0x02, 0x30, 0x60, 0x72, 0x0D, 0x0A};
byte breakM[] = {0x3A, 0x1A, 0x02, 0x00, 0x43, 0x61, 0x0D, 0x0A};
byte lockM[] = {0x3A, 0x1A, 0x02, 0x00, 0x43, 0x61, 0x0D, 0x0A};
const size_t messageSize = sizeof(message);

// card states
byte readCard[7];
byte storedIDs[10][7];
bool lock;

// SPI interfaces
MFRC522 rfid(RFID_CS, RFID_RST);
MCP3002 adc;

byte throt = 0;
int brk = 0;

void handleRoot() {
  server.send(200, "text/html", "<h1>You are connected</h1>");
}

void setup() {
    lock = false;
    Serial.begin(115200);
    SPI.begin();
    rfid.PCD_Init();
    adc.begin(ADCCS, MOSI, MISO, SCK);

    Serial.print("Connecting to "); 
    Serial.println(ssid);
    WiFi.begin(ssid, password);
    unsigned long startTime = millis();
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        if (millis() - startTime > 10000) {
            joinedNetwork = false;
            break;
        }
    }
    Serial.println("");
    if (joinedNetwork) {
        Serial.println("WiFi connected.");
        Serial.println("IP address: ");
        Serial.println(WiFi.localIP());
    } else {
        Serial.print("Setting up soft-AP ...");
        Serial.println(WiFi.softAP(softAPssid, softAPpass) ? "Ready" : "Failed");
        Serial.println("IP address: ");
        Serial.println(WiFi.softAPIP());
    }
    server.on("/", handleRoot);
    server.begin();
    Serial.println("HTTP Server Started");
}

void loop() {
    server.handleClient();
    if (rfid.PICC_IsNewCardPresent()) {
        getID();
        if (findID()) {
            lock != lock;
        }
    }
    //if (lock) {
        //Serial.write(lockM, messageSize);
    //} else {
        brk = adc.analogRead(BREAK);
        if (brk < 500) {
            throt = map(adc.analogRead(THROTTLE), 0, 1023, 0x72, 0xFF);
            message[3] = throt - 0x42;
            message[5] = throt;
            Serial.write(message, messageSize);
        } else if (brk < 800) {
            message[3] = 0x30;
            message[5] = 0x72;
            Serial.write(message, messageSize);
        } else {
            Serial.write(breakM, messageSize);
        }
    //  }
    Serial.flush();
    delay(10);
}

void getID() {
    if (!rfid.PICC_ReadCardSerial()) {
        return;
    }
    for (uint8_t i = 0; i < 7; i++) {
        readCard[i] = rfid.uid.uidByte[i];
    }
    rfid.PICC_HaltA();
}

bool findID() {
    for (auto& storedID: storedIDs) {
        if (check(storedID)) {
            return true;
        }
    }
    return false;
}

bool check(byte correct[]) {
    for(uint8_t i = 0; i < 7; i++) {
        if(correct[i] != readCard[i]) {
            return false;
        }
    }
    return true;
}
