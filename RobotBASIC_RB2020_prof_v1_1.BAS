 // ================================================================================
// RoboBASIC_RB2020 1.1
// Simulation of the RB using the RobotBASIC simulator.
//
// Author: Carlos Carreto
// Last revision: 18/06/2020
// ================================================================================

// ================================================================================
// Constants
// ================================================================================
// Identifiers of the states.
WAIT = 0
NAVIGATE = 1
APPROACH = 2
PUT_OUT = 3

// Identifiers of the floor tags.
LINE_TAG = 0
CIRCLE_TAG = 1
NO_TAG = 2

// Distances for the NAVIGATE state.
DIST1 = 40
DIST2 = 50


// ================================================================================
// Variables
// ================================================================================
Ox = 250 //X of the left the top left corner of the arena.
Oy = 50  //Y of the left the top left corner of the arena.
 
//Colors of the different elements of the arena
wallColor = Green
lineColor = White
startColor = White
floorColor = Black
 candleColor = Red
penColor = Blue
 
state = WAIT  // Actual state of the finite state machine.
 
tag = NO_TAG  // Identifier of the floor thag updated by the sub GetFloorTag

rooms = 0;    // Identifier/counter for the rroms/lines

// Variables used by the GetFlameDirection subroutine               
flameDirection = 0
flameColor = Black
flameDistance = 0
flameFound = false

inRoom = false // Flag indicating if flame is in room
 
 
// ================================================================================
// Main Program
// ================================================================================
MainProgram:
   gosub DisplayInstructions
   gosub InitializeGUI
   gosub DrawArena
   gosub InitializeRobot
   gosub FiniteStateMachine
end


// ================================================================================
// Initialization Subroutines
// ================================================================================
InitializeRobot:
  rLocate Ox + 200, Oy + 45, 180 //Initial robot position
  rInvisible floorColor, lineColor, startColor, penColor  //List of invisible colors (elements with these colors are not obstacles).
  rPen Down, penColor   // The robot will draw a line using the color specified.
  LineWidth 3           // Width of the line.
  rSlip 20              // Percentage for the Slipping feature of the robot.
return


InitializeGUI:
  // Start and Stop buttons of the robot.   
  AddButton "START", Ox, Oy - 30 - 10, 80, 30
  AddButton "STOP", Ox + 80 + 10, Oy - 30 - 10, 80, 30
   
  call Header("Configuration", 10, 10, 12)
   
  // Reset button to start all over.
  AddButton "RESET", 10, Oy, 80, 30
   
  // Edits to choose the flame position and arena configuration.
  // If user enters 0, the position and configuration are chosen randomly.
  XYString 10, Oy + 30 + 10, "Flame position: "
  AddEdit "EFlamePos", 195, Oy + 30 + 10, 23, 23, 0
  SetEditMask "EFlamePos", "0"
   
  XYString 10, Oy + 60 + 10, "Arena configuration: "
  AddEdit "EArenaConfig", 195, Oy + 60 + 10, 23, 23, 0
  SetEditMask "EArenaConfig", "0"
   
  // Checkboxes to slect operation modes and other configurations.
  AddCheckBox "CBPen", 10, Oy + 90 + 10, "Pen", true, false
  AddCheckBox "CBAStart", 10, Oy + 110 + 10, "Arbitrary Start", false, false
  AddCheckBox "CBFurniture", 10, Oy + 130 + 10, "Furniture", false, false
  AddCheckBox "CBRTrip", 10, Oy + 150 + 10, "Return Trip", false, false

  // Event handler to detect the changes in the states of the checkboxes.
  // The event handler works in parallel with the execution of the simulation. 
  // This is usefull to turn on/off some feature during simulation the pen of the robot 
  // for example).
  // Notice that instead of checking the state of a checkbox using the event handler,
  // we can also check it locally, adding the correspondent code where needed. See the 
  // example at the end of the DrawArena subroutine.
  onCheckBox CBHandler
  
  call Header("Screen", 10, 300, 12)
return
 
DisplayInstructions:
  data IM;"RoboBASIC_RB2020"
  data IM;"Rob? Bombeiro Simulation"
  n = MsgBox(IM)
return
 

