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
    rot ++;}
  else {
    //counter--;
    rot --;}
    //Serial.println(counter); 
}
