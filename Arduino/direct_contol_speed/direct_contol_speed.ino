// Consider changing these to interupts!

#include <AccelStepper.h>
// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver:
const int dirPin = 28;
const int stepPin = 26;
String readString;
const int dirPin_2= 32;
const int stepPin_2=30;
//const int microstep= 1; //Only the stepper motor 1 needs microstepping
const int stepsPerRevolution = 3200;

int incomingByte = 0; // for incoming serial data
int input = 0;

#define motorInterfaceType 1
// Create a new instance of the AccelStepper class:
AccelStepper stepper1 = AccelStepper(motorInterfaceType, stepPin, dirPin);
AccelStepper stepper2 = AccelStepper(motorInterfaceType, stepPin_2, dirPin_2);
AccelStepper stepper;
int target = 0;
int target1 = 0;
int target2 = 0;
int motor = 1;

//String val; // Data received from the serial port
int ledPin = 13; // Set the pin to digital I/O 13
boolean ledState = LOW; //to toggle our LED

// the possible states of the state-machine
typedef enum {  NONE, GOT_R, GOT_A, GOT_G } states;
// current state-machine state
states state = NONE;
// current partial number
float currentValue;
int decimal = 0;

/*
#include <Rotary.h>
volatile long rot, last_rot, temp_rot = 0;
// Rotary encoder is wired with the common to ground and the two
// outputs to pins 5 and 6.
Rotary rotary = Rotary(2, 3);

// Counter that will be incremented or decremented by rotation.
int counter = 0;
*/

void setup() 
{
  // Set the maximum speed in steps per second:
  stepper1.setMaxSpeed(1800);
  stepper2.setMaxSpeed(1800);
  stepper1.setSpeed(0);
  stepper1.runSpeed();
  stepper2.setSpeed(0);
  stepper2.runSpeed();
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  
  pinMode(ledPin, OUTPUT); // Set pin as OUTPUT
  //initialize serial communications at a 9600 baud rate
  Serial.begin(9600); // 115200
  //Serial.setTimeout(10);
  establishContact();  // send a byte to establish contact until receiver responds 
  state = NONE;
/*
  //Z rising pulse from encoder activated ai2().
  pinMode(4, INPUT_PULLUP); // internal pullup input pin 4
  attachInterrupt(2, rotate, CHANGE);
  attachInterrupt(3, rotate, CHANGE);
  attachInterrupt(4, ai2, RISING);
*/
}

void loop (){
  // motor control with gamepad:
  stepper1.runSpeed();
  stepper2.runSpeed();
  if (Serial.available() > 12){
    while (Serial.available ()){
      stepper1.runSpeed();
      stepper2.runSpeed();
      //Serial.print(counter);
      byte incoming = Serial.read();
      if (incoming == '<'){
        while (1){
          incoming = Serial.read();
          if (incoming == '>'){
            break;
          }
          processIncomingByte(incoming);
        }
      }
    }
  }
  // encoder feedback
  /*
  unsigned char result = rotary.process();
  if (result == DIR_CW) {
    counter++;
    //if (counter % 100 == 0){
    //  Serial.print(counter);
    //}
  } else if (result == DIR_CCW) {
    counter--;
    //if (counter % 100 == 0){
    //  Serial.print(counter);
    //}
  }
  */
  /*
  if( rot != temp_rot ){
      Serial.print("rot = ");
      Serial.print (rot);
      Serial.print(", resolution = ");
      Serial.print (counter-last_rot);
      temp_rot = rot;
      Serial.print(", last turn at ");
      Serial.print(last_rot);
      last_rot = counter;
    }
    */
  //delay(50);
}  // end of loop

/*
// loop to test stepper motor:
void loop() {

  // send data only when you receive data:
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();
    input = incomingByte ; 

    switch (input) { 
      case '1':         // if input=1 ....... motors turn forward
        forward();
        break;
      case '2':         // if input=2 ....... motors turn backward
        backward();
        break;
    }
    delay(200);
    input=0;
  }
}

void forward() {          //function of forward 
  digitalWrite(dirPin, HIGH);
  Serial.println ("forwards");
  digitalWrite(stepPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(stepPin, LOW);
}

void backward() {         //function of backward
  Serial.println ("backwards");
  digitalWrite(dirPin, LOW);

 
  for(int x = 0; x < stepsPerRevolution; x++)
  {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(100);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(100);
  }
  delay(1000); // Wait a second
}

*/

