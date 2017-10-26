local miniGameName = "farOutFowl";
local miniGamePath = "miniGames/farOutFowl/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Ugh, giant space chickens, amiright?! Catch the eggs, don't let any drop!" ..
  "||Touch and hold left or right half of screen to move your basket that way.";


-- Physics.
local physics = require("physics");
physics.start();
physics.setGravity(0, 0);
local physicsData = (require ("miniGames." .. miniGameName .. ".physicsData")).physicsData(1.0);

-- Constants for catcher movement directions.
scene.CATCHER_DIR_LEFT = "left";
scene.CATCHER_DIR_RIGHT = "right";

-- Variables used to move the chicken and control chicken and egg speed.
scene.chickenEggSpeed = 12;
scene.chickenNewTargetLocation = nil;
scene.scoreFlipAmount = 40;
scene.prevScore = 0;

-- Variables related to the eggs in play.  The elements of these are DisplayObjects.
scene.fallingEggs = { };
scene.splatteredEggs = { };

-- Flags to record when fingers are held down on sides of the screen.
scene.leftDown = false;
scene.rightDown = false;


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

  local chicken = self.resMan:newSprite("chicken", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("chicken_00"), count = 2, time = 500 }
  );
  chicken.x = display.contentCenterX;
  chicken.y = 300;
  chicken:setSequence("default");
  chicken:play();
  self:chooseNewChickenTarget();

  local catcher = self.resMan:newSprite("catcher", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("catcher"), count = 1, time = 9999 }
  });
  catcher.x = display.contentCenterX;
  catcher.y = display.contentHeight - 100;
  catcher.objType = "catcher";
  catcher.catcherDir = nil;
  physics.addBody(catcher, "dynamic", physicsData:get("catcher"));
  catcher.isSleepingAllowed = false;

  -- Load sounds.
  self.resMan:loadSound("catch", self.sharedResourcePath .. "pop2.wav");
  self.resMan:loadSound("splat", self.sharedResourcePath .. "splat.wav");
  self.resMan:loadSound("squawk", miniGamePath .. "squawk.wav");

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

    -- Needed to allow multiple touch events, which makes the left/right control scheme work right with the touch logic.
    system.activate("multitouch");

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
    system.deactivate("multitouch");

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

  for i = 1, #self.fallingEggs, 1 do
    if self.fallingEggs[i] ~= nil then
      self.fallingEggs[i]:removeSelf();
    end
    self.fallingEggs[i] = nil;
  end
  self.fallingEggs = nil;
  for i = 1, #self.splatteredEggs, 1 do
    if self.splatteredEggs[i] ~= nil then
      self.splatteredEggs[i]:removeSelf();
    end
    self.splatteredEggs[i] = nil;
  end
  self.splatteredEggs = nil;

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

  local chicken = self.resMan:getSprite("chicken");
  local catcher = self.resMan:getSprite("catcher");

  -- Move the chicken towards the current target location.
  if chicken.x < self.chickenNewTargetLocation then
    chicken.x = chicken.x + self.chickenEggSpeed;
    if chicken.x >= self.chickenNewTargetLocation then
      -- Target location reached, time to drop an egg and start moving chicken to a new target location.
      self:spawnEgg();
      self:chooseNewChickenTarget();
    end
  else
    chicken.x = chicken.x - self.chickenEggSpeed;
    if chicken.x <= self.chickenNewTargetLocation then
      -- Target location reached, time to drop an egg and start moving chicken to a new target location.
      self:spawnEgg();
      self:chooseNewChickenTarget();
    end
  end

  -- Move the falling eggs.
  for i = 1, #self.fallingEggs, 1 do
    -- Only process eggs not marked for removal.
    if self.fallingEggs[i].removeMe == false then
      -- When it hits the "bottom", show a splattered egg.
      if self.fallingEggs[i].y > 1820 then
        -- Add a splattered egg.
        audio.play(self.resMan:getSound("splat"));
        local splatteredEgg = display.newSprite(
          self.resMan:getDisplayGroup("gameGroup"), self.resMan:getImageSheet("imageSheet"), {
            { name = "default", start = self.resMan:getImageSheetInfo("imageSheet"):getFrameIndex("splatteredEgg"),
              count = 1, time = 9999
            }
          }
        );
        splatteredEgg.x = self.fallingEggs[i].x;
        splatteredEgg.y = self.fallingEggs[i].y;
        splatteredEgg.displayFrameCount = 0;
        table.insert(self.splatteredEggs, splatteredEgg);
        -- Remove the falling egg.  We'll just mark it for removal here, it'll be removed later.
        self.fallingEggs[i].removeMe = true;
        -- Update score.
        self.updateScore(self, -2);
      else
        -- Just move the egg down.
        self.fallingEggs[i].y = self.fallingEggs[i].y + self.chickenEggSpeed;
      end
    end
  end

  -- Elapse time for the splattered eggs and remove when they've been displayed for long enough.
  for i = 1, #self.splatteredEggs, 1 do
    self.splatteredEggs[i].displayFrameCount = self.splatteredEggs[i].displayFrameCount + 1;
    if self.splatteredEggs[i].displayFrameCount > 30 then
      self.splatteredEggs[i]:removeSelf();
      self.splatteredEggs[i] = nil;
    end
  end

  -- Remove eggs marked for removal and clean up the arrays.
  for i = 1, #self.fallingEggs, 1 do
    if self.fallingEggs[i].removeMe == true then
      self.fallingEggs[i]:removeSelf();
      self.fallingEggs[i] = nil;
    end
  end

  -- Clean up the two arrays to eliminate nil elements.
  self.fallingEggs = utils:cleanArray(self.fallingEggs);
  self.splatteredEggs = utils:cleanArray(self.splatteredEggs);

  -- Move the catcher.
  local catcherMoveSpeed = self.chickenEggSpeed - 2;
  if catcher.catcherDir == self.CATCHER_DIR_LEFT then
    catcher.x = catcher.x - catcherMoveSpeed;
    -- Stop at edge of screen.
    if catcher.x < catcher.width / 2 then
      catcher.x = catcher.width / 2;
    end
  elseif catcher.catcherDir == self.CATCHER_DIR_RIGHT then
    catcher.x = catcher.x + catcherMoveSpeed;
    -- Stop at edge of screen.
    if catcher.x > display.contentWidth - (catcher.width / 2) then
      catcher.x = display.contentWidth - (catcher.width / 2);
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

  local catcher = self.resMan:getSprite("catcher");

  -- At begin phase, determine which direction to move.  Also, record when a hold begins on the left or right side.
  if inEvent.phase == "began" then
    if inEvent.x < display.contentCenterX then
      self.leftDown = true;
      catcher.catcherDir = self.CATCHER_DIR_LEFT;
    else
      self.rightDown = true;
      catcher.catcherDir = self.CATCHER_DIR_RIGHT;
    end
  -- At ended phase, we need to determine if the lift was on the left or right side and flip the appropriate flag.
  elseif inEvent.phase == "ended" then
    if inEvent.x < display.contentCenterX then
      -- If a finger was lifted on the left side and the leftDown flag is true then this is the simple case, just
      -- reset the flag.
      if self.leftDown == true then
        self.leftDown = false;
      -- However, if leftDown is NOT true, then that means the player pressed down on the left side but then moved
      -- their finger to the right and lifted, so we need to change that flag instead.
      else
        self.rightDown = false;
      end
    else
      -- The same sort of logic now applies if the lift was on the right side.
      if self.rightDown == true then
        self.rightDown = false;
      else
        self.leftDown = false;
      end
    end
    -- With the appropriate flag cleared, now we figure out what direction to move.  Doing it this way allows for
    -- multiple presses, so you can press left AND right simultaneously, and when you lift one side then the other
    -- takes its place the the direction of movement.
    if self.leftDown == true and self.rightDown == false then
      catcher.catcherDir = self.CATCHER_DIR_LEFT;
    elseif self.leftDown == false and self.rightDown == true then
      catcher.catcherDir = self.CATCHER_DIR_RIGHT;
    else
      catcher.catcherDir = nil;
    end
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

    local obj1 = inEvent.object1.objType;
    local obj2 = inEvent.object2.objType;
    if obj1 == "catcher" or obj2 == "catcher" then

      -- Get references to the catcher and the egg.
      local egg = inEvent.object1;
      local catcher = inEvent.object2;
      if inEvent.object2.objType == "egg" then
        -- Swap the references.  Neat little multiple assignment trick!
        egg, catcher = catcher, egg;
      end

      -- Play sound, update score and increase speed if it's time.
      audio.play(self.resMan:getSound("catch"));
      self.updateScore(self, 1);
      if self.score > self.prevScore + self.scoreFlipAmount then
        self.chickenEggSpeed = self.chickenEggSpeed + 2;
        self.prevScore = self.score;
        -- Increment the speed flip counter so the speed increases slower as we go
        self.scoreFlipAmount = self.scoreFlipAmount + 50;
      end

      -- Mark the egg for removal (to be done in enterFrame);
      egg.removeMe = true;

    end
  end

end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Spawns a new egg.
--
function scene:spawnEgg()

  local chicken = self.resMan:getSprite("chicken");

  audio.play(self.resMan:getSound("squawk"));
  local egg = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), self.resMan:getImageSheet("imageSheet"), {
    { name = "default", start = self.resMan:getImageSheetInfo("imageSheet"):getFrameIndex("egg"),
      count = 1, time = 9999
    }
  });
  chicken:toFront();
  egg.x = chicken.x;
  egg.y = chicken.y + 100;
  egg.objType = "egg";
  egg.removeMe = false;
  physics.addBody(egg, "dynamic", physicsData:get("egg"));
  egg.isSleepingAllowed = false;
  table.insert(self.fallingEggs, egg);
  egg.arrayIndex = #self.fallingEggs;

end -- End spawnEgg().


---
-- Chooses a new random target location for the chicken to drop an egg at.
--
function scene:chooseNewChickenTarget()

  local chicken = self.resMan:getSprite("chicken");
  self.chickenNewTargetLocation =
    math.random((chicken.width / 2) + 10, display.contentWidth - (chicken.width / 2) - 10);

end -- End chooseNewChickenTarget().


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
