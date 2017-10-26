local miniGameName = "deathtrap";
local miniGamePath = "miniGames/deathtrap/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Even Indiana Jones would be worried! Get to the door without being electrocuted." ..
  "||Swipe up, down, left or right anywhere to move from tile to tile.";


-- The point that the touch event started at.
scene.touchStart = nil;

-- Constants for allowed player movements.
scene.NONE = 0;
scene.NE = 1;
scene.NW = 2;
scene.ES = 3;
scene.SW = 4;
scene.NES = 5;
scene.NSW = 6;
scene.ESW = 7;
scene.NEW = 8;
scene.NESW = 9;

-- A map of the valid moves the player can make on each tile.
scene.moveMatrix = {
  { scene.ES,   scene.ESW,  scene.ESW,  scene.ESW,  scene.NSW,  scene.NONE, scene.NONE, scene.NONE, scene.NONE },
  { scene.NES,  scene.NESW, scene.NESW, scene.NESW, scene.NSW,  scene.NONE, scene.NONE, scene.NONE, scene.NONE },
  { scene.NES,  scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.SW,   scene.NONE, scene.NONE, scene.NONE },
  { scene.NES,  scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NSW,  scene.NONE, scene.NONE, scene.NONE },
  { scene.NES,  scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.SW,   scene.NONE, scene.NONE },
  { scene.NES,  scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NSW,  scene.NONE, scene.NONE },
  { scene.NE,	  scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NSW,  scene.NONE, scene.NONE },
  { scene.NONE, scene.NES,  scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.NESW, scene.SW,   scene.NONE },
  { scene.NONE, scene.NE,   scene.NEW,  scene.NEW,  scene.NEW,  scene.NEW,  scene.NEW,  scene.NW,   scene.NONE }
};

-- Which of the pathMatrix maps is active.
scene.correctPath = nil;

