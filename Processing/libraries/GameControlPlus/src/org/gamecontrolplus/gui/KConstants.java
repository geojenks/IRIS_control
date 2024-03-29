/*
 * Part of the Game Control Plus library - http://www.lagers.org.uk/gamecontrol
 * 
 * Copyright (c) 2020 Peter Lager
 * <quark(a)lagers.org.uk> http:www.lagers.org.uk
 * 
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it freely,
 * subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented;
 * you must not claim that you wrote the original software.
 * If you use this software in a product, an acknowledgment in the product
 * documentation would be appreciated but is not required.
 * 
 * 2. Altered source versions must be plainly marked as such,
 * and must not be misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source distribution.
 * 
 */

package org.gamecontrolplus.gui;

public interface KConstants {

	final float INPUT_UI_HEIGHT	= 24;
	final float DESC_UI_HEIGHT	= 30;
	final float ELEMENT_UI_GAP	= 4;
	final float INPUT_UI_LENGTH	= 220;
	final float DESC_UI_LENGTH	= 300;
	final float TEXTFIELD_GAP	= 4;
	final float INICATOR_D		= 12;
	
	final float CONNECTOR_SIZE_R	= 10; // radius
	final float CONNECTOR_SIZE_R2	= CONNECTOR_SIZE_R * CONNECTOR_SIZE_R ; // radius squared
	final float CONNECTOR_SIZE_D	= 2 * CONNECTOR_SIZE_R ; // radius
	// Connector type
	final int INPUT 			= 0x01;
	final int DESC 				= 0x02;

	final float FONT_SIZE 		= 12;

	final int PANEL_WIDTH		= 320;
	final int PANEL_HEIGHT		= 280;
	
	// UI element type IDs
	final int UI_BUTTON			= 0x01;
	final int UI_COOLIEHAT		= 0x02;
	final int UI_SLIDER			= 0x03;
	final int UI_DESCRIPTOR		= 0x04;
	
	final int[] UI_E_BACK		= new int[] { 0, 0xFFFFD0D0, 0xFFD0FFD0, 0xFFD0D0FF, 0xFFFFD0D0 };
	
	final int BACKGROUND			= 0xFFF0FFF0;
	final int PANEL					= 0xFF208020;
	final int BORDER 				= 0xFF4040A0;
	final int CONNECTION			= 0xFF8080A0;
	final int HIGHLIGHT 			= 0xFFFF40FF;
	final int NAME_AREA 			= 0xFFC8C8FF;
	final int CONNECTOR				= 0xFFFFC0FF;
	final int TEXTFILL				= 0xFF000080;
	final int PRESSED				= 0xFFFF3030;
	final int RELEASED				= 0xFF802020;
	final int SLIDER_CURSOR			= 0xFFFF4040;


	// Configuration status (KConfigDeviceUI)
	int WORKING						= 0;
	int CANCELLED					= 1;
	int FINISHED					= 2;
	
	
	int NOT_OVER					= 0x0000;
	// Add connector number
	int OVER_CONNECTOR				= 0x0100;

	int ON_PRESS 		= 0;
	int ON_RELEASE 		= 1;
	int WHILE_PRESS 	= 2;

	int BUTTON_TYPE		= 1;
	int HAT_TYPE		= 2;
	int SLIDER_TYPE		= 3;
	
	String SEPARATOR	= "\t";
//	String SEPARATOR = "\t";
}
