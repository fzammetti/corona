local miniGameName = "theEscape";
local miniGamePath = "miniGames/theEscape/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "'Tis confusion! Push the rocks to the red pads to escape. If you get stuck, tap the skull to, uhh, try again." ..
  "||Swipe up, down, left or right anywhere to move.";


-- Graphics.
scene.rocks = { };
scene.tiles = { };

-- The point that the touch event started at.
scene.touchStart = nil;

-- Constants for player move directions.
scene.MOVING_UP = 1;
scene.MOVING_DOWN = 2;
scene.MOVING_RIGHT = 3;
scene.MOVING_LEFT = 4;

-- Constants for tile types in the levelPatters.
scene.TILE_NOTHING = 0;
scene.TILE_WALL = 1;
scene.TILE_DESTPAD = 2;
scene.TILE_PLAYER = 3;
scene.TILE_ROCK = 4;

-- Amount to shift all elements right and down to center on screen.
scene.xAdj = 50;
scene.yAdj = 300;

-- What level pattern is currently being used.
scene.currentLevelPattern = nil;

-- Patterns for the levels.
scene.levelPatterns = {
  {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 1, 3, 0, 1, 1, 1, 0, 0 },
    { 0, 0, 1, 0, 4, 0, 0, 1, 0, 0 },
    { 0, 1, 1, 1, 0, 1, 0, 1, 1, 0 },
    { 0, 1, 2, 1, 0, 1, 0, 0, 1, 0 },
    { 0, 1, 2, 4, 0, 0, 1, 0, 1, 0 },
    { 0, 1, 2, 0, 0, 0, 4, 0, 1, 0 },
    { 0, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { } -- Meta data, gets populated on-the-fly
  },
  {
    { 1, 1, 1, 1, 1, 0, 0, 0, 0, 0 },
    { 1, 3, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 1, 0, 4, 4, 1, 0, 0, 1, 1, 1 },
    { 1, 0, 4, 0, 1, 0, 0, 1, 2, 1 },
    { 1, 1, 1, 0, 1, 1, 1, 1, 2, 1 },
    { 0, 1, 1, 0, 0, 0, 0, 0, 2, 1 },
    { 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 },
    { 0, 1, 0, 0, 0, 1, 1, 1, 1, 1 },
    { 0, 1, 0, 0, 0, 1, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 },
    { } -- Meta data, gets populated on-the-fly
  },
  {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 2, 1, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 0, 1, 1, 1, 1, 0 },
    { 0, 1, 1, 1, 4, 0, 4, 2, 1, 0 },
    { 0, 1, 2, 0, 4, 3, 1, 1, 1, 0 },
    { 0, 1, 1, 1, 1, 4, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 2, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { } -- Meta data, gets populated on-the-fly
  },
  {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 },
    { 0, 0, 1, 1, 0, 0, 1, 0, 0, 0 },
    { 0, 0, 1, 3, 4, 0, 1, 0, 0, 0 },
    { 0, 0, 1, 1, 4, 0, 1, 1, 0, 0 },
    { 0, 0, 1, 1, 0, 4, 0, 1, 0, 0 },
    { 0, 0, 1, 0, 4, 0, 0, 1, 0, 0 },
    { 0, 0, 1, 2, 2, 2, 2, 1, 0, 0 },
    { 0, 0, 1, 1, 1, 1, 1, 1, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { } -- Meta data, gets populated on-the-fly
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

  self.resMan:newSprite("player", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "still", start = sheetInfo:getFrameIndex("player_still"), count = 1, time = 9999 },
    { name = "up", start = sheetInfo:getFrameIndex("player_up"), count = 1, time = 9999 },
    { name = "down", start = sheetInfo:getFrameIndex("player_down"), count = 1, time = 9999 },
    { name = "left", start = sheetInfo:getFrameIndex("player_left"), count = 1, time = 9999 },
    { name = "right", start = sheetInfo:getFrameIndex("player_right"), count = 1, time = 9999 }
  });

  local skull = self.resMan:newSprite("skull", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("skull"), count = 1, time = 9999 }
  });
  skull.x = display.contentWidth - (skull.width / 2) - 20;
  skull.y = display.contentHeight - (skull.width / 2) - 20;

  self:startLevel(1);

  -- Load sounds.
  self.resMan:loadSound("move", self.sharedResourcePath .. "splat2.wav");
  self.resMan:loadSound("push", self.sharedResourcePath .. "grunt.wav");
  self.resMan:loadSound("win", self.sharedResourcePath .. "harp.wav");
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

    self.resMan:getSprite("skull"):addEventListener("touch", function(inEvent) self:skullTouchHandler(inEvent); end );

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

  -- Destroy graphics.

  for i = 1, #self.rocks, 1 do
    if self.rocks[i] ~= nil then
      self.rocks[i]:removeSelf();
    end
    self.rocks[i] = nil;
  end
  self.rocks = nil;
  for i = 1, #self.tiles, 1 do
    if self.tiles[i] ~= nil then
      self.tiles[i]:removeSelf();
    end
    self.tiles[i] = nil;
  end
  self.tiles = nil;

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

  if inEvent.phase == "began" then

    self.touchStart = { x = inEvent.x, y = inEvent.y };

  elseif inEvent.phase == "ended" and self.touchStart ~= nil then

    -- Determine what direction swipe was in.
    local swipeDir = self:determineSwipeDirection(self.touchStart, { x = inEvent.x, y = inEvent.y });
    self.touchStart = nil;

    -- Now see if it's a valid move.  The call to canPlayerMove() also does the actual movement.
    local player = self.resMan:getSprite("player");
    player:setSequence("still");
    if swipeDir == self.SWIPE_UP then
      if self:canPlayerMove(self.SWIPE_UP) then
        player:setSequence("up");
      end
    elseif swipeDir == self.SWIPE_DOWN then
      if self:canPlayerMove(self.SWIPE_DOWN) then
        player:setSequence("down");
      end
    elseif swipeDir == self.SWIPE_LEFT then
      if self:canPlayerMove(self.SWIPE_LEFT) then
        player:setSequence("left");
      end
    elseif swipeDir == self.SWIPE_RIGHT then
      if self:canPlayerMove(self.SWIPE_RIGHT) then
        player:setSequence("right");
      end
    end

    -- See if all the rocks are sitting on destination pads.  If so, time to move on to the next level.
    local destpads = self.levelPatterns[self.currentLevelPattern][11].destpads;
    local numInPlace = 0;
    for i = 1, #self.rocks, 1 do
      local rock = self.rocks[i];
      for j = 1, #destpads, 1 do
        if rock.gridX == destpads[j].x and rock.gridY == destpads[j].y then
          numInPlace = numInPlace + 1;
        end
      end
    end
    if numInPlace == #self.rocks then
      audio.play(self.resMan:getSound("win"));
      self.updateScore(self, 50);
      self.currentLevelPattern = self.currentLevelPattern + 1;
      if self.currentLevelPattern > #self.levelPatterns then
        self.currentLevelPattern = 1;
      end
      self:startLevel(self.currentLevelPattern);
    end

  end