-- These are maps that define the layout of which tiles are safe (1) and
-- which are instant electrical death (0).
scene.pathMatrix = {
  {
    { 1, 1, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 1, 1, 1, 1, 1, 0, 0, 0 },
    { 1, 1, 0, 0, 0, 1, 0, 0, 0 },
    { 1, 1, 0, 0, 0, 1, 0, 0, 0 },
    { 1, 1, 0, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 0, 0, 0, 0, 0 }
  },
  {
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 1, 1, 1, 1, 1, 1, 0, 0, 0 },
    { 1, 0, 0, 0, 1, 1, 0, 0, 0 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 1, 1, 1, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 1, 0, 1, 1, 0, 0, 0 },
    { 0, 1, 1, 0, 0, 0, 0, 0, 0 },
    { 0, 1, 1, 0, 0, 0, 0, 0, 0 }
  },
  {
    { 1, 1, 1, 0, 1, 0, 0, 0, 0 },
    { 1, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 1, 1, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 1, 0, 0, 0 },
    { 1, 1, 1, 1, 0, 1, 0, 0, 0 },
    { 1, 0, 0, 1, 0, 1, 0, 0, 0 },
    { 1, 1, 0, 1, 1, 1, 0, 0, 0 },
    { 0, 1, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 1, 1, 0, 1, 1, 1, 0, 0 }
  },
  {
    { 1, 1, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 1, 1, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 1, 0, 0, 0 },
    { 0, 0, 1, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 1, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 1, 1, 1, 1, 1, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 1, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 1, 0, 0 }
  },
  {
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 1, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 0, 0, 0, 0, 0 },
    { 0, 1, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 0, 0, 0, 0 }
  },
  {
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 1, 1, 1, 0, 1, 0, 0, 0, 0 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0 },
    { 1, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 1, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 1, 0, 1, 1, 1, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 1, 0, 0 }
  },
  {
    { 0, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 0, 0, 1, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 1, 0, 1, 1, 0, 0, 0, 0 },
    { 0, 1, 0, 1, 0, 0, 0, 0, 0 },
    { 1, 1, 0, 1, 1, 1, 1, 0, 0 },
    { 1, 1, 0, 0, 0, 0, 1, 0, 0 },
    { 0, 1, 0, 0, 0, 0, 1, 1, 0 },
    { 0, 1, 1, 1, 1, 1, 1, 1, 0 }
  },
  {
    { 1, 1, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 0, 0, 1, 1, 0, 0, 0, 0 },
    { 1, 1, 1, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 1, 1, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 1, 1, 0, 0, 0 },
    { 0, 1, 1, 0, 0, 1, 0, 0, 0 },
    { 0, 1, 1, 0, 0, 1, 0, 0, 0 },
    { 0, 1, 1, 0, 0, 1, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 0, 0, 0 }
  },
  {
    { 1, 1, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0 },
    { 1, 0, 1, 0, 1, 1, 0, 0, 0 },
    { 1, 1, 1, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 1, 1, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 1, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 1, 0, 0 }
  },
  {
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 0, 0, 0, 0 },
    { 0, 1, 0, 1, 0, 0, 0, 0, 0 },
    { 1, 1, 0, 1, 0, 1, 0, 0, 0 },
    { 1, 0, 0, 1, 0, 1, 0, 0, 0 },
    { 1, 1, 0, 1, 0, 1, 0, 0, 0 },
    { 0, 1, 0, 1, 1, 1, 0, 0, 0 },
    { 0, 1, 1, 0, 0, 1, 1, 1, 0 }
  }
};


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

  local background = self.resMan:newSprite("background", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("background"), count = 1, time = 9999 }
  );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;
  background:setSequence("default");
  background:play();

  local player = self.resMan:newSprite("player", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "standing", start = sheetInfo:getFrameIndex("player_standing"), count = 1, time = 9999 },
    { name = "jumping", start = sheetInfo:getFrameIndex("player_jumping"), count = 1, time = 9999 },
    { name = "dieing", start = sheetInfo:getFrameIndex("player_dieing_00"), count = 2, time = 250, loopCount = 4 }
  });
  player.x = -4000;
  player.y = -4000;
  player.playerTile = nil;
  player:setSequence("standing");
  player:play();

  -- Load sounds.
  self.resMan:loadSound("jump", self.sharedResourcePath .. "jump.wav");
  self.resMan:loadSound("zap", self.sharedResourcePath .. "electricity.wav");
  self.resMan:loadSound("win", self.sharedResourcePath .. "fanfare.wav");

  -- Reset for a new game.
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

  local player = self.resMan:getSprite("player");

  -- If the player is currently being zapped then don't respond to touch events.
  if player.sequence == "dieing" then
    self.touchStart = nil;
    return;
  end

  if inEvent.phase == "began" then

    self.touchStart = { x = inEvent.x, y = inEvent.y };

  elseif inEvent.phase == "ended" and self.touchStart ~= nil and player.isWinning == false and
      player.sequence == "standing" then

    local xDelta_leftRight = 141;
    local xDelta_upDown = 54;
    local yDelta = 86;

    -- Determine what direction swipe was in.
    local swipeDir = self:determineSwipeDirection(self.touchStart, { x = inEvent.x, y = inEvent.y });
    self.touchStart = nil;

    -- If the player jumps "up" on the final door tile then they won.
    if swipeDir == self.SWIPE_UP and player.playerTile.y == 1 and player.playerTile.x == 5 then
      audio.play(self.resMan:getSound("win"));
      self.updateScore(self, 250);
      player.isWinning = true;
      transition.to(player, {
        time = 1000, xScale = 0, yScale = 0, alpha = 0,
        x = (player.x + xDelta_upDown + 60), y = (player.y - yDelta - 80),
        onComplete = function()
          self:resetGame();
        end
      });
      return;
    end

    -- Now see if it's a valid move.
    if self:isMoveValid(swipeDir) then
      player:setSequence("jumping");
      if swipeDir == self.SWIPE_UP then
        player.playerTile.y = player.playerTile.y - 1;
        audio.play(self.resMan:getSound("jump"));
        transition.to(player, {
          x = xDelta_upDown, y = -yDelta, delta = true, time = 250,
          onComplete = function()
            player:setSequence("standing");
            self:landedOnNewTile();
          end
        });
      elseif swipeDir == self.SWIPE_DOWN then
        player.playerTile.y = player.playerTile.y + 1;
        audio.play(self.resMan:getSound("jump"));
        transition.to(player, {
          x = -xDelta_upDown, y = yDelta, delta = true, time = 250,
          onComplete = function()
            player:setSequence("standing");
            self:landedOnNewTile();
          end
        });
      elseif swipeDir == self.SWIPE_LEFT then
        player.playerTile.x = player.playerTile.x - 1;
        audio.play(self.resMan:getSound("jump"));
        transition.to(player, {
          x = -xDelta_leftRight, delta = true, time = 250,
          onComplete = function()
            player:setSequence("standing");
            self:landedOnNewTile();
          end
        });
      elseif swipeDir == self.SWIPE_RIGHT then
        player.playerTile.x = player.playerTile.x + 1;
        audio.play(self.resMan:getSound("jump"));
        transition.to(player, {
          x = xDelta_leftRight, delta = true, time = 250,
          onComplete = function()
            player:setSequence("standing");
            self:landedOnNewTile();
          end
        });
      end
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
-- Determines if s player movement in a given direction is valid (i.e., leads to a full tile).
--
-- @param  inMoveDirection The direction to move (one of the direction constants).
-- @return                 True if valid, false if not.
--
function scene:isMoveValid(inMoveDirection)

  local player = self.resMan:getSprite("player");

  -- Up.
  if inMoveDirection == self.SWIPE_UP then
    if self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NE or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NES or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NSW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NEW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NESW then
      return true;
    end
  end

  -- Right.
  if inMoveDirection == self.SWIPE_RIGHT then
    if self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NE or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.ES or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NES or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.ESW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NEW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NESW then
      return true;
    end
  end

  -- Down.
  if inMoveDirection == self.SWIPE_DOWN then
    if self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.ES or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.SW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NES or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NSW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.ESW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NESW then
      return true;
    end
  end

  -- Left.
  if inMoveDirection == self.SWIPE_LEFT then
    if self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.SW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NSW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.ESW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NEW or
      self.moveMatrix[player.playerTile.y][player.playerTile.x] == self.NESW then
      return true;
    end
  end

  return false;

