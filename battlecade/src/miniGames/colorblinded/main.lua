local miniGameName = "colorblinded";
local miniGamePath = "miniGames/colorblinded/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Radiation meets turtles! How else do you explain the color?!" ..
  "||Tap the turtles of the specified color as fast as possible and don't tap turtles of the wrong color.";


-- How many turtles have been tapped correctly for the current color.
scene.rightCount = nil;

-- How many turtles have been tapped incorrectly for the current color.
scene.wrongCount = nil;

-- The time the current color began.
scene.startTime = nil;


--- ====================================================================================================================
--  ====================================================================================================================
--  Scene lifecycle Event Handlers
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  self.parent.create(self, inEvent);
  --utils:log(self.miniGameName, "create()");

  -- Load graphics.

  local imageSheet, sheetInfo = self.resMan:newImageSheet(
    "imageSheet", "miniGames." .. miniGameName .. ".imageSheet", miniGamePath .. "imageSheet.png"
  );

  -- The current color text.
  self.resMan:newText(
    "currentColor", self.resMan:getDisplayGroup("gameGroup"), "",
    display.contentCenterX, 250, globalNativeFont, 180
  );

  -- Turtles.
  local xStart = 150;
  local x = xStart;
  local y = 620;
  for i = 1, 16, 1 do
    local s = self.resMan:newSprite("turtles" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
      { name = "blue", start = sheetInfo:getFrameIndex("blue"), count = 1, time = 9999 },
      { name = "green", start = sheetInfo:getFrameIndex("green"), count = 1, time = 9999 },
      { name = "purple", start = sheetInfo:getFrameIndex("purple"), count = 1, time = 9999 },
      { name = "red", start = sheetInfo:getFrameIndex("red"), count = 1, time = 9999 },
      { name = "yellow", start = sheetInfo:getFrameIndex("yellow"), count = 1, time = 9999 },
      { name = "happy", start = sheetInfo:getFrameIndex("happy"), count = 1, time = 9999 },
      { name = "sad", start = sheetInfo:getFrameIndex("sad"), count = 1, time = 9999 }
    });
    s.x = x;
    s.y = y;
    x = x + (s.width) + 80;
    if i == 4 or i == 8 or i == 12 then
      x = xStart;
      y = y + (s.height + 200);
    end
    s:setSequence("yellow");
    s:play();
  end

  -- Load sounds.
  self.resMan:loadSound("right", self.sharedResourcePath .. "ting.wav");
  self.resMan:loadSound("wrong", self.sharedResourcePath .. "grunt.wav");

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  self.parent.show(self, inEvent);

  if inEvent.phase == "did" then

    --utils:log(self.miniGameName, "show(): did");
    for i = 1, 16, 1 do
      self.resMan:getSprite("turtles" .. i):addEventListener("touch",
        function(inEvent) self:turtleTouchHandler(inEvent);
        end
      );
    end

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  self.parent.hide(self, inEvent);

  if inEvent.phase == "did" then

    --utils:log(self.miniGameName, "hide(): did");

  end

end -- End hide().


---
-- Handler for the destroy event.
--
-- @param inEvent The event object.
--
function scene:destroy(inEvent)

  self.parent.destroy(self, inEvent);

  --utils:log(self.miniGameName, "destroy()");

end -- End destroy().


---
-- Called when the menu is triggered (either from it being shown or hidden).
--
function scene:menuTriggered()
end -- End menuTriggered().


---
-- Called when the starting countdown begins.
--
function scene:countdownStartEvent()
end -- End countdownStartEvent().


---
-- Called right after "GO!" is displayed to start a game.
--
function scene:startEvent()

  self:newColor();

end -- End startEvent().


---
-- Called right before "GAME OVER" is shown to end a game.
--
function scene:endEvent()
end -- End endEvent().


--- ====================================================================================================================
--  ====================================================================================================================
--  EnterFrame
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the enterFrame event.
--
-- @param inEvent The event object.
--
function scene:enterFrame(inEvent)

  self.parent.enterFrame(self, inEvent);

end -- End enterFrame().


--- ====================================================================================================================
--  ====================================================================================================================
--  Touch Handler(s)
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Function that handles touch events on the screen generally.
--
-- @param inEvent The event object.
--
function scene:touch(inEvent)
end -- End touch().


