//package org.gamecontrolplus.gui;
//
//import org.gamecontrolplus.ControlButton;
//
//public class LButton extends LBaseInput {
//
//	ControlButton button;
//	
//	boolean isPressed;
//	
//	public LButton(LConfigUI ccw, ControlButton pbutton, float x, float y){
//		super(ccw, x, y, 1, 1);
//		uiType = UI_BUTTON;
//		inputTypeName = "BUTTON";
//		button = pbutton;
//		name = button.getName();
//		namePos = 20 + (int)(ccw.input_UI_length - 20 - app.textWidth(name)) / 2;
//		backCol = UI_E_BACK[uiType];
//		fontBaseLine = (ccw.desc_UI_height + ccw.fontSize) / 2;
//	}
//	
//	public void update(){
//		isPressed = button.pressed();
//	}
//	
//	public void draw(){
//		app.pushMatrix();
////		app.pushStyle();
//		app.translate(px, py);
//		
//		drawBackground();
//	
//		// Pressed ?
//		app.stroke(BORDER);
//		app.strokeWeight(1);
//		app.fill(isPressed ? PRESSED : RELEASED);
//		app.ellipse(ccw.input_UI_height/2, ccw.input_UI_height/2, ccw.indicator_d, ccw.indicator_d);
//		
//		drawConnectors();
//		drawControlHighlight();
//		
////		app.popStyle();
//		app.popMatrix();
//	}
//}
//