end -- End isMoveValid().


---
-- Deals with the player landing on a new tile.
--
function scene:landedOnNewTile()

  -- If tile is a death tile, start the animation for dieing.
  local player = self.resMan:getSprite("player");
  if self.pathMatrix[self.correctPath][player.playerTile.y][player.playerTile.x] == 0 then
    self.updateScore(self, -2);
    player:setSequence("dieing");
    audio.play(self.resMan:getSound("zap"));
    player:addEventListener("sprite", function(inEvent) self:deathListener(inEvent); end );
    player:play();
  else
    self.updateScore(self, 2);
  end

end -- End landedOnNewTile().


---
-- Handler for events on the player sprite when dieing animation is playing.
--
-- @param inEvent The event object
--
function scene:deathListener(inEvent)

  if inEvent.phase == "ended" then
    local player = self.resMan:getSprite("player");
    player:setSequence("standing");
    player.x = display.contentCenterX - 424;
    player.y = display.contentCenterY + 396;
    player.playerTile = { x = 2, y = 9 };
  end

end -- End deathListener().


---
-- Reset game (at start, or when player completes).
--
function scene:resetGame()

  -- Position player and reset scale.
  local player = self.resMan:getSprite("player");
  player.x = display.contentCenterX - 424;
  player.y = display.contentCenterY + 396;
  player.xScale = 1;
  player.yScale = 1;
  player.alpha = 1;
  player.playerTile = { x = 2, y = 9 };
  player.isWinning = false;

  self.touchStart = nil;

  -- Choose new correct path.
  self.correctPath = math.random(1, 10);

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
