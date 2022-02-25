
#include <Rotary.h>
volatile long rot, last_rot, temp_rot = 0;
// Rotary encoder is wired with the common to ground and the two
// outputs to pins 5 and 6.
Rotary rotary = Rotary(2, 3);

// Counter that will be incremented or decremented by rotation.
int counter = 0;
unsigned long starttime;
unsigned long elapsed;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); // 115200  state = NONE;

  //Z rising pulse from encoder activated ai2().
  pinMode(4, INPUT_PULLUP); // internal pullup input pin 4
  attachInterrupt(2, rotate, CHANGE);
  attachInterrupt(3, rotate, CHANGE);
  attachInterrupt(4, ai2, RISING);
  starttime = millis();
  elapsed = 0;
}

void loop() {
  // put your main code here, to run repeatedly:
  elapsed = millis() - starttime;
  if (elapsed % 10 == 0){
    Serial.print(elapsed);
    Serial.print(", ");
    Serial.println(counter);
    //Serial.println("!");
  }
/*  if( rot != temp_rot ){
      Serial.print("rot = ");
      Serial.print (rot);
      Serial.print(", resolution = ");
      Serial.print (counter-last_rot);
      temp_rot = rot;
      Serial.print(", last turn at ");
      Serial.println(last_rot);
      last_rot = counter;
    }
    */
}

// The resolution is 10000 steps per whole revolution, or 20000 if half_step is enabled. It sometimes misses 1 of these for seom reason??

void rotate() {
  // encoder interupt
  unsigned char result = rotary.process();
  if (result == DIR_CW) {
    counter++;
    //Serial.println(counter);
  } else if (result == DIR_CCW) {
    counter--;
    //Serial.println(counter);
  }
}

void ai2() {
  // encoder interupt
  // ai2 is activated if DigitalPin nr 4 is going from LOW to HIGH
  unsigned char result = rotary.process();
  if (result == DIR_CW) {
    //counter++;
    counter=counter+100000;
    rot ++;}
  else {
    //counter--;
    counter=counter-100000;
    rot --;}
    //Serial.println(counter); 
}