// ================================================================================
// Arena Subroutines
// ================================================================================
DrawArena:
  //ClearScr White

  // Draw LED
  gosub LedOff
 
  // Draw the floor.
  Rectangle Ox, Oy, Ox + 496, Oy + 496, floorColor, floorColor

  // Draw exterior walls.
  Line Ox, Oy, Ox, Oy + 496, 3, wallColor //Left
  Line Ox, Oy, Ox + 496, Oy, 3, wallColor //Top
  Line Ox + 496, Oy, Ox + 496, Oy + 496, 3, wallColor //Right
  Line Ox, Oy + 496, Ox + 496, Oy + 496, 3, wallColor //Botom
 
  // Draw room 1.
  Line Ox + 154, Oy, Ox + 154, Oy + 182, 3, wallColor 
  Line Ox + 96, Oy + 182, Ox + 154, Oy + 182, 3, wallColor 
  Line Ox + 3, Oy + 182, Ox + 93, Oy + 182, 3, lineColor //*** line ***
 
  // draw room 2.
  Line Ox, Oy + 274, Ox + 154, Oy + 274, 3, wallColor 
  Line Ox + 154, Oy + 274, Ox + 154, Oy + 396, 3, wallColor 
  Line Ox + 154, Oy + 399, Ox + 154, Oy + 493, 3, lineColor //*** line ***
  
  /*
  // Draw room 3.
  Line Ox + 246, Oy + 314, Ox + 496, Oy + 314, 3, wallColor 
  Line Ox + 246, Oy + 406, Ox + 246, Oy + 496, 3, wallColor 
  Line Ox + 246, Oy + 317, Ox + 246, Oy + 403, 3, lineColor //*** line ***
  Line Ox + 407, Oy + 314, Ox + 493, Oy + 314, 3, lineColor //*** line ***
   
  // Draw room 4.
  Line Ox + 246, Oy + 92, Ox + 246, Oy + 214, 3, wallColor 
  Line Ox + 246, Oy + 92, Ox + 398, Oy + 92, 3, wallColor 
  Line Ox + 398, Oy + 92, Ox + 398, Oy + 214, 3, wallColor 
  Line Ox + 398, Oy + 214, Ox + 342, Oy + 214, 3, wallColor 
  Line Ox + 249, Oy + 214, Ox + 339, Oy + 214, 3, lineColor //*** line ***
  */

  // Use room configuration given by the user or choose a random configuration.
  arenaConfig = ToNumber(GetEdit("EArenaConfig"))
  if(arenaConfig < 1 or arenaConfig > 4)
    arenaConfig = Random(3) + 1
    SetEdit "EArenaConfig", arenaConfig
  endif  

  // Draw room 3.
  if (arenaConfig = 1) or (arenaConfig = 2)
     Line Ox + 246, Oy + 314, Ox + 496, Oy + 314, 3, wallColor 
     Line Ox + 246, Oy + 406, Ox + 246, Oy + 496, 3, wallColor 
     Line Ox + 246, Oy + 317, Ox + 246, Oy + 403, 3, lineColor //*** line ***
     Line Ox + 407, Oy + 314, Ox + 493, Oy + 314, 3, lineColor //*** line ***
   elseif (arenaConfig = 3)  or (arenaConfig = 4)
     Line Ox + 246, Oy + 314, Ox + 496, Oy + 314, 3, wallColor 
     Line Ox + 246, Oy + 314, Ox + 246, Oy + 396, 3, wallColor 
     Line Ox + 246, Oy + 399, Ox + 246, Oy + 493, 3, lineColor //*** line ***
     Line Ox + 407, Oy + 314, Ox + 493, Oy + 314, 3, lineColor //*** line ***
  endif
  
  // Draw room 4.
  if (arenaConfig = 1) or (arenaConfig = 4)  
      Line Ox + 246, Oy + 92, Ox + 246, Oy + 214, 3, wallColor 
      Line Ox + 246, Oy + 92, Ox + 398, Oy + 92, 3, wallColor 
      Line Ox + 398, Oy + 92, Ox + 398, Oy + 214, 3, wallColor 
      Line Ox + 398, Oy + 214, Ox + 342, Oy + 214, 3, wallColor 
      Line Ox + 249, Oy + 214, Ox + 339, Oy + 214, 3, lineColor //*** line ***
  elseif (arenaConfig = 2) or (arenaConfig = 3)
      Line Ox + 246, Oy + 92, Ox + 246, Oy + 214, 3, wallColor 
      Line Ox + 298, Oy + 92, Ox + 398, Oy + 92, 3,  lineColor 
      Line Ox + 398, Oy + 92, Ox + 398, Oy + 214, 3, wallColor 
      Line Ox + 246, Oy + 92, Ox + 298, Oy + 92, 3, wallColor 
      Line Ox + 249, Oy + 214, Ox + 398, Oy + 214, 3, wallColor 
  endif 

  // Draw white circle (start position)
  Circle Ox + 170, Oy + 16, Ox + 170 + 60, Oy + 16 + 60, startColor, startColor
 
  // Use position given by the user or choose random position for the candle.
  candleBasePos = ToNumber(GetEdit("EFlamePos"))
  if(candleBasePos < 1 or candleBasePos > 8)
    candleBasePos = Random(7) + 1
    SetEdit "EFlamePos", candleBasePos
  endif  
 
   if (candleBasePos = 1)
    candleBaseOX = Ox + 3
    candleBaseOY = Oy + 3
    //candleBaseDI = 270
    //candleBaseDF = 90
    candleX = 1 
    candleY = 1
  elseif (candleBasePos = 2)
    candleBaseOX = Ox + 154 - 2
    candleBaseOY = Oy + 3
    //candleBaseDI = 180
    //candleBaseDF = 90
    candleX = -1 
    candleY = 1
  elseif (candleBasePos = 3)
    candleBaseOX = Ox + 246 + 3
    candleBaseOY = Oy + 92 + 3
    //candleBaseDI = 270
    //candleBaseDF = 90
    candleX = 1 
    candleY = 1
    // Reposition the candle because of the orientation of the island room.
    if(arenaConfig == 2 or arenaConfig == 3) 
      candleBaseOY = candleBaseOY + 55      
    endif  
  elseif (candleBasePos = 4)
    candleBaseOX = Ox + 398 - 1
    candleBaseOY = Oy + 92 + 3
    //candleBaseDI = 180
    //candleBaseDF = 90
    candleX = -1 
    candleY = 1
    // Reposition the candle because of the orientation of the island room.
    if(arenaConfig == 2 or arenaConfig == 3)
      candleBaseOY = candleBaseOY + 55
    endif  
  elseif (candleBasePos = 5)
    candleBaseOX = Ox + 496 - 1
    candleBaseOY = Oy + 496 - 1
    //candleBaseDI = 90
    //candleBaseDF = 90
    candleX = -1 
    candleY = -1
  elseif (candleBasePos = 6)
    candleBaseOX = Ox + 3 
    candleBaseOY = Oy + 496 - 1
    //candleBaseDI = 0
    //candleBaseDF = 90
    candleX = 1 
    candleY = -1
  elseif (candleBasePos = 7)
    candleBaseOX = Ox + 3
    candleBaseOY = Oy + 274 + 3
    //candleBaseDI = 270
    //candleBaseDF = 90
    candleX = 1 
    candleY = 1
  elseif (candleBasePos = 8)
    candleBaseOX = Ox + 154 - 1
    candleBaseOY = Oy + 274 + 3
    //candleBaseDI = 180
    //candleBaseDF = 90
    candleX = -1 
    candleY = 1
  endif
     
  candleR = 5            // Radius of the candle base (corresponds to the candle itself).
  candleX = candleX * 30 // X position of the candle inside the semicircle.
  candleY = candleY * 30 // Y position of the candle inside the semicircle.
  
  // Draw the candle. 
  Circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, candleColor, candleColor 
   
  if(GetCheckBox("CBFurniture"))
    //candleY = 1
    if ((candleBasePos == 3 or  candleBasePos == 4) and (arenaConfig == 2 or arenaConfig == 3))
      candleY = -1
    endif  
    
    candleR = 15            // Radius of the candle base (corresponds to the candle itself).
    candleX = candleX * 2.1 // X position of the candle inside the semicircle.
    candleY = candleY * 2.1 // Y position of the candle inside the semicircle.    
    Circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, Yellow, Yellow     
  endif  
