local miniGameName = "glutton";
local miniGamePath = "miniGames/glutton/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "It must be a vegetarian snake: eat space carrots without eating yourself!" ..
  "||Swipe up, down, left or right anywhere to change direction.";


-- The point that the touch event started at.
scene.touchStart = nil;

-- Constants for snake move directions.
scene.MOVING_UP = 1;
scene.MOVING_DOWN = 2;
scene.MOVING_RIGHT = 3;
scene.MOVING_LEFT = 4;

-- Amounts to adjust X and Y of snake parts.
-- Note: X grid coordinate goes from 1 to 17
-- Note: Y grid coordinate goes from 1 to 30
scene.xAdj = 44;
scene.yAdj = 200;

-- How many segments there currently are.
scene.segmentsCount = 0;

-- Current red color of the LASER fence and which way the pulse is going.
scene.laserFenceColor = .5;
scene.laserFenceColorDir = "inc";
scene.laserFenceColorFrameCount = 0;


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

  -- Construct LASER fence border.
  local laserFence = self.resMan:newRect("laserFence", self.resMan:getDisplayGroup("gameGroup"),
    display.contentCenterX, display.contentCenterY + 80, display.contentWidth - 100, display.contentHeight - 240
  );
  laserFence:setFillColor(0, 0, 0, 0);
  laserFence.strokeWidth = 20;
  laserFence:setStrokeColor(255, 0, 0);
  laserFence.alpha = .5;

  -- Build the snake.
  local head = self.resMan:newSprite("head", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("head"), count = 1, time = 9999 }
  });
  self:buildSnake();

  -- Create and place food.
  local food = self.resMan:newSprite("food", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("food"), count = 1, time = 9999 }
  });
  self:placeFood();

  -- Load sounds.
  self.resMan:loadSound("chomp", self.sharedResourcePath .. "chomp.wav");
  self.resMan:loadSound("move", self.sharedResourcePath .. "step.wav");
  self.resMan:loadSound("splat", self.sharedResourcePath .. "splat.wav");

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

  -- Pulse the LASER fence.
  self.laserFenceColorFrameCount = self.laserFenceColorFrameCount + 1;
  if self.laserFenceColorFrameCount >= 3 then
    self.laserFenceColorFrameCount = 0;
    if self.laserFenceColorDir == "inc" then
      self.laserFenceColor = self.laserFenceColor + .1;
      if self.laserFenceColor >= 1 then
        self.laserFenceColorDir = "dec";
      end
    else
      self.laserFenceColor = self.laserFenceColor - .1;
      if self.laserFenceColor <= .6 then
        self.laserFenceColorDir = "inc";
      end
    end
    self.resMan:getRect("laserFence").alpha = self.laserFenceColor;
  end

  -- Bump up frame count.
  local head = self.resMan:getSprite("head");
  local food = self.resMan:getSprite("food");
  head.movingFrames = head.movingFrames + 1;
  -- When we reach half-way through the current frame, it's time to move the snake.
  if head.movingFrames == 5 then

    -- Move the snake body.  Each segment is located where the previous one was, except for the first.
    for i = self.segmentsCount, 2, -1 do
      local segment1 = self.resMan:getSprite("segments" .. i);
      local segment2 = self.resMan:getSprite("segments" .. (i - 1));
      segment1.gridX = segment2.gridX;
      segment1.gridY = segment2.gridY;
      segment1.x = segment2.x;
      segment1.y = segment2.y;
    end
    -- The first segment goes where the head is.
    local firstSegment = self.resMan:getSprite("segments1");
    firstSegment.gridX = head.gridX;
    firstSegment.gridY = head.gridY;
    firstSegment.x = head.x;
    firstSegment.y = head.y;

    -- Now move the head.
    head.movingFrames = 0;
    if head.moving == self.MOVING_UP then
      head.gridY = head.gridY - 1;
    elseif head.moving == self.MOVING_DOWN then
      head.gridY = head.gridY + 1;
    elseif head.moving == self.MOVING_LEFT then
      head.gridX = head.gridX - 1;
    elseif head.moving == self.MOVING_RIGHT then
      head.gridX = head.gridX + 1;
    end
    head.x = (head.gridX * head.width) + self.xAdj;
    head.y = (head.gridY * head.height) + self.yAdj;
    audio.play(self.resMan:getSound("move"));

    -- If the head is out of bounds then restart.
    if head.gridX == 0 or head.gridX == 18 or head.gridY == 0 or head.gridY == 31 then
      audio.play(self.resMan:getSound("splat"));
      self.updateScore(self, -50);
      self:buildSnake();
      self:placeFood();
    end

    -- If the head is over any body segment then the snake eat itself and we need to restart.
    for i = 1, self.segmentsCount, 1 do
      local segment = self.resMan:getSprite("segments" .. i);
      if head.gridX == segment.gridX and head.gridY == segment.gridY then
        audio.play(self.resMan:getSprite("splat"));
        self.updateScore(self, -50);
        self:buildSnake();
        self:placeFood();
        break;
      end
    end

    -- If the head is on the food, eat it and add a segment
    if head.gridX == food.gridX and head.gridY == food.gridY then
      audio.play(self.resMan:getSound("chomp"));
      self.updateScore(self, 2 * self.segmentsCount);
      -- Now create a new segment, position it based on the current tail and segment before the tail, and add it.
      local tail = self.resMan:getSprite("segments" .. self.segmentsCount);
      local preTail = self.resMan:getSprite("segments" .. self.segmentsCount - 1);
      self.segmentsCount = self.segmentsCount + 1;
      local newTail = self.resMan:newSprite(
        "segments" .. self.segmentsCount, self.resMan:getDisplayGroup("gameGroup"),
        self.resMan:getImageSheet("imageSheet"), {
          { name = "default", start = self.resMan:getImageSheetInfo("imageSheet"):getFrameIndex("body"),
            count = 1, time = 9999
          }
        }
      );
      if tail.gridX == preTail.gridX and tail.gridY > preTail.gridY then
        newTail.gridX = tail.gridX;
        newTail.gridY = tail.gridY + 1;
      elseif tail.gridX == preTail.gridX and tail.gridY < preTail.gridY then
        newTail.gridX = tail.gridX;
        newTail.gridY = tail.gridY - 1;
      elseif tail.gridX < preTail.gridX and tail.gridY == preTail.gridY then
        newTail.gridX = tail.gridX - 1;
        newTail.gridY = tail.gridY;
      elseif tail.gridX > preTail.gridX and tail.gridY == preTail.gridY then
        newTail.gridX = tail.gridX + 1;
        newTail.gridY = tail.gridY;
      end
      newTail.x = (newTail.gridX * newTail.width) + self.xAdj;
      newTail.y = (newTail.gridY * newTail.height) + self.yAdj;
      -- Now place food again.
      self:placeFood();
    end

  end

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

  if inEvent.phase == "began" then

    self.touchStart = { x = inEvent.x, y = inEvent.y };

  elseif inEvent.phase == "ended" and self.touchStart ~= nil then

    -- Determine what direction swipe was in.
    local swipeDir = self:determineSwipeDirection(self.touchStart, { x = inEvent.x, y = inEvent.y });
    self.touchStart = nil;

    -- Now see if it's a valid move.
    local head = self.resMan:getSprite("head");
    if swipeDir == self.SWIPE_UP then
      head.moving = self.MOVING_UP;
      head.rotation = 0;
    elseif swipeDir == self.SWIPE_DOWN then
      head.moving = self.MOVING_DOWN;
      head.rotation = 0;
      head:rotate(180);
    elseif swipeDir == self.SWIPE_LEFT then
      head.moving = self.MOVING_LEFT;
      head.rotation = 0;
      head:rotate(-90);
    elseif swipeDir == self.SWIPE_RIGHT then
      head.moving = self.MOVING_RIGHT;
      head.rotation = 0;
      head:rotate(90);
    end

  end

