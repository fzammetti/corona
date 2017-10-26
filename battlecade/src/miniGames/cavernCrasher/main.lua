local miniGameName = "cavernCrasher";
local miniGamePath = "miniGames/cavernCrasher/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Fly your ship through the ice caverns, avoiding everything so you don't go boom." ..
  "||Tap and hold to activate anti-gravity, release to let gravity do it's thing.";


local physics = require("physics");
physics:start();
physics.setGravity(0, 0);
local physicsData = (require ("miniGames." .. miniGameName .. ".physicsData")).physicsData(1.0);

-- The maximum height of any cavern tile.
scene.maxTileHeight = 700;

-- Flag: is the pler holding their finger on the screen?
scene.fingerDown = false;

-- The current amount the ship's Y coordinate is being changed.
scene.currentShipYChange = 0;

-- Flag: did the ship collide with a cavern wall?
scene.shipCollision = false;

-- The channel the ambient sound is playing on.
scene.ambientChannel = nil;

-- Counter of how many frames have elapsed since the score was inceased.
scene.scoreFrameCount = 0;

-- How many frames to go until the next boulder appearance.
scene.framesUntilNextBoulderAppearance = 30 * 10;

-- Explosion particle emitter data.
scene.explosionEmitterParams = nil;


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

  -- Top.
  for i = 1, 14, 1 do
    local xLoc = (108 * i) - 162;
    local yLoc = math.random(0, 450);
    local t = self.resMan:newSprite("top" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet,
      { name = "default", start = sheetInfo:getFrameIndex("stalagmite"), count = 1, time = 500 }
    );
    t.x = xLoc;
    t.y = yLoc;
    physics.addBody(t, "static", physicsData:get("stalagmite_top"));
  end

  -- Bottom.
  for i = 1, 14, 1 do
    local xLoc = (108 * i) - 162;
    local yLoc = math.random(0, 350);
    local b = self.resMan:newSprite("bottom" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet,
      { name = "default", start = sheetInfo:getFrameIndex("stalagmite"), count = 1, time = 500 }
    );
    utils:flipDisplayObject(b);
    b.x = xLoc;
    b.y = display.contentHeight - yLoc;
    physics.addBody(b, "static", physicsData:get("stalagmite_bottom"));
  end

  -- Ship.
  local ship = self.resMan:newSprite("ship", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("ship_00"), count = 2, time = 500 }
  );
  ship.x = 100;
  ship.y = display.contentCenterY + 50;
  physics.addBody(ship, "dynamic", physicsData:get("ship_01"));
  ship:setSequence("default");
  ship:play();

  -- Boulder.
  local boulder = self.resMan:newSprite("boulder", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("boulder"), count = 1, time = 500 }
  );
  boulder.isVisible = false;
  boulder.x = display.contentWidth + boulder.width;
  boulder.y = display.contentCenterY + 50;
  physics.addBody(boulder, "static", physicsData:get("boulder"));
  boulder:setSequence("default");
  boulder:play();

  -- Load sounds.
  self.resMan:loadSound("ambient", self.sharedResourcePath .. "ambient.wav");
  self.resMan:loadSound("explosion", self.sharedResourcePath .. "explosion.wav");

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

  if self.gameState == self.STATE_PAUSED then
    -- Menu is being shown.
    audio.stop();
  else
    -- Menu is being hidden.
    audio.play(self.resMan:getSound("ambient"), { channel = 1, loops = -1 });
    audio.setVolume(0.25, { channel = 1 });
  end

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

  audio.play(self.resMan:getSound("ambient"), { channel = 1, loops = -1 });
  audio.setVolume(0.25, { channel = 1 });

end -- End startEvent().