return


// ================================================================================
// Finite Satate Machine
// ================================================================================
FiniteStateMachine:
  while true
    if(state == WAIT)
      gosub WaitState
    elseif(state == NAVIGATE)
      gosub NavigateState  
    elseif(state == APPROACH)
      gosub ApproachState    
    elseif(state == PUT_OUT)
      gosub PutOutState2 
    endif     
    
    gosub Screen  // Update screen.    
    
    GetButton btn
    if(btn == "STOP") then state = WAIT
  wend
return


WaitState:
  EnableButton "START", true
  EnableButton "RESET", true
  EnableButton "STOP", false
  
  repeat 
    GetButton btn 
    if(btn == "RESET") 
      gosub DrawArena
      gosub InitializeRobot
      EnableCheckBox "CBPen", true
      EnableCheckBox "CBAStart", true
      EnableCheckBox "CBFurniture", true
      EnableCheckBox "CBRTrip", false  
    endif  
  until btn == "START"

  EnableButton "START", false
  EnableButton "RESET", false
  EnableButton "STOP", true      
  EnableCheckBox "CBPen", false
  EnableCheckBox "CBAStart", false
  EnableCheckBox "CBFurniture", false  
  EnableCheckBox "CBRTrip", false  

  // Robot initialization
  gosub LedOff
  rooms = 0
  inRoom = false
  
  // Start navigation
  gosub ManeuverToExitWhiteCircle
  state = NAVIGATE
