#include <SPI.h>
#include <MCP3XXX.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>

#include "index.h"

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
ESP8266WebServer server(80);

MCP3002 adc;
int brk;
int maxBrk = 0;
int minBrk = 1023;
int throt;
int maxThrot = 0;
int minThrot = 1023;
long startTime = 0;

void handleRoot() {
    String s = MAIN_page;
    server.send(200, "text/html", s);
}

void handleADC() {
    brk = adc.analogRead(BREAK);
    throt = adc.analogRead(THROTTLE);
    String message = "[";
    message += String(brk);
    message += ",";
    message += String(throt);
    message += ",";
    message += String(maxBrk);
    message += ",";
    message += String(minBrk);
    message += ",";
    message += String(maxThrot);
    message += ",";
    message += String(minThrot);
    message += "]";
    server.send(200, "application/json", message);
    startTime = millis();
}

void setup() {
    Serial.begin(115200);
    SPI.begin();
    adc.begin(ADCCS, MOSI, MISO, SCK);

    Serial.print("Connecting to "); 
    Serial.println(ssid);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    
    Serial.println("");
    Serial.println("WiFi connected.");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());

    if (!MDNS.begin("theflock")) {
        Serial.println("Error setting up MDNS responder!");
    }

    server.on("/", handleRoot);
    server.on("/readADC", handleADC);
    server.begin();
    Serial.println("HTTP Server Started");
}

void loop() {
    //server.handleClient();
    if (millis() - startTime > 100) {
        brk = adc.analogRead(BREAK);
        throt = adc.analogRead(THROTTLE);
        if (brk > maxBrk) maxBrk = brk;
        if (brk < minBrk) minBrk = brk;
        if (throt > maxThrot) maxThrot = throt;
        if (throt < minThrot) minThrot = throt;
        Serial.print("Throttle: ")
        Serial.println(throt);
        Serial.print("Max Throttle: ")
        Serial.println(maxThrot);
        Serial.print("Min Throttle: ")
        Serial.println(minThrot);
        Serial.print("Break: ");
        Serial.println(brk);
        Serial.print("Max Break: ")
        Serial.println(maxBrk);
        Serial.print("Min Break: ")
        Serial.println(minBrk);
        startTime = millis();
    }
}
