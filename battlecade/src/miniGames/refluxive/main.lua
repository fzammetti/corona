local miniGameName = "refluxive"
local miniGamePath = "miniGames/refluxive/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Rocks... from space! Use your special Rock Rejector 9000(tm) to keep 'em at bay." ..
  "||Touch and hold left or right half of screen to move your bouncer thingy that way.";


-- Physics.
local physics = require("physics");
physics.start();
physics.setGravity(0, 0);
local physicsData = (require ("miniGames." .. miniGameName .. ".physicsData")).physicsData(1.0);

-- Constants for paddle movement directions.
scene.PADDLE_DIR_LEFT = "left";
scene.PADDLE_DIR_RIGHT = "right";

-- Constants for bouncy movement directions.
scene.BOUNCY_DIR_NE = 1;
scene.BOUNCY_DIR_NW = 2;
scene.BOUNCY_DIR_SE = 3;
scene.BOUNCY_DIR_SW = 4;

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

  local paddle = self.resMan:newSprite("paddle", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("paddle"), count = 1, time = 9999 }
  });
  paddle.x = display.contentCenterX;
  paddle.y = display.contentHeight - 100;
  paddle.objType = "paddle";
  paddle.paddleDir = nil;
  physics.addBody(paddle, "dynamic", physicsData:get("paddle"));
  paddle.isSleepingAllowed = false;

  for i = 1, 3, 1 do
    local b = self.resMan:newSprite("bouncies" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
      { name = "default", start = sheetInfo:getFrameIndex("bouncy"), count = 1, time = 9999 }
    });
    b.x = math.random(b.width, display.contentWidth - b.width);
    b.y = math.random(b.height, display.contentHeight / 3);
    b.movementDir = math.random(1, 4);
    b.objType = "bouncy";
    physics.addBody(b, "dynamic", physicsData:get("bouncy"));
    b.isSleepingAllowed = false;
  end

  -- Load sounds.
  self.resMan:loadSound("bounce", self.sharedResourcePath .. "bounce.wav");
  self.resMan:loadSound("missed", self.sharedResourcePath .. "buzzer.wav");

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

  local bouncyMoveSpeed = 16;
  local paddleMoveSpeed = bouncyMoveSpeed - 4;

  local paddle = self.resMan:getSprite("paddle");

  -- Paddle moving?
  if paddle.paddleDir == self.PADDLE_DIR_LEFT then
    paddle.x = paddle.x - paddleMoveSpeed;
    -- Stop at edge of screen.
    if paddle.x < paddle.width / 2 then
      paddle.x = paddle.width / 2;
    end
  elseif paddle.paddleDir == self.PADDLE_DIR_RIGHT then
    paddle.x = paddle.x + paddleMoveSpeed;
    -- Stop at edge of screen.
    if paddle.x > display.contentWidth - (paddle.width / 2) then
      paddle.x = display.contentWidth - (paddle.width / 2);
    end
  end

  local bounciesVisible = 0;
  for i = 1, 3, 1 do

    local b = self.resMan:getSprite("bouncies" .. i);
    if b.isVisible == true then

      bounciesVisible = bounciesVisible + 1;

      -- Move the bouncies.
      if b.movementDir == self.BOUNCY_DIR_NE then
        b.x = b.x + bouncyMoveSpeed;
        b.y = b.y - bouncyMoveSpeed;
      elseif b.movementDir == self.BOUNCY_DIR_NW then
        b.x = b.x - bouncyMoveSpeed;
        b.y = b.y - bouncyMoveSpeed;
      elseif b.movementDir == self.BOUNCY_DIR_SE then
        b.x = b.x + bouncyMoveSpeed;
        b.y = b.y + bouncyMoveSpeed;
      elseif b.movementDir == self.BOUNCY_DIR_SW then
        b.x = b.x - bouncyMoveSpeed;
        b.y = b.y + bouncyMoveSpeed;
      end

      -- Update bouncy rotation.
      b.rotation = b.rotation + 6;
      if b.rotation > 360 then
        b.rotation = 0;
      end

      -- Bounce off the screen edges (horizontal).
      if b.x < (b.width / 2) then
        if b.movementDir == self.BOUNCY_DIR_NW then
          b.movementDir = self.BOUNCY_DIR_NE;
        end
        if b.movementDir == self.BOUNCY_DIR_SW then
          b.movementDir = self.BOUNCY_DIR_SE;
        end
      elseif b.x > display.contentWidth - (b.width / 2) then
        if b.movementDir == self.BOUNCY_DIR_NE then
          b.movementDir = self.BOUNCY_DIR_NW;
        end
        if b.movementDir == self.BOUNCY_DIR_SE then
          b.movementDir = self.BOUNCY_DIR_SW;
        end
      end

      -- Bounce off the screen edges (vertical).
      if b.y < b.height then
        if b.movementDir == self.BOUNCY_DIR_NE then
          b.movementDir = self.BOUNCY_DIR_SE;
        end
        if b.movementDir == self.BOUNCY_DIR_NW then
          b.movementDir = self.BOUNCY_DIR_SW;
        end
      end

      -- See if it goes off the bottom of the screen, flag it if so
      if b.y > display.contentHeight and b.isVisible == true then
        audio.play(self.resMan:getSound("missed"));
        b.isVisible = false;
        self.updateScore(self, -25);
      end

    end -- End bouncy visibility check.

  end -- End for loop.

  -- Check to see if all bouncies are gone.  If so, reset game.
  if bounciesVisible == 0 then
    self.updateScore(self, -100);
    for i = 1, 3, 1 do
      local b = self.resMan:getSprite("bouncies" .. i);
      b.isVisible = true;
      b.movementDir = nil;
      transition.to(b, {
        x = math.random(b.width, display.contentWidth - b.width),
        y = math.random(b.height, display.contentHeight / 3),
        time = 1000,
        onComplete = function(inBouncie)
          inBouncie.movementDir = math.random(1, 4);
        end
      });
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
    local paddle = self.resMan:getSprite("paddle");
    if inEvent.x < display.contentCenterX then
      self.leftDown = true;
      paddle.paddleDir = self.PADDLE_DIR_LEFT;
    else
      self.rightDown = true;
      paddle.paddleDir = self.PADDLE_DIR_RIGHT;
    end
    -- At ended phase, we need to determine if the lift was on the left or right side and flip the appropriate flag.
  elseif inEvent.phase == "ended" then
    local paddle = self.resMan:getSprite("paddle");
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
      paddle.paddleDir = self.PADDLE_DIR_LEFT;
    elseif self.leftDown == false and self.rightDown == true then
      paddle.paddleDir = self.PADDLE_DIR_RIGHT;
    else
      paddle.paddleDir = nil;
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
    if (obj1 == "bouncy" and obj2 == "paddle") or (obj1 == "paddle" and obj2 == "bouncy") then

      -- Get references to the bouncy and paddle.
      local bouncy = inEvent.object1;
      local paddle = inEvent.object2;
      if inEvent.object2.objType == "bouncy" then
        -- Swap the references.  Neat little multiple assignment trick!
        bouncy, paddle = paddle, bouncy;
      end

      -- Make sure the bouncy's Y coordinate isn't too far below that of the paddle.  This is to avoid the situation
      -- where hitting the side of the paddle counts as a catch (which is a problem because you can usually leave the
      -- paddle in the middle and at least one bouncy will get into a pattern where it'll keep bouncing forever without
      -- the player moving at all, and that's just too easy!).
      if bouncy.y > paddle.y then
        return;
      end

      -- Play sound and update score.
      audio.play(self.resMan:getSound("bounce"));
      self.updateScore(self, 2);

      -- Change bouncy direction.
      if bouncy.movementDir == self.BOUNCY_DIR_SE then
        bouncy.movementDir = self.BOUNCY_DIR_NW;
      elseif bouncy.movementDir == self.BOUNCY_DIR_SW then
        bouncy.movementDir = self.BOUNCY_DIR_NE;
      end

    end
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
