local miniGameName = "defender";
local miniGamePath = "miniGames/defender/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Time to be a do-gooder: you gotta protect the innocents from the baddies!" ..
  "||Tap the guys with guns to protect the innocents, but don't tap innocents.";


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

  for i = 1, 20, 1 do
    local target = self.resMan:newSprite("targets" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
      { name = "enemy1", start = sheetInfo:getFrameIndex("enemy1_1"), count = 2, time = 500 },
      { name = "enemy2", start = sheetInfo:getFrameIndex("enemy2_1"), count = 2, time = 500 },
      { name = "enemy3", start = sheetInfo:getFrameIndex("enemy3_1"), count = 2, time = 500 },
      { name = "enemy4", start = sheetInfo:getFrameIndex("enemy4_1"), count = 2, time = 500 },
      { name = "enemy5", start = sheetInfo:getFrameIndex("enemy5_1"), count = 2, time = 500 },
      { name = "enemy6", start = sheetInfo:getFrameIndex("enemy6_1"), count = 2, time = 500 },
      { name = "enemy7", start = sheetInfo:getFrameIndex("enemy7_1"), count = 2, time = 500 },
      { name = "enemy8", start = sheetInfo:getFrameIndex("enemy8_1"), count = 2, time = 500 },
      { name = "goodguy1", start = sheetInfo:getFrameIndex("goodguy1_1"), count = 2, time = 500 },
      { name = "goodguy2", start = sheetInfo:getFrameIndex("goodguy2_1"), count = 2, time = 500 },
      { name = "goodguy3", start = sheetInfo:getFrameIndex("goodguy3_1"), count = 2, time = 500 },
      { name = "goodguy4", start = sheetInfo:getFrameIndex("goodguy4_1"), count = 2, time = 500 },
      { name = "goodguy5", start = sheetInfo:getFrameIndex("goodguy5_1"), count = 2, time = 500 },
      { name = "goodguy6", start = sheetInfo:getFrameIndex("goodguy6_1"), count = 2, time = 500 },
      { name = "goodguy7", start = sheetInfo:getFrameIndex("goodguy7_1"), count = 2, time = 500 },
      { name = "goodguy8", start = sheetInfo:getFrameIndex("goodguy8_1"), count = 2, time = 500 }
    });
    target.targetIndex = i;
    self:repositionTarget(i);
  end

  -- Load sounds.
  self.resMan:loadSound("good", self.sharedResourcePath .. "drip.wav");
  self.resMan:loadSound("bad", self.sharedResourcePath .. "buzzer.wav");

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

    for i = 1, 20, 1 do
      self.resMan:getSprite("targets" .. i):addEventListener("touch",
        function(inEvent) self:targetTouchHandler(inEvent);
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

  -- Move each of the 20 targets.
  for i = 1, 20, 1 do
    local target = self.resMan:getSprite("targets" .. i);
    if target.targetDirection == 1 then -- Up
      target.y = target.y - target.targetSpeed;
      if target.y < -100 then
        self:repositionTarget(i)
      end
    elseif target.targetDirection == 2 then -- Down
      target.y = target.y + target.targetSpeed;
      if target.y > (display.contentHeight + 100) then
        self:repositionTarget(i)
      end
    elseif target.targetDirection == 3 then -- Left
      target.x = target.x - target.targetSpeed;
      if target.x < -100 then
        self:repositionTarget(i)
      end
    elseif target.targetDirection == 4 then -- Right
      target.x = target.x + target.targetSpeed;
      if target.y < display.contentWidth + 100 then
        self:repositionTarget(i)
      end
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
end -- End touch().


---
-- Handles touches on a target.
--
-- @param inEvent The event object.
--
function scene:targetTouchHandler(inEvent)

  if inEvent.phase == "ended" then

    -- Get a reference to the selected target.
    local target = inEvent.target;

    -- Score them based on good vs. bad target.
    if string.find(target.sequence, "goodguy") == nil then
      -- Enemy, add 2.
      audio.play(self.resMan:getSound("good"));
      self.updateScore(self, 2);
    else
      -- Good guy, subtract 2.
      audio.play(self.resMan:getSound("bad"));
      self.updateScore(self, -4);
    end

    -- Explode the target and re-position.
    local explosionParticleEmitter = display.newEmitter(self.explosionEmitterParams);
    explosionParticleEmitter.x = target.x;
    explosionParticleEmitter.y = target.y;
    self:repositionTarget(target.targetIndex);

  end -- End ended event.

end -- End targetTouchHandler().


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
-- Reposition a specified target off-screen.
--
-- @param inTargetNunmber The index into the targets array to reposition.
--
function scene:repositionTarget(inTargetNumber)

  local target = self.resMan:getSprite("targets" .. inTargetNumber);

  -- Randomly select a target type, direction of movement and movement speed.
  local targetType = math.random(1, 16);
  target.targetType = targetType;
  if targetType < 9 then
    target:setSequence("enemy" .. targetType);
    target:play();
  else
    target:setSequence("goodguy" .. (targetType - 8));
    target:play();
  end
  target.targetSpeed = math.random(3, 8);
  local targetDirection = math.random(1, 4);
  target.targetDirection = targetDirection;

  -- Now position the target off-screen in an appropriate location based on the direction of movement.
  if targetDirection == 1 then -- Up
    target.x = math.random(100, (display.contentWidth - 100));
    target.y = display.contentHeight + 100;
    target.rotation = -90;
  elseif targetDirection == 2 then -- Down
    target.x = math.random(100, (display.contentWidth - 100));
    target.y = -100;
    target.rotation = 90;
  elseif targetDirection == 3 then -- Left
    target.x = display.contentWidth + 100;
    target.y = math.random(300, (display.contentHeight - 100));
    target.rotation = -180;
  elseif targetDirection == 4 then -- Right
    target.x = -100;
    target.y = math.random(300, (display.contentHeight - 100));
    target.rotation = 0;
  end

end -- End repositionTarget().


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
