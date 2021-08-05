unsigned long t;

void setup() {
  Serial.begin(115200); // initialize serial communication at 9600 bits per second
  //t = millis();
}


void loop() {
  //if(t - millis() >= 4) {
    Serial.println(analogRead(A7));
    //t = millis();
  //}
}
