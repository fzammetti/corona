local miniGameName = "antigravitator";
local miniGamePath = "miniGames/antigravitator/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
"Convicts are escaping! You're the gunner, so do your shootin' thing to, uhh, take care of the problem." ..
    "||Tap anywhere to fire.";


-- Physics.
local physics = require("physics");
physics.start();
physics.setGravity(0, 0);

-- Constants for gun movement direction.
scene.GUN_MOVE_DIR_UP = 1;
scene.GUN_MOVE_DIR_DOWN = 2;


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

  for i = 1, 6, 1 do
    local enemy = self.resMan:newSprite("enemies" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet,
      { name = "default", start = sheetInfo:getFrameIndex("enemy_00"), count = 2, time = 500 }
    );
    enemy.y = display.contentHeight + 1000;
    enemy.objType = "enemy";
    enemy.enemyNumber = i;
    enemy.spawnMe = false;
    physics.addBody(enemy, "dynamic", { isSensor = true });
    enemy.isSleepingAllowed = false;
    enemy:setSequence("default");
    enemy:play();
    self:spawnEnemy(enemy);
  end

  local gravPits = { nil, nil, nil };
  for i = 1, 3, 1 do
    gravPits[i] = self.resMan:newSprite("gravpit" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet,
      { name = "default", start = sheetInfo:getFrameIndex("gravpit_00"), count = 2, time = 500 }
    );
    if i == 1 then
      gravPits[i].x = 200;
    elseif i == 2 then
      gravPits[i].x = display.contentCenterX;
    elseif i == 3 then
      gravPits[i].x = display.contentWidth - 200;
    end
    gravPits[i].y = display.contentHeight - (gravPits[i].height / 2);
    gravPits[i]:setSequence("default");
    gravPits[i]:play();
  end

  local ship = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("ship_00"), count = 6, time = 500 }
  );
  ship.x = display.contentCenterX;
  ship.y = 210;
  ship:setSequence("default");
  ship:play();

  local laserbeam = self.resMan:newRect(
    "laserbeam", self.resMan:getDisplayGroup("gameGroup"), display.contentCenterX + 1000, 0, 10, 16
  );
  laserbeam.fill.effect = "generator.random";
  laserbeam.isVisible = false;
  laserbeam.objType = "laserbeam";
  laserbeam.phase = nil;
  physics.addBody(laserbeam, "dynamic", { isSensor = true });
  laserbeam.isSleepingAllowed = false;

  local gun = self.resMan:newSprite("gun", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("gun"), count = 1, time = 9999 }
  });
  gun.x = gun.width / 2;
  gun.y = 400;
  gun.moveDir = self.GUN_DIR_UP;

  -- Load sounds.
  self.resMan:loadSound("explosion", self.sharedResourcePath .. "explosion.wav");
  self.resMan:loadSound("missileFiring", self.sharedResourcePath .. "laser.wav");

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

    self.resMan:getRect("laserbeam").isVisible = false;
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
    self.resMan:getRect("laserbeam").isVisible = false;
  else
    -- Menu is being hidden.
    self.resMan:getRect("laserbeam").isVisible = true;
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

  local laserbeam = self.resMan:getRect("laserbeam");
  local gun = self.resMan:getSprite("gun");

  -- Move the gun if not firing.
  if laserbeam.isVisible == false then
    local gunMoveSpeed = 10;
    if gun.moveDir == self.GUN_MOVE_DIR_UP then
      gun.y = gun.y - gunMoveSpeed;
      if gun.y <= 400 then
        gun.moveDir = self.GUN_MOVE_DIR_DOWN;
      end
    else
      gun.y = gun.y + gunMoveSpeed;
      if gun.y >= 1760 then
        gun.moveDir = self.GUN_MOVE_DIR_UP;
      end
    end
  end

  -- Move the laserbeam if firing.
  if laserbeam.isVisible == true then
    -- First, the laserbeam grows in width to it's maximum size so it "emerges" from the gun.
    if laserbeam.phase == "growing" then
      laserbeam.width = laserbeam.width + 75;
      physics.removeBody(laserbeam);
      physics.addBody(laserbeam, "dynamic", { isSensor = true });
      if laserbeam.width > display.contentWidth then
        laserbeam.phase = "moving";
      end
    end
    -- And all along, it's moving to the right.
    laserbeam.x = laserbeam.x + 35;
    if laserbeam.x > display.contentWidth + (laserbeam.width / 2) then
      laserbeam.isVisible = false;
    end
  end

  -- Move enemies and respawn if they reach the top (also respawn them if they're marked for respawn, which will
  -- happen after they're hit... have to do it this way to avoid an error trying to move an object during a collision).
  for i = 1, 6, 1 do
    local enemy = self.resMan:getSprite("enemies" .. i);
    if enemy.spawnMe == true then
      enemy.spawnMe = false;
      self:spawnEnemy(enemy);
    end
    enemy.y = enemy.y - (enemy.moveSpeed * 3);
    if enemy.y < 100 then
      self:spawnEnemy(enemy);
      self.updateScore(self, -2);
    end
    -- Also, destroy the explosion emitter attached to this enemy, if any, if it's done emitting.
    if enemy.explosionParticleEmitter ~= nil and enemy.explosionParticleEmitter.state == "stopped" then
      enemy.explosionParticleEmitter:removeSelf();
      enemy.explosionParticleEmitter = nil;
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

  local laserbeam = self.resMan:getRect("laserbeam");

  -- Fire laserbeam if not already firing.
  if inEvent.phase == "began" and laserbeam.isVisible == false then
    local gun = self.resMan:getSprite("gun");
    laserbeam.width = 10;
    laserbeam.x = gun.x;
    laserbeam.y = gun.y;
    laserbeam.phase = "growing";
    laserbeam.isVisible = true;
    laserbeam.fill.effect = "generator.random";
    laserbeam:toBack();
    audio.play(self.resMan:getSound("missileFiring"));
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
    if obj1 == "laserbeam" or obj2 == "laserbeam" then

      -- Get references to the enemy and the laserbeam.
      local enemy = inEvent.object1;
      local laserbeam = inEvent.object2;
      if inEvent.object2.objType == "enemy" then
        -- Swap the references.  Neat little multiple assignment trick!
        enemy, laserbeam = laserbeam, enemy;
      end

      -- Play sound, update score, show explosion and respawn enemy.
      audio.play(self.resMan:getSound("explosion"));
      self.updateScore(self, 2);
      -- Explosion emitter gets attached to enemy so we can destroy it in enterFrame when it's done emitting.
      local explosionParticleEmitter = display.newEmitter(self.explosionEmitterParams);
      explosionParticleEmitter.x = enemy.x;
      explosionParticleEmitter.y = enemy.y;
      enemy.explosionParticleEmitter = explosionParticleEmitter;
      enemy.spawnMe = true;

    end
  end

end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Randomly spawn a specified enemy at a position off-screen so they can emerge from a gravPit.
--
-- @param inEnemy The enemy sprite to place.
--
function scene:spawnEnemy(inEnemy)

  -- Randomly pick which gravPit they emerge from.
  local gravPit = math.random(1, 3);
  if gravPit == 1 then
    inEnemy.x = 200;
  elseif gravPit == 2 then
    inEnemy.x = display.contentCenterX;
  else
    inEnemy.x = display.contentWidth - 200;
  end

  -- Set their Y location to a random value somewhere below the gravPit.  This ensures they emerge at more random times.
  inEnemy.y = display.contentHeight + math.random(100, 300);

  -- Choose a random speed.  Since
  inEnemy.moveSpeed = math.random(1, 3);

end -- End spawnEnemy().


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
