import processing.serial.*;

import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import cc.arduino.*;
import org.firmata.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

// since we're doing serial handshaking,
// we need to check if we've heard from the microcontroller
boolean firstContact = false;

ControlDevice cont;
ControlIO control;

//Arduino arduino;

float thumb;
float tilt;

void setup() {
//  size(360, 200);

  control = ControlIO.getInstance(this);
  cont = control.getMatchedDevice("IRIS_xbox");

  if (cont == null) {
    println("not today chump");
    System.exit(-1);
  }

  //println(Arduino.list());
  //  arduino = new Arduino(this, Arduino.list()[0], 9600);
  //  arduino.pinMode(10, Arduino.SERVO);

  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  delay(300);
}

public void getUserInput() {
  // assign our float value
  //access the controller.
  tilt = map(cont.getSlider("radius").getValue(), -1, 1, 0, 180);
  thumb = map(cont.getSlider("angle").getValue(), -1, 1, 0, 180);
  //println(thumb);
  //println(tilt);
}


void draw() {
//  getUserInput();
//  background(thumb, 100, 255);

  // arduino.servoWrite(10, (int)thumb);

  //  if (abs(thumb)  > 5){
  //    myPort.write(str(thumb));
  //    println(thumb);
  //  }

  //  if ( myPort.available() > 0) {  // If data is available,
  //    val = myPort.readStringUntil('\n');         // read it and store it in val
  //    println(val); //print it out in the console
  //  }
}


void serialEvent( Serial myPort) {
  //put the incoming data into a String -
  //the '\n' is our end delimiter indicating the end of a complete packet
  val = myPort.readStringUntil('\n');
  //make sure our data isn't empty before continuing
  if (val != null) {
    //trim whitespace and formatting characters (like carriage return)
    val = trim(val);
    if (val.length() > 0){
      println(val);
    }

    //look for our 'A' string to start the handshake
    //if it's there, clear the buffer, and send a request for data
    if (firstContact == false) {
      if (val.equals("A")) {
        myPort.clear();
        firstContact = true;
        myPort.write("A");
        println("contact");
      }
    } //else { //if we've already established contact, keep getting and parsing data
      //println(val);
      //thumb = 0;
      getUserInput();
      //println("hey");
      //println(tilt);
      //println(thumb);
      //myPort.write(byte('<'));
      //String string = "A" + str(thumb).substring(0,5) + "R" + str(tilt).substring(0,5);
      //myPort.write(string);
      
      myPort.write(byte('<'));
      myPort.write(byte('A'));
      //println(int(thumb));
      //myPort.write(byte('5'));
      myPort.write(str(thumb).substring(0,5));
      //println(int(tilt));
      myPort.write(byte('R'));
      myPort.write(str(tilt).substring(0,5));
      myPort.write('>');
      
      //delay(50);
      //myPort.write(byte('>'));
      //println('<');
      //println('A'+(char)thumb+'R'+(char)tilt+'>');
      /*if (abs(thumb)  > 5)s{
       myPort.write('<'+'A'+(char)thumb+'>');
       //println(thumb);
       }
       if (abs(tilt)  > 5){
       myPort.write('R'+(char)tilt+'\n');
       //println(tilt);
       }*/
      //delay(100);
      // if (mousePressed == true)
      // {                           //if we clicked in the window
      //   myPort.write('1');        //send a 1
      //   println("1");
      // }

      // when you've parsed the data you have, ask for more:
      //myPort.write("A");
    //}
  }
}