return

 
NavigateState:
  if(rRange(0) < 30) then rTurn -90  // Front wall detected.
  
  gosub CheckBumpers
  
  dist = rRange(90)
  if(dist >= DIST1 and dist <= DIST2)  // Ideal distance to the wall.
    rForward 1
  elseif(dist < DIST1)  // Too close to the wall.
    rTurn -1
    rForward 1
  elseif(dist > DIST2)  // Too far from the wall.
    rTurn 1
    rForward 1
  endif  

  gosub GetFloorTag
  if(tag == LINE_TAG)     // It is at the entrance of the room.
    rooms = rooms + 1
    // Check if flame is in room. If true enter the room, if false go to next room.
    call MoveForward(50)
    gosub ScanRoom
    if(inRoom == false)
      gosub ManeuverToGoToNextRoom
    endif
  
  elseif(tag == CIRCLE_TAG)  // It is at the start position.
    // Maneuver to go to island room
    call ManeuverToGoToIslandRoom()
  endif    

  if(inRoom == true)
    gosub GetFlameDirection2
    if(flameDirection != 0)
      state = APPROACH
      return
    endif  
  endif  

return


ApproachState:
  gosub LedOn   //Turn on LED indicating that the flame is being detected.
  
  gosub GetFlameDirection2
  if(flameDirection == 0)
    state = NAVIGATE
    return
  elseif(flameDirection == 1)  // Flame is on the right.
    rTurn 2
  elseif(flameDirection == 2)  // Flame is on the right
    rTurn 1
  elseif(flameDirection == 3)  // Flame is ahead. 
    call CheckBumpers2()
    if(CheckBumpers2__Result == false)
      rForward 1
    endif 
    //if(flameDistance < 10)
    if(rRange(0) < 10)
      state = PUT_OUT
      return
    endif  
  elseif(flameDirection == 4)  // Flame is on the left.
    rTurn -1     
  elseif(flameDirection == 5)  // Flame is on the left.
    rTurn -2  
  endif
return

  
PutOutState 1:
  // Basic version. 
  // If robot reaches this state, it always puts out the candle.
  Circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, Gray, Gray
  
  gosub LedOff
  state = WAIT
return

PutOutState2:
  // More realistic version. 
  // If robot reaches this state, it has a 75% chance to put out the candle.
  x = Random(99) + 1
  if(x < 75) then Circle candleBaseOX + candleX - candleR, candleBaseOY + candleY - candleR, candleBaseOX + candleX + candleR, candleBaseOY + candleY + candleR, Gray, Gray
  
  // Check if flame is still present. I so, go to state APPROACH.
  rForward -20
  gosub GetFlameDirection2
  if (flameDirection != 0)
    state = APPROACH
    return
  endif  
  
  gosub LedOff

  state = WAIT
return


// ================================================================================
// Maneuver Subroutines
// ================================================================================
ManeuverToExitWhiteCircle:
  repeat
    rForward 1
    gosub GetFloorTag
  until tag == NO_TAG  
return

Sub MoveForward(dist):
  for d = 1 to dist
    rForward 1
    delay 10
  next
return

ManeuverToGoToNextRoom:
  if(rooms == 1)
    rTurn 180
    call MoveForward(50)
  elseif(rooms == 2)
    rTurn 180
    call MoveForward(50)
  elseif(rooms == 3)
  elseif(rooms == 4)
  endif
return


Sub ManeuverToGoToIslandRoom():
  rTurn 180
  call MoveForward(50)
return
// ================================================================================
// Sensor Subroutines
// ================================================================================
CheckBumpers:
  bmp = rDBumper(Red)
  
  if(bmp & 4)     // Collision ahead.
    rForward -10
    rTurn -45
  elseif(bmp & 8) // Left collision.  
    rForward -10
    rTurn 45
  elseif(bmp & 2) // Right collision.
    rForward -10
    rTurn -45
  endif    
return
 
