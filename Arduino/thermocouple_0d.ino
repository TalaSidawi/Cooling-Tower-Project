/***************************************************
  Orignally written by Limor Fried/Ladyada for Adafruit Industries.
  BSD license, all text above must be included in any redistribution

  Code adapted by James Findley de Regt
  ..._0d intended to break TC reading in to separate function
  and to read from two different TCs 
 ****************************************************/

// MAX31855 works via SPI
#include <SPI.h>
#include "Adafruit_MAX31855.h"

// hardware SPI - SCK is D13; MISO is D12
// define chip select (CS) seperately for each TC
#define TC1pin 2
#define TC2pin 3
// create thermocouple objects
Adafruit_MAX31855 thermocouple1 (TC1pin);
Adafruit_MAX31855 thermocouple2 (TC2pin);
// Loop count variable
int runtime = 0;

// initialize stuff
void setup() {
  // Using monitor for test output
  Serial.begin(9600);
  //initialize the chips
  thermocouple1.begin();
  thermocouple2.begin();
  // chip needs a bit of time to "settle" 
  Serial.println("MAX31855 test");
  delay(500);
  Serial.print("Initializing sensor...");
  // Chip will throw errors if connected improperly
  if (!thermocouple1.begin()) {
    Serial.println("ERROR.");
    while (1) delay(10);
  }
  if (!thermocouple2.begin()) {
    Serial.println("ERROR.");
    while (1) delay(10);
  }
  Serial.println("DONE.");
}

// the main loop
void loop() {
  // Loop counter
  runtime++;
  Serial.print ("Runtime is: ");    Serial.print (runtime);   Serial.println (" seconds");
  // Grab TC1 data
  double temp1 [2];
  temp1 [0] = thermocouple1.readInternal();
  temp1 [1] = thermocouple1.readCelsius();

  // Print it
  Serial.println("Thermocouple 1");
  Serial.print("Internal Temp = ");  Serial.print(temp1[0]);   Serial.print("       Tip Temp = ");    Serial.println(temp1[1]);

  // Grab TC2 data
  double temp2 [2];
  temp2 [0] = thermocouple2.readInternal();
  temp2 [1] = thermocouple2.readCelsius();

  // Print it
  Serial.println("Thermocouple 2");
  Serial.print("Internal Temp = ");  Serial.print(temp2[0]);   Serial.print("       Tip Temp = ");    Serial.println(temp2[1]);

  Serial.println();
  delay(1000);
}

//double temp1 () {
//  double temp1 [2];
//  temp1 [0] = thermocouple1.readInternal();
//  temp1 [1] = thermocouple1.readCelcius();
//  return temp1;
//}