void processIncomingByte (const byte b)
{
  //Serial.print(b);
  char c;
  c = (char) b;
  //Serial.print(c);
  if (c == '.'){
    decimal++;
  }
  if (isdigit (c)) {
    //Serial.print("number");
    if (decimal){
      currentValue += float(c - '0')/pow(10,decimal);
      decimal++;
      //Serial.print(currentValue);
    }
    else {
      currentValue *= 10;
      currentValue += c - '0';
    }
    
  }  // end of digit
  else {
    //Serial.println(c);
    // The end of the number signals a state change
    if (c != '.'){
      decimal = 0;
      handlePreviousState ();
      // set the new state, if we recognize it
      switch (c)
        {
        case 'R':
          state = GOT_R;
          break;
        case 'A':
          state = GOT_A;
          break;
        case 'G':
          state = GOT_G;
          break;
        default:
          state = NONE;
        break;
        }
    }  // end of switch on incoming byte
  } // end of not digit
  //delay(500);
} // end of processIncomingByte

void handlePreviousState ()
{
  switch (state)
  {
  case GOT_R:
    processRadius (currentValue);
    break;
  case GOT_A:
    processAngle (currentValue);
    break;
  case GOT_G:
    processGear (currentValue);
    break;
  }  // end of switch  
  currentValue = 0.00;
}  // end of handlePreviousState

void processRadius (float value)//const unsigned int value)
{
  if ((int) value -90 >= 0){         // if input=1 ....... motors turn forward
    digitalWrite(dirPin, HIGH);
  }
  else {
    digitalWrite(dirPin, LOW);
  }
  Serial.print ("Radius_v = ");
  Serial.print ((((int)value-90)/abs((int)value-90)) // get the +/- sign
      *((int)value-90)*((int)value-90)/2);
  if (abs((int) value - 90) < 5){
    stepper1.setSpeed(0);//*microstep);
    //digitalWrite(stepPin, LOW);
  }
  else {
    stepper1.setSpeed(
      (((int)value-90)/abs((int)value-90)) // get the +/- sign
      *((int)value-90)*((int)value-90)/2
      );//*microstep);
    //digitalWrite(stepPin, HIGH);
  }
  //stepper1.runSpeed();
  //delay(20);
} // end of processRPM

void processAngle (float value)//const unsigned int value)
{
  /*
    if ((int) value -90 >= 0){         // if input=1 ....... motors turn forward
    digitalWrite(dirPin, HIGH);
  }
  else {
    digitalWrite(dirPin, LOW);
  }
  Serial.print ("Angle = ");
  Serial.println ((((int)value-90)/abs((int)value-90)) // get the +/- sign
      *((int)value-90)*((int)value-90)/2);
  if (abs((int) value - 90) < 5){
    stepper2.setSpeed(0);//*microstep);
    //digitalWrite(stepPin, LOW);
  }
  else {
    stepper2.setSpeed(
      (((int)value-90)/abs((int)value-90)) // get the +/- sign
      *((int)value-90)*((int)value-90)/2
      );//*microstep);
    //digitalWrite(stepPin, HIGH);
  }
  */
  Serial.print (", Angle_v = ");
  Serial.print (value-90);
  Serial.print (", Radius_p = ");
  Serial.print(stepper1.currentPosition())
  Serial.print (", Angle_p = ");
  Serial.println(stepper2.currentPosition())
  
  stepper2.setSpeed(10*((int)value-90));
  //stepper2.runSpeed();
  
} // end of processSpeed

void processGear (float value)//const unsigned int value)
{
  // do something with gear 
  Serial.print ("Gear = ");
  Serial.println (value);  
} // end of processGear

void establishContact() {
  while (Serial.available() <= 0) {
  Serial.println("A");   // send a capital A
  delay(300);
  }
}