end -- End touch().


---
-- Function that handles touch events on the skull to reset the level when the player gets stuck.
--
-- @param inEvent The event object.
--
function scene:skullTouchHandler(inEvent)

  if inEvent.phase == "ended" then
    self.updateScore(self, -15);
    audio.play(self.resMan:getSound("explosion"));
    local player = self.resMan:getSprite("player");
    local explosionParticleEmitter = display.newEmitter(self.explosionEmitterParams);
    explosionParticleEmitter.x = player.x;
    explosionParticleEmitter.y = player.y;
    self:startLevel(self.currentLevelPattern);
  end

  return true;

end -- End skullTouchHandler().


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
-- Determines if a player movement is valid.
--
-- @param inDirection The swipe direction.
--
function scene:canPlayerMove(inDirection)

  local levelPattern = self.levelPatterns[self.currentLevelPattern];

  local player = self.resMan:getSprite("player");

  local xDelta = 0;
  local yDelta = 0;
  if inDirection == self.SWIPE_UP then
    yDelta = -1;
  elseif inDirection == self.SWIPE_DOWN then
    yDelta = 1;
  elseif inDirection == self.SWIPE_LEFT then
    xDelta = -1;
  elseif inDirection == self.SWIPE_RIGHT then
    xDelta = 1;
  end
  local pGridX = player.gridX;
  local pGridY = player.gridY;

  local pGridXNew = pGridX + xDelta;
  local pGridYNew = pGridY + yDelta;

  -- First, see if we'd hit a wall and abort it so.
  if levelPattern[pGridYNew][pGridXNew] == self.TILE_WALL then
    return false;
  end

  -- Next, if there's a rock where the player is trying to move to.
  local rocks = self.rocks;
  for i = 1, #rocks, 1 do
    local rock = rocks[i];
    local rGridX = rock.gridX;
    local rGridY = rock.gridY;
    local rGridXNew = rGridX + xDelta;
    local rGridYNew = rGridY + yDelta;
    -- See if the next rock is where the player is trying to move to.
    if rGridX == pGridXNew and rGridY == pGridYNew then
      -- See if where the rock will move to hits a wall.
      if levelPattern[rGridYNew][rGridXNew] == self.TILE_WALL then
        return false;
      end
      -- See if where the rock will move to hits any other rock.
      for j = 1, #rocks, 1 do
        if rGridXNew == rocks[j].gridX and rGridYNew == rocks[j].gridY then
          return false;
        end
      end
      -- Ok, the rock can move, take care of that now.
      audio.play(self.resMan:getSound("push"));
      rock.gridX = rGridXNew;
      rock.gridY = rGridYNew;
      rock.x = ((rock.gridX - 1) * rock.width) + self.xAdj;
      rock.y = ((rock.gridY - 1) * rock.height) + self.yAdj;
      -- Now, see if the rock is on a pad and give a few points if it is.
      if levelPattern[rGridYNew][rGridXNew] == self.TILE_DESTPAD then
        self.updateScore(self, 25);
      end
    end -- End found matching rock.
  end -- End iteration over rocks.

  -- All good, player can move.
  audio.play(self.resMan:getSound("move"));
  player.gridX = pGridXNew;
  player.gridY = pGridYNew;
  player.x = ((player.gridX - 1) * player.width) + self.xAdj;
  player.y = ((player.gridY - 1) * player.height) + self.yAdj;
  return true;

