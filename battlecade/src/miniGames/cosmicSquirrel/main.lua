local miniGameName = "cosmicSquirrel";
local miniGamePath = "miniGames/cosmicSquirrel/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
"Squirrels - IN SPACE! Get the giant space squirrel through the obstacles to the giant space acorn." ..
    "||Swipe up, down, left or right anywhere to move.";


-- Physics.
local physics = require("physics");
physics.start();
physics.setGravity(0, 0);
local physicsData = (require ("miniGames." .. miniGameName .. ".physicsData")).physicsData(1.0);

-- The point that the touch event started at.
scene.touchStart = nil;


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

  -- Acorn.
  local acorn = self.resMan:newSprite("acorn", self.resMan:getDisplayGroup("gameGroup"), imageSheet ,
    { name = "default", start = sheetInfo:getFrameIndex("acorn"), count = 1, time = 500 }
  );
  physics.addBody(acorn, "dynamic", { isSensor = true });
  acorn.objType = "acorn";
  acorn.y = 260;

  -- Squirrel.
  local squirrel = self.resMan:newSprite("squirrel", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "walking", start = sheetInfo:getFrameIndex("squirrel_00"), count = 2, time = 250 }
  );
  physics.addBody(squirrel, "dynamic", { isSensor = true });
  squirrel.objType = "squirrel";
  squirrel:setSequence("walking");

  -- Aliens.
  local aliens = { };
  for i = 1, 4, 1 do
    aliens[i] = self.resMan:newSprite("aliens" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet ,
      { name = "default", start = sheetInfo:getFrameIndex("alien_00"), count = 3, time = 500 }
    );
    physics.addBody(aliens[i], "dynamic", { isSensor = true });
    aliens[i].objType = "alien";
    aliens[i]:setSequence("default");
    aliens[i]:play();
    local alienWidth = aliens[i].width;
    if i == 1 or i == 3 then
      aliens[i].x = math.random(200, display.contentWidth - 200);
    else
      aliens[i].x = aliens[i - 1].x + alienWidth + math.random(alienWidth, (display.contentWidth / 2));
    end
    if i < 3 then
      aliens[i].y = 460;
      aliens[i].moveDir = "R";
    else
      aliens[i].y = 1310;
      aliens[i].moveDir = "L";
      -- Bottom two aliens move left, opposite of the base image, so need to mirror.
      utils:mirrorDisplayObject(aliens[i]);
    end
  end

  -- Comets.
  local comets = { };
  for i = 1, 2, 1 do
    comets[i] = self.resMan:newSprite("comets" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet ,
      { name = "default", start = sheetInfo:getFrameIndex("comet_00"), count = 11, time = 500 }
    );
    physics.addBody(comets[i], "dynamic", physicsData:get("comet"));
    comets[i].objType = "comet";
    comets[i]:setSequence("default");
    comets[i]:play();
    local cometWidth = comets[i].width;
    if i == 1 then
      comets[i].x = math.random(200, display.contentWidth - 200);
    else
      comets[i].x = comets[i - 1].x + cometWidth + math.random(cometWidth, (display.contentWidth / 2));
    end
    comets[i].y = 700;
  end

  -- Ships.
  local ships = { };
  for i = 1, 4, 1 do
    ships[i] = self.resMan:newSprite("ships" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet ,
      { name = "default", start = sheetInfo:getFrameIndex("ship_00"), count = 2, time = 500 }
    );
    ships[i].objType = "ship";
    ships[i]:setSequence("default");
    ships[i]:play();
    local shipWidth = ships[i].width;
    if i == 1 or i == 3 then
      ships[i].x = math.random(200, display.contentWidth - 200);
    else
      ships[i].x = ships[i - 1].x + shipWidth + math.random(shipWidth, (display.contentWidth / 2));
    end
    if i < 3 then
      physics.addBody(ships[i], "dynamic", physicsData:get("ship"));
      ships[i].y = 960;
      -- Top two ships move right, opposite of the base image, so need to mirror.
      utils:mirrorDisplayObject(ships[i]);
    else
      physics.addBody(ships[i], "dynamic", physicsData:get("ship_mirror"));
      ships[i].y = 1650;
    end
  end

  -- Load sounds.

  self.resMan:loadSound("chomp", self.sharedResourcePath .. "chomp.wav");
  self.resMan:loadSound("splat", self.sharedResourcePath .. "splat.wav");
  self.resMan:loadSound("walking", self.sharedResourcePath .. "walking.wav");

  self:resetGame();

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

    physics.stop();
    transition.cancel();

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

  local squirrel = self.resMan:getSprite("squirrel");

  if squirrel.resolveCollision == true then
    squirrel.resolveCollision = false;
    self:resetGame();
  end

  -- Move aliens.
  for i = 1, 4, 1 do
    local alien = self.resMan:getSprite("aliens" .. i);
    if i == 1 or i == 2 then
      alien.x = alien.x + 4;
      if alien.x >= (display.contentWidth + 100) then
        alien.x = -100;
      end
    else
      alien.x = alien.x - 4;
      if alien.x <= -100 then
        alien.x = (display.contentWidth + 100);
      end
    end
  end

  -- Move comets.
  for i = 1, 2, 1 do
    local comet = self.resMan:getSprite("comets" .. i);
    if i == 1 or i == 2 then
      comet.x = comet.x - 6;
      if comet.x <= -200 then
        comet.x = (display.contentWidth + 200);
      end
    else
      comet.x = self.comets[i].x + 6;
      if comet.x >= (display.contentWidth + 200) then
        comet.x = -200;
      end
    end
  end

  -- Move ships.
  for i = 1, 4, 1 do
    local ship = self.resMan:getSprite("ships" .. i);
    if i == 1 or i == 2 then
      ship.x = ship.x + 9;
      if ship.x >= (display.contentWidth + 100) then
        ship.x = -100;
      end
    else
      ship.x = ship.x - 9;
      if ship.x <= -100 then
        ship.x = (display.contentWidth + 100);
      end
    end
  end

