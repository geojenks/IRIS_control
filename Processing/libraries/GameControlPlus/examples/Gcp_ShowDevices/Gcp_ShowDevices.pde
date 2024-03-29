/**
 Displays all control devices that are attached.
 
 When this sketch runs it will seek all control devices attached
 to the system and display a list of devices and a list of the 
 control inputs. This information will be stored in two files
 'devices.txt' and 'detils.txt' which can be found in the sketch
 data folder
 
 for Processing V3
 (c) 2020 Peter Lager
 */
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

import java.awt.Font;

// Need G4P library
import g4p_controls.*;

ControlIO controlIO;

// G4P controls
GLabel label1, label2; 
GTextArea txaListing, txaDetails; 

Font font = new Font("Monospaced", Font.PLAIN, 12);

public void setup() {
  size(800, 600, JAVA2D);
  surface.setTitle("GCP Show all connected devices");
  createGUI();
  txaListing.setFont(font);
  txaDetails.setFont(font);
  // Initialise the IO control
  controlIO = ControlIO.getInstance(this);
  // Get a list of available devices, save to file and display
  String devices = controlIO.deviceListToText("");
  saveStrings(dataPath("devices.txt"), split(devices, '\n'));
  txaListing.setText(devices + "\n ");
  // Get a details of available devices, save to file and display
  String details = controlIO.devicesToText("");
  saveStrings(dataPath("details.txt"), split(details, '\n'));
  txaDetails.setText(details + "\n ");
}

public void draw() {
  background(230);
}

// Create all the GUI controls. 
public void createGUI() {
  surface.setTitle("Game Control Plus - show available input devices");
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.PURPLE_SCHEME);
  G4P.setCursor(ARROW);
  label1 = new GLabel(this, 0, 0, 800, 20);
  label1.setText("Available Devices");
  label1.setTextBold();
  label1.setOpaque(true);
  label2 = new GLabel(this, 0, 180, 800, 20);
  label2.setText("Device Details");
  label2.setTextBold();
  label2.setOpaque(true);
  txaListing = new GTextArea(this, 0, 20, 800, 160, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  txaListing.setOpaque(true);
  txaDetails = new GTextArea(this, 0, 200, 800, 400, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  txaDetails.setOpaque(true);
}