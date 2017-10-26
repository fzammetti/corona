local miniGameName = "theBogazDerby";
local miniGamePath = "miniGames/theBogazDerby/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Drive your ship way too fast down an intergalactic starway and avoid other ships!" ..
  "||Touch and hold left or right half of screen to move your ship that way.";


-- Physics.
local physics = require("physics");
physics.start();
physics.setGravity(0, 0);
local physicsData = (require ("miniGames." .. miniGameName .. ".physicsData")).physicsData(1.0);

-- Constants for player movement directions.
scene.PLAYER_DIR_LEFT = "left";
scene.PLAYER_DIR_RIGHT = "right";

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

  -- Player.
  local player = self.resMan:newSprite("player", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("player"), count = 1, time = 9999 }
  });
  player.x = display.contentCenterX;
  player.y = display.contentHeight - (player.height / 2) - 40;
  player.playerDir = nil;
  physics.addBody(player, "dynamic", physicsData:get("player"));

  -- Enemy.
  local enemy = self.resMan:newSprite("enemy", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("enemy"), count = 1, time = 9999 }
  });
  enemy.explosionParticleEmitter = nil;
  physics.addBody(enemy, "dynamic", physicsData:get("enemy"));
  self:resetEnemy();

  -- Load sounds.
  self.resMan:loadSound("ambient", self.sharedResourcePath .. "ambient.wav");
  self.resMan:loadSound("honk", miniGamePath .. "honk.wav");
  self.resMan:loadSound("crash", miniGamePath .. "crash.wav");

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

  if inEvent.phase == "will" then

    transition.to(backgroundParticleEmitter, { gravityy = backgroundParticleEmitter.originalGravityY, time = 500 });
    transition.to(backgroundParticleEmitter, { y = display.contentCenterY, time = 500 });

  elseif inEvent.phase == "did" then

    --utils:log(self.miniGameName, "hide(): did");

    physics.stop();
    system.deactivate("multitouch");
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

  backgroundParticleEmitter.originalGravityY = backgroundParticleEmitter.gravityy;
  transition.to(backgroundParticleEmitter, { gravityy = 400, time = 500 });
  transition.to(backgroundParticleEmitter, { y = -200, time = 500 });

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
  transition.to(backgroundParticleEmitter, { gravityy = backgroundParticleEmitter.originalGravityY, time = 500 });
  transition.to(backgroundParticleEmitter, { y = display.contentCenterY, time = 500 });

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

  local player = self.resMan:getSprite("player");
  local enemy = self.resMan:getSprite("enemy");

  -- If we have an explosion emitter on the enemy then that means a collision occurred and we have to handle it here.
  if enemy.explosionParticleEmitter ~= nil then
    -- We need to ensure the enemy is hidden until the emitter completes.
    enemy.isVisible = false;
    enemy.y = -1000;
    -- When the emitter completes we need to show the enemy and reset their positions.
    if enemy.explosionParticleEmitter.state == "stopped" then
      enemy.explosionParticleEmitter:removeSelf();
      enemy.explosionParticleEmitter = nil;
      self:resetEnemy();
      enemy.isVisible = true;
    end
  -- No emitter.
  else
    -- Move the enemy and reset if they reach the bottom.
    enemy.y = enemy.y + enemy.speed;
    if enemy.y > display.contentHeight + 200 then
      audio.play(self.resMan:getSound("honk"));
      self:resetEnemy();
      self.updateScore(self, 5);
    end
  end

  -- Move the player.
  local playerMoveSpeed = 20;
  if player.playerDir == self.PLAYER_DIR_LEFT then
    player.x = player.x - playerMoveSpeed;
    -- Stop at edge of screen.
    if player.x < player.width / 2 then
      player.x = player.width / 2;
    end
  elseif player.playerDir == self.PLAYER_DIR_RIGHT then
    player.x = player.x + playerMoveSpeed;
    -- Stop at edge of screen.
    if player.x > display.contentWidth - (player.width / 2) then
      player.x = display.contentWidth - (player.width / 2);
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
  local player = self.resMan:getSprite("player");
  if inEvent.phase == "began" then
    if inEvent.x < display.contentCenterX then
      self.leftDown = true;
      player.playerDir = self.PLAYER_DIR_LEFT;
    else
      self.rightDown = true;
      player.playerDir = self.PLAYER_DIR_RIGHT;
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
      player.playerDir = self.PLAYER_DIR_LEFT;
    elseif self.leftDown == false and self.rightDown == true then
      player.playerDir = self.PLAYER_DIR_RIGHT;
    else
      player.playerDir = nil;
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

    local enemy = self.resMan:getSprite("enemy");

    audio.play(self.resMan:getSound("crash"));
    enemy.explosionParticleEmitter = display.newEmitter(self.explosionEmitterParams);
    enemy.explosionParticleEmitter.x = enemy.x;
    enemy.explosionParticleEmitter.y = enemy.y;
    enemy.explosionParticleEmitter.xScale = 2;
    enemy.explosionParticleEmitter.yScale = 2;
    self.updateScore(self, -20);

  end

end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Chooses a new random X location and speed for the enemy and position off-screen top.
--
function scene:resetEnemy()

  -- Enemy.
  local enemy = self.resMan:getSprite("enemy");
  enemy.x = math.random((enemy.width / 2) + 10, display.contentWidth - (enemy.width / 2) - 10);
  enemy.y = -240;
  enemy.speed = math.random(10, 30);

end -- End resetEnemy().


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