Sub CheckBumpers2():
  bmp = rDBumper(Red)
  result = false
  if(bmp & 4)     // Collision ahead.
    rForward -10
    rTurn -45
    result = true
  elseif(bmp & 8) // Left collision.  
    rForward -10
    rTurn 45
    result = true
  elseif(bmp & 2) // Right collision.
    rForward -10
    rTurn -45
    result = true
  endif    
return result
 
 
GetFloorTag:
  if(rSense(White) & 2)  
    rForward 5 
    if(rSense(White) & 2)  
      tag = CIRCLE_TAG
    else
      tag = LINE_TAG
    endif 
  else
    tag = NO_TAG
  endif  
return
 
 
GetFlameDirection:
  // This version uses the rSensor that simulates 5 sensores positioned at
  // 90?, 45?, 0?, -45? and -90?. 
  // The sunroutin updates the following variables: 
  // flameDirection - a value between 1 and 5 corresponding to the directions of the sensors.
  // flameColor - the detected color
  // flameDistance - the distance to the color
  // flameFound - a boolean indicating that a color was detected within the sensor range.
  // If flame is not detected, flameDirection will be zero.
  flameDirection = 0   
  for i = 1 to 5
    rSensor i, 150, flameColor, flameDistance, flameFound
    if(flameColor == Red)
      flameDirection = i
      break
    endif  
  next
return


GetFlameDirection2:
  // This version uses the sensor rLook to simulate a linear camera with 25 pixels.
  // Angle of view between 12? and -12?.
  // This implementation is compatible with the GetFlameDirection version and also
  // updates the flameDirection variable with the direction of the flame between 1 and 5.
  // If flame is not detected, flameDirection will be zero.
  flameDirection = 0   
  for i = -12 to 12
    if(rLook(i) == Red)
      if(i < -8)
        flameDirection = 5
      elseif(i < -2)
        flameDirection = 4
      elseif(i < 2)
        flameDirection = 3  
      elseif(i < 8)
        flameDirection = 2
      else
        flameDirection = 1
     endif   
    endif
  next
return

GetFlameDirection3:
  // This version uses the sensor rLook to simulate a linear camera with 25 pixels.
  // Angle of view between 12? and -12?.
  // This implementation simply aupdates the flameDirection variable with the angle where 
  // the flame was detected (between 12? and -12?).
  // This returned angle can be used to derectly control de robot to turn itself to face the 
  // flame. If flame is not detected, flameDirection will be 99.
  // This implemenation is not compatible with the actual APPROACH state. A new AproachState
  // must be implemented to work with this implementation. 
  flameDirection = 99   
  for i = -12 to 12
    if(rLook(i) == Red)
      flameDirection = i
      return
    endif
  next
return

ScanRoom:
  for ang = 1 to 45
    gosub GetFlameDirection2
    if(flameDirection != 0)
      inRoom = true
      return
    endif
    rTurn 2
    delay 10
  next
  
  for ang = 1 to 45
    rTurn -2
    delay 10
  next
  
  for ang = 1 to 45
    gosub GetFlameDirection2
    if(flameDirection != 0)
      inRoom = true
      return
    endif
    rTurn -2
    delay 10
  next
  
  for ang = 1 to 45
    rTurn 2
    delay 10
  next

return


// ================================================================================
// Interface Subroutines
// ================================================================================
Screen:
  // Write the name of the current state.
  if(state == 0)
    stateName = "WAIT    "
  elseif(state == 1)  
    stateName = "NAVIGATE"    
  elseif(state == 2)  
    stateName = "APPROACH"    
  elseif(state == 3)  
    stateName = "PUT_OUT "    
  endif
  XYString 10, 340, "State: " + stateName

  // Write the number of rooms/lines counted. 
  XYString 10, 360, "Lines: " + rooms
  
  // Write the actual flame direction. 
  XYString 10, 380, "Flame: " + flameDirection
return

 
LedOn:
  CircleWH Ox + 200, Oy - 43, 35, 35, Black, Red
return  


LedOff:
  CircleWH Ox + 200, Oy - 43, 35, 35, Black, Gray
return  

Sub Header(str, x, y, s):
  XYText x, y, str, "Verdana", s, fs_Bold, Red, White
return 

CBHandler:
  cb = LastCheckBox()
  if(cb == "CBPen")
    if(GetCheckBox("CBPen"))
      rPen Down, penColor
    else
      rPen Up
    endif    
  elseif(cb == "CBAStart")
  
  elseif(cb == "CBFurniture") 
  
  elseif(cb == "CBRTrip")
  
  endif 
  oncheckbox CBHandler
return