end -- End enterFrame().


---
-- Called when the menu is triggered (either from it being shown or hidden).
--
function scene:menuTriggered()
end -- End menuTriggered().


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

  local squirrel = self.resMan:getSprite("squirrel");

  if squirrel.moving == true or squirrel.resolveCollision == true then
    self.touchStart = nil;
    return;
  end

  if inEvent.phase == "began" then

    self.touchStart = { x = inEvent.x, y = inEvent.y };

  elseif inEvent.phase == "ended" and self.touchStart ~= nil then

    local xDelta_leftRight = 141;
    local xDelta_upDown = 54;
    local yDelta = 86;

    -- How many pixels to move the squirrel with each swipe.
    local moveAmountVert = 170;
    local moveAmountHoriz = 140;

    -- Determine what direction swipe was in.
    local swipeDir = self:determineSwipeDirection(self.touchStart, { x = inEvent.x, y = inEvent.y });
    self.touchStart = nil;

    if swipeDir == self.SWIPE_UP and squirrel.y > 400 then

      squirrel.moving = true;
      squirrel:play();
      audio.play(self.resMan:getSound("walking"));
      transition.to(squirrel, {
        time = 500, delta = true, y = -moveAmountVert,
        onComplete = function()
          squirrel.moving = false;
          squirrel:pause();
          squirrel.rotation = 0;
          self.touchStart = nil;
          audio.stop();
        end
      });
      return;

    elseif swipeDir == self.SWIPE_DOWN and squirrel.y < 1800 then

      squirrel.moving = true;
      squirrel.rotation = 180;
      squirrel:play();
      audio.play(self.resMan:getSound("walking"));
      transition.to(squirrel, {
        time = 500, delta = true, y = moveAmountVert,
        onComplete = function()
          squirrel.moving = false;
          squirrel:pause();
          squirrel.rotation = 0;
          self.touchStart = nil;
          audio.stop();
        end
      });
      return;

    elseif swipeDir == self.SWIPE_LEFT and squirrel.x > 200 then

      squirrel.moving = true;
      squirrel.rotation = 270;
      squirrel:play();
      audio.play(self.resMan:getSound("walking"));
      transition.to(squirrel, {
        time = 500, delta = true, x = -moveAmountHoriz,
        onComplete = function()
          squirrel.moving = false;
          squirrel:pause();
          squirrel.rotation = 0;
          self.touchStart = nil;
          audio.stop();
        end
      });
      return;

    elseif swipeDir == self.SWIPE_RIGHT and squirrel.x < 900 then

      squirrel.moving = true;
      squirrel.rotation = 90;
      squirrel:play();
      audio.play(self.resMan:getSound("walking"));
      transition.to(squirrel, {
        time = 500, delta = true, x = moveAmountHoriz,
        onComplete = function()
          squirrel.moving = false;
          squirrel.rotation = 0;
          squirrel:pause();
          self.touchStart = nil;
          audio.stop();
        end
      });
      return;

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

  if inEvent.phase == "began" then

    local obj1 = inEvent.object1.objType;
    local obj2 = inEvent.object2.objType;

    -- Get references to the squirrel and what it collided with.
    local squirrel = inEvent.object1;
    local collidedObject = inEvent.object2;
    if inEvent.object2.objType == "squirrel" then
      -- Swap the references.  Neat little multiple assignment trick!
      squirrel, collidedObject = collidedObject, squirrel;
    end

    -- If it was the acorn, score it and reset.
    if collidedObject.objType == "acorn" then
      transition.cancel();
      audio.stop();
      squirrel.moving = false;
      squirrel:pause();
      self.touchStart = nil;
      audio.play(self.resMan:getSound("chomp"));
      self.updateScore(self, 10);
      squirrel.resolveCollision = true;
    else
      transition.cancel();
      audio.stop();
      squirrel.moving = false;
      squirrel:pause();
      self.touchStart = nil;
      audio.play(self.resMan:getSound("splat"));
      self.updateScore(self, -5);
      squirrel.resolveCollision = true;
    end

  end

end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================

---
-- Reset the game when the acorn is gotten or the squirrel is squished.
--
function scene:resetGame()

  -- Random position for acorn.
  self.resMan:getSprite("acorn").x = math.random(300, display.contentWidth - 300);

  -- Initial position for squirrel.
  local squirrel = self.resMan:getSprite("squirrel");
  squirrel.rotation = 0;
  squirrel.x = display.contentCenterX;
  squirrel.y = display.contentHeight - squirrel.height;

end -- End resetGame().


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