---
-- Handles touches on a peg.
--
-- @param inEvent The event object.
--
function scene:turtleTouchHandler(inEvent)

  if inEvent.phase == "ended" then

    -- Get a reference to the selected turtle.
    local turtle = inEvent.target;

    if
      (self.rightColor == 1 and turtle.sequence == "blue") or
      (self.rightColor == 2 and turtle.sequence == "green") or
      (self.rightColor == 3 and turtle.sequence == "purple") or
      (self.rightColor == 4 and turtle.sequence == "red") then
      audio.play(self.resMan:getSound("right"));
      turtle:setSequence("happy");
      self.rightCount = self.rightCount + 1;
      -- When they finally get all the right ones tapped, if they do, then it's time to score them and select a new
      -- color.
      if self.rightCount == 4 then
        local elapsedTime = os.difftime(os.time(), self.startTime);
        -- Now calculate the score.  The time taken is the basic measure, but we also subtract for each incorrect hit.
        if elapsedTime < 1 then
          self.updateScore(self, 20);
        elseif elapsedTime >= 1 and elapsedTime < 2 then
          self.updateScore(self, 15);
        elseif elapsedTime >= 2 and elapsedTime < 3 then
          self.updateScore(self, 10);
        elseif elapsedTime >= 3 and elapsedTime < 4 then
          self.updateScore(self, 5);
        end
        self.updateScore(self, -(self.wrongCount * 5));
        self:newColor();
      end
    else
      audio.play(self.resMan:getSound("wrong"));
      self.wrongCount = self.wrongCount + 1;
      turtle:setSequence("sad");
    end

  end -- End ended event.

end -- End turtleTouchHandler().


--- ====================================================================================================================
--  ====================================================================================================================
--  Collision Handler
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Function that handles collision events.
--
-- @param inEvent The event object.
--
function scene:collision(inEvent)
end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Function that selects a new color and changes all the turtles.
--
function scene:newColor()

  -- First, choose a color that will be the right one for the player to tap.
  local rightColor = math.random(1, 4);
  self.rightColor = rightColor;

  -- Now choose a wrong color.
  local wrongColor;
  local chooseAgain = true;
  while chooseAgain do
    wrongColor = math.random(1, 4);
    if wrongColor ~= rightColor then
      chooseAgain = false;
    end
  end

  -- Now, change the text to be the correct color.
  local currentColor = self.resMan:getText("currentColor");
  if rightColor == 1 then
    currentColor.text = "Blue";
  elseif rightColor == 2 then
    currentColor.text = "Green";
  elseif rightColor == 3 then
    currentColor.text = "Purple";
  elseif rightColor == 4 then
    currentColor.text = "Red";
  end

  -- Now, change the actual color of the text to the wrong color.
  if wrongColor == 1 then
    currentColor:setFillColor(0, 0, 255);
  elseif wrongColor == 2 then
    currentColor:setFillColor(0, 255, 0);
  elseif wrongColor == 3 then
    currentColor:setFillColor(255, 0, 255);
  elseif wrongColor == 4 then
    currentColor:setFillColor(255, 0, 0);
  end

  -- Now randomly change each turtle to a color, ensuring that we wind up with four of each of the four colors.
  local blueCount = 0;
  local greenCount = 0;
  local purpleCount = 0;
  local redCount = 0;
  for i = 1, 16, 1 do
    local chooseAgain = true;
    local turtleColor;
    while chooseAgain do
      turtleColor = math.random(1, 4);
      local turtle = self.resMan:getSprite("turtles" .. i);
      if turtleColor == 1 and blueCount < 4 then
        turtle:setSequence("blue");
        blueCount = blueCount + 1;
        chooseAgain = false;
      elseif turtleColor == 2 and greenCount < 4 then
        turtle:setSequence("green");
        greenCount = greenCount + 1;
        chooseAgain = false;
      elseif turtleColor == 3 and purpleCount < 4 then
        turtle:setSequence("purple");
        purpleCount = purpleCount + 1;
        chooseAgain = false;
      elseif turtleColor == 4 and redCount < 4 then
        turtle:setSequence("red");
        redCount = redCount + 1;
        chooseAgain = false;
      end
    end
  end

  -- Finally, reset variables as needed.  Note that we need to do this last so that the above code doesn't cost
  -- the player any time.
  self.rightCount = 0;
  self.wrongCount = 0;
  self.startTime = os.time();

end -- End newColor().


--- ====================================================================================================================
--  ====================================================================================================================
--  ====================================================================================================================
--  ====================================================================================================================


--utils:log(miniGameName, "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