end -- End canPlayerMove().


---
-- Starts a new level.  Draws the board and positions the player and rocks.
--
-- @param inLevelNumber The level number to start.
--
function scene:startLevel(inLevelNumber)

  self.currentLevelPattern = inLevelNumber;

  local imageSheet = self.resMan:getImageSheet("imageSheet");
  local imageSheetInfo = self.resMan:getImageSheetInfo("imageSheet");

  -- Draw the board (cleaning up any old one first).
  for i = 1, #self.tiles, 1 do
    self.tiles[i]:removeSelf();
    self.tiles[i] = nil;
  end
  self.tiles = nil;
  self.tiles = { };
  local levelPattern = self.levelPatterns[self.currentLevelPattern];
  local levelMetaData = levelPattern[11];
  levelMetaData.destpads = { };
  levelMetaData.rocksStart = { };
  for y = 1, #levelPattern, 1 do
    local nextRow = levelPattern[y];
    for x = 1, #nextRow, 1 do
      local t;
      if nextRow[x] == self.TILE_WALL then
        t = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
          { name = "default", start = imageSheetInfo:getFrameIndex("wall"), count = 1, time = 9999 }
        });
      elseif nextRow[x] == self.TILE_DESTPAD then
        t = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
          { name = "default", start = imageSheetInfo:getFrameIndex("destpad"), count = 1, time = 9999 }
        });
        table.insert(levelMetaData.destpads, { x = x, y = y });
      elseif nextRow[x] == self.TILE_PLAYER then
        levelMetaData.playerStartX = x;
        levelMetaData.playerStartY = y;
      elseif nextRow[x] == self.TILE_ROCK then
        table.insert(levelMetaData.rocksStart, { x = x, y = y });
      end
      if t ~= nil then
        t.x = ((x - 1) * t.width) + self.xAdj;
        t.y = ((y - 1) * t.height) + self.yAdj;
        table.insert(self.tiles, t);
      end
    end
  end

  -- Draw rocks (cleaning up any old ones first).
  for i = 1, #self.rocks, 1 do
    self.rocks[i]:removeSelf();
    self.rocks[i] = nil;
  end
  self.rocks = { };
  for i = 1, #levelMetaData.rocksStart, 1 do
    local nextRock = levelPattern[11].rocksStart[i];
    local r = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
      { name = "default", start = imageSheetInfo:getFrameIndex("rock"), count = 1, time = 9999 }
    });
    r.gridX = nextRock.x;
    r.gridY = nextRock.y;
    r.x = ((r.gridX - 1) * r.width) + self.xAdj;
    r.y = ((r.gridY - 1) * r.height) + self.yAdj;
    self.rocks[i] = r;
  end

  -- Reset the player.
  local player = self.resMan:getSprite("player");
  player:toFront();
  player:setSequence("still");
  player.gridX = levelMetaData.playerStartX;
  player.gridY = levelMetaData.playerStartY;
  player.x = ((player.gridX - 1) * player.width) + self.xAdj;
  player.y = ((player.gridY - 1) * player.height) + self.yAdj;

end -- End startLevel().


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