---
-- Called right before "GAME OVER" is shown to end a game.
--
function scene:endEvent()

  audio.stop();

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

  local boulderAppearanceFrequencyLow = 4;
  local boulderAppearanceFrequencyHigh = 10;

  local boulder = self.resMan:getSprite("boulder");
  local ship = self.resMan:getSprite("ship");

  -- If the flag is set then the ship collided with a wall and we need to reset things.
  if self.shipCollision == true then
    self.shipCollision = false;
    self.fingerDown = false;
    self.currentShipYChange = 0;
    ship.y = display.contentCenterY + 50;
    self.scoreFrameCount = 0;
    boulder.isVisible = false;
    boulder.x = display.contentWidth + boulder.width;
    -- Pick a random next appearance time.
    self.framesUntilNextBoulderAppearance =
      30 * math.random(boulderAppearanceFrequencyLow, boulderAppearanceFrequencyHigh);
  end

  -- Increase score if it's time.
  self.scoreFrameCount = self.scoreFrameCount + 1;
  if self.scoreFrameCount >= 30 then
    self.scoreFrameCount = 0;
    self.updateScore(self, 2);
  end

  -- Move all tiles.
  local cavernSpeed = 10;
  for i = 1, 14, 1 do
    local t = self.resMan:getSprite("top" .. i);
    t.x = t.x - cavernSpeed;
    local b = self.resMan:getSprite("bottom" .. i);
    b.x = b.x - cavernSpeed;
  end
  -- When we've moved far enough, it's time to shift things.
  if self.resMan:getSprite("top1").x <= -162 then
    for i = 1, 13, 1 do
      -- Reset X coordinates.
      local t = self.resMan:getSprite("top" .. i)
      local b = self.resMan:getSprite("bottom" .. i)
      local newX = (108 * i) - 162;
      t.x = newX;
      b.x = newX;
      -- Copy the Y from the tiles to the right.
      local t1 = self.resMan:getSprite("top" .. i + 1);
      local b1 = self.resMan:getSprite("bottom" .. i + 1);
      t.y = t1.y;
      b.y = b1.y;
    end
    -- Now, reset the 14th (off-screen) top tile and give it a random height.
    local newX = (108 * 14) - 162;
    local newY = math.random(0, 400);
    local t14 = self.resMan:getSprite("top14");
    t14.x = newX;
    t14.y = newY;
    -- Now do the same thing for the bottom tiles.
    newY = math.random(0, 350);
    local b14 = self.resMan:getSprite("bottom14");
    b14.x = newX;
    b14.y = display.contentHeight - newY;
  end

  -- Move the ship according to "gravity".
  ship.y = ship.y + self.currentShipYChange;

  -- Adjust the effect of "gravity" on the ship.
  local amountChangePerFrame = 1.0;
  if self.fingerDown == true then
    self.currentShipYChange = self.currentShipYChange - amountChangePerFrame;
  else
    self.currentShipYChange = self.currentShipYChange + amountChangePerFrame;
  end

  -- Deal with the boulder.  Determine if it's time to show it, or if it's already showing then move it and
  -- set up for the next appearance when it goes off screen.
  local boulderSpeed = 8;
  if boulder.isVisible == true then
    boulder.x = boulder.x - boulderSpeed;
    if boulder.x < -(boulder.width * 2) then
      boulder.isVisible = false;
      boulder.x = display.contentWidth + boulder.width;
      -- Pick a random next appearance time.
      self.framesUntilNextBoulderAppearance =
      30 * math.random(boulderAppearanceFrequencyLow, boulderAppearanceFrequencyHigh);
    end
  else
    -- We're currently waiting for the next appearance.
    self.framesUntilNextBoulderAppearance = self.framesUntilNextBoulderAppearance - 1;
    if self.framesUntilNextBoulderAppearance <= 0 then
      boulder.isVisible = true;
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

  -- At begin phase, determine which direction to move.  Also, record when a hold begins on the left or right side.
  if inEvent.phase == "began" then
    self.fingerDown = true;
    self.currentShipYChange = 0;
  elseif inEvent.phase == "ended" then
    self.fingerDown = false;
    self.currentShipYChange = 0;
  end

  return true;

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
    local explosionParticleEmitter = display.newEmitter(self.explosionEmitterParams);
    local ship = self.resMan:getSprite("ship");
    explosionParticleEmitter.x = ship.x;
    explosionParticleEmitter.y = ship.y;
    self.shipCollision = true;
    audio.play(self.resMan:getSound("explosion"));
    self.updateScore(self, -50);
  end

end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


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