end -- End touch().


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
-- Builds the snake.  This is done at the start or when the snake hits a boundary or eats itself.
--
function scene:buildSnake()

  -- Delete all existing segments.
  for i = 1, self.segmentsCount, 1 do
    self.resMan:removeSprite("segments" .. i);
  end

  -- Position the head and reset flags.
  local head = self.resMan:getSprite("head");
  head.rotation = 0;
  head.gridX = 9;
  head.gridY = 24;
  head.x = (head.gridX * head.width) + self.xAdj;
  head.y = (head.gridY * head.height) + self.yAdj;
  head.moving = self.MOVING_UP;
  head.movingFrames = 0;
  self.segmentsCount = 0;

  -- Create our initial segments.
  local imageSheet = self.resMan:getImageSheet("imageSheet");
  local sheetInfo = self.resMan:getImageSheetInfo("imageSheet");
  for i = 1, 4, 1 do
    self.segmentsCount = self.segmentsCount + 1;
    local segment = self.resMan:newSprite("segments" .. self.segmentsCount,
      self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
        { name = "default", start = sheetInfo:getFrameIndex("body"), count = 1, time = 9999 }
      }
    );
    segment.gridX = head.gridX;
    segment.gridY = head.gridY + i;
    segment.x = (segment.gridX * segment.width) + self.xAdj;
    segment.y = (segment.gridY * segment.height) + self.yAdj;
  end

end -- End buildSnake().


---
-- Randomly places the food at a new location, taking care not to place it on a segment of the snake.
--
function scene:placeFood()

  -- Re-choose if food is placed on head or a body segment.
  local chooseAgain = true;
  local food = self.resMan:getSprite("food");
  local head = self.resMan:getSprite("head");
  while chooseAgain do
    -- Assume we'll successfully place the food this iteration.
    chooseAgain = false;
    -- Choose a location.
    food.gridX = math.random(2, 17);
    food.gridY = math.random(2, 29);
    -- Test against head, choose again if we hit it.
    if food.gridX == head.gridX and food.gridY == head.gridY then
      chooseAgain = true;
    end
    -- Test against all body segments, choose again if we hit one.
    for i = 1, self.segmentsCount, 1 do
      local segment = self.resMan:getSprite("segments" .. i);
      if food.gridX == segment.gridX and food.gridY == segment.gridY then
        chooseAgain = true;
      end
    end
  end

  food.x = (food.gridX * food.width) + self.xAdj;
  food.y = (food.gridY * food.height) + self.yAdj;

end -- End placeFood().


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
