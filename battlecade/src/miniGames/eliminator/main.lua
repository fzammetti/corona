local miniGameName = "eliminator";
local miniGamePath = "miniGames/eliminator/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Don't get peg on your face! Try to get down to just one peg." ..
  "||Tap a peg to lift it, then an empty space to put it there, always jumping over another peg.";


-- Graphics.
scene.boardImages = {
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
  { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, }
};

-- Variables we need.
scene.raisedPeg = { x = nil, y = nil };
scene.tBlank = 0;
scene.tEmpty = 1;
scene.tFilled = 2;
scene.currentBoard = 0;

-- Board maps.
scene.boardMaps = {
  {
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    { 2, 2, 2, 2, 2, 1, 2, 2, 2, 2 },
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 }
  },
  {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 2, 2, 0, 0, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 2, 2, 2, 2, 2, 2, 0, 0 },
    { 0, 2, 2, 2, 2, 1, 2, 2, 2, 0 },
    { 0, 2, 2, 2, 2, 2, 2, 2, 2, 0 },
    { 0, 0, 2, 2, 2, 2, 2, 2, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 0, 0, 2, 2, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  },
  {
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 0, 0, 0, 0, 2, 2, 2 },
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    { 1, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
    { 1, 1, 2, 2, 2, 2, 2, 2, 1, 1 }
  },
  {
    { 2, 0, 0, 0, 0, 0, 0, 0, 0, 2 },
    { 2, 2, 0, 0, 0, 0, 0, 0, 2, 2 },
    { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    { 0, 2, 0, 2, 0, 0, 2, 0, 2, 0 },
    { 0, 2, 0, 2, 1, 1, 2, 0, 2, 0 },
    { 0, 2, 0, 0, 2, 2, 0, 0, 2, 0 },
    { 0, 2, 0, 1, 1, 1, 1, 0, 2, 0 },
    { 0, 0, 2, 0, 0, 0, 0, 2, 0, 0 },
    { 0, 0, 0, 2, 2, 2, 2, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
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

  -- Draw the pegs.
  for y = 1, 10, 1 do
    for x = 1, 10, 1 do
      local s = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
        { name = "blank", start = sheetInfo:getFrameIndex("blank"), count = 1, time = 9999 },
        { name = "down", start = sheetInfo:getFrameIndex("down"), count = 1, time = 9999 },
        { name = "empty", start = sheetInfo:getFrameIndex("empty"), count = 1, time = 9999 },
        { name = "up", start = sheetInfo:getFrameIndex("up"), count = 1, time = 9999 }
      });
      s.x = ((x - 1) * s.width) + (s.width / 2);
      s.y = ((y - 1) * s.height) + 500;
      s.gridX = x;
      s.gridY = y;
      s:setSequence("blank");
      s:play();
      self.boardImages[y][x] = s;
    end
  end

  -- Reset the board to show it's current state.
  self:setNewLevel();

  -- Load sounds.
  self.resMan:loadSound("up", self.sharedResourcePath .. "windup.wav");
  self.resMan:loadSound("remove", self.sharedResourcePath .. "drip.wav");
  self.resMan:loadSound("win", self.sharedResourcePath .. "fanfare.wav");
  self.resMan:loadSound("lose", self.sharedResourcePath .. "buzzer.wav");

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

    for y = 1, 10, 1 do
      for x = 1, 10, 1 do
        self.boardImages[y][x]:addEventListener("touch", function(inEvent) self:pegTouchHandler(inEvent); end );
      end
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

  -- Destroy graphics.

  for y = 1, 10, 1 do
    for x = 1, 10, 1 do
      self.boardImages[y][x]:removeSelf();
      self.boardImages[y][x] = nil;
    end
    self.boardImages[y] = nil;
  end
  self.boardImages = nil;

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
end -- End touch().


---
-- Handles touches on a peg.
--
-- @param inEvent The event object.
--
function scene:pegTouchHandler(inEvent)

  if inEvent.phase == "ended" then

    -- Get a reference to the selected peg.
    local peg = inEvent.target;

    -- If it's an empty peg then deal with putting a raised peg down if one is currently up.
    if peg.sequence == "empty" and self.raisedPeg.x ~= nil then
      local removedPeg = self:isMoveValid({ x = peg.gridX, y = peg.gridY});
      if removedPeg.x ~= nil then
        audio.play(self.resMan:getSound("remove"));
        self.updateScore(self, 2);
        -- Empty the peg in the middle.
        self.boardImages[removedPeg.y][removedPeg.x]:setSequence("empty");
        -- Empty the peg that was moved.
        self.boardImages[self.raisedPeg.y][self.raisedPeg.x]:setSequence("empty");
        -- Put the peg in the new location.
        self.boardImages[peg.gridY][peg.gridX]:setSequence("down");
        -- Make sure there's no peg raised now.
        self.raisedPeg = { x = nil, y = nil };
        -- See if there's any moves left to make.
        local cmm = self:checkMoreMoves();
        -- If there are no moves left that can be made...
        if cmm.movesLeft == false then
          -- One piece left is a win.
          if cmm.piecesLeft == 1 then
            audio.play(self.resMan:getSound("win"));
            self.updateScore(self, 100);
            self:setNewLevel();
          -- More than one piece left is a loss.
          else
            audio.play(self.resMan:getSound("lose"));
            self:setNewLevel();
          end
        end
      else
        -- Peg going down but no peg to be removed.
        audio.play(self.resMan:getSound("up"));
      end
      return;
    end

    -- Now, raise or lower the selected peg as appropriate and record it as raised if it now is.
    if peg.sequence == "down" then
      audio.play(self.resMan:getSound("up"));
      if self.raisedPeg.x ~= nil then
        self.boardImages[self.raisedPeg.y][self.raisedPeg.x]:setSequence("down");
        self.raisedPeg = { x = nil, y = nil };
      end
      peg:setSequence("up");
      self.raisedPeg = { x = peg.gridX, y = peg.gridY };
      return;
    end

    -- It's the raised peg, so put it down.
    if peg.sequence == "up" then
      audio.play(self.resMan:getSound("up"));
      peg:setSequence("down");
      self.raisedPeg = { x = nil, y = nil };
    end

  end -- End ended event.

end -- End pegTouchHandler().


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
-- Redraws the board for a new level and sets everything up for it.
--
function scene:setNewLevel()

  -- Start with no raised peg.
  self.raisedPeg = { x = nil, y = nil };

  -- Cycle to the next board.
  self.currentBoard = self.currentBoard + 1;
  if self.currentBoard > 3 then
    self.currentBoard = 1;
  end

  -- Set peg states.
  for y = 1, 10, 1 do
    for x = 1, 10, 1 do
      local peg = self.boardImages[y][x];
      if self.boardMaps[self.currentBoard][y][x] == self.tBlank then
        peg:setSequence("blank");
      elseif self.boardMaps[self.currentBoard][y][x] == self.tEmpty then
        peg:setSequence("empty");
      elseif self.boardMaps[self.currentBoard][y][x] == self.tFilled then
        peg:setSequence("down");
      end
    end
  end

end -- End setNewLevel().


---
-- Determines if a move is valid.
--
-- @param  inNewXY The new X/Y coordinate of the peg.
-- @return         An object with an x and y attribute of the middle peg that should be removed.  Both will be nil if
--                 the move isn't valid.
--
function scene:isMoveValid(inNewXY)

  local middleXY = { x = nil, y = nil };
  if inNewXY.y == (self.raisedPeg.y - 2) and inNewXY.x == (self.raisedPeg.x) and
    self.boardImages[self.raisedPeg.y - 1][self.raisedPeg.x].sequence == "down" then
    middleXY.x = self.raisedPeg.x;
    middleXY.y = self.raisedPeg.y - 1;
  elseif inNewXY.y == (self.raisedPeg.y + 2) and inNewXY.x == (self.raisedPeg.x) and
    self.boardImages[self.raisedPeg.y + 1][self.raisedPeg.x].sequence == "down" then
    middleXY.x = self.raisedPeg.x;
    middleXY.y = self.raisedPeg.y + 1;
  elseif inNewXY.y == (self.raisedPeg.y) and inNewXY.x == (self.raisedPeg.x - 2) and
    self.boardImages[self.raisedPeg.y][self.raisedPeg.x - 1].sequence == "down" then
    middleXY.x = self.raisedPeg.x - 1;
    middleXY.y = self.raisedPeg.y;
  elseif inNewXY.y == (self.raisedPeg.y) and inNewXY.x == (self.raisedPeg.x + 2) and
    self.boardImages[self.raisedPeg.y][self.raisedPeg.x + 1].sequence == "down" then
    middleXY.x = self.raisedPeg.x + 1;
    middleXY.y = self.raisedPeg.y;
  elseif inNewXY.y == (self.raisedPeg.y - 2) and inNewXY.x == (self.raisedPeg.x - 2) and
    self.boardImages[self.raisedPeg.y - 1][self.raisedPeg.x - 1].sequence == "down" then
    middleXY.x = self.raisedPeg.x - 1;
    middleXY.y = self.raisedPeg.y - 1;
  elseif inNewXY.y == (self.raisedPeg.y - 2) and inNewXY.x == (self.raisedPeg.x + 2) and
    self.boardImages[self.raisedPeg.y - 1][self.raisedPeg.x + 1].sequence == "down" then
    middleXY.x = self.raisedPeg.x + 1;
    middleXY.y = self.raisedPeg.y - 1;
  elseif inNewXY.y == (self.raisedPeg.y + 2) and inNewXY.x == (self.raisedPeg.x - 2) and
    self.boardImages[self.raisedPeg.y + 1][self.raisedPeg.x - 1].sequence == "down" then
    middleXY.x = self.raisedPeg.x - 1;
    middleXY.y = self.raisedPeg.y + 1;
  elseif inNewXY.y == (self.raisedPeg.y + 2) and inNewXY.x == (self.raisedPeg.x + 2) and
    self.boardImages[self.raisedPeg.y + 1][self.raisedPeg.x + 1].sequence == "down" then
    middleXY.x = self.raisedPeg.x + 1;
    middleXY.y = self.raisedPeg.y + 1;
  end

  return middleXY;

end -- End isMoveValid().


---
-- See if there's any moves left to make
--
-- @return An object with two properties: movesLeft and piecesLeft.
--
function scene:checkMoreMoves()

  local piecesLeft = 0;
  local movesLeft = false;
  -- Count number of pieces left.
  for y = 1, 10, 1 do
    for x = 1, 10, 1 do
      if self.boardImages[y][x].sequence == "down" then
        piecesLeft = piecesLeft + 1;
      end
    end
  end
  -- Look for valid moves.
  for y = 2, 9, 1 do
    for x = 2, 9, 1 do
      if self.boardImages[y][x].sequence == "down" then
        if
          (self.boardImages[y + 1][x + 0].sequence == "down" and self.boardImages[y - 1][x - 0].sequence == "empty") or
          (self.boardImages[y - 1][x + 0].sequence == "down" and self.boardImages[y + 1][x - 0].sequence == "empty") or
          (self.boardImages[y + 0][x + 1].sequence == "down" and self.boardImages[y - 0][x - 1].sequence == "empty") or
          (self.boardImages[y + 0][x - 1].sequence == "down" and self.boardImages[y - 0][x + 1].sequence == "empty") or
          (self.boardImages[y + 1][x - 1].sequence == "down" and self.boardImages[y - 1][x + 1].sequence == "empty") or
          (self.boardImages[y - 1][x + 1].sequence == "down" and self.boardImages[y + 1][x - 1].sequence == "empty") or
          (self.boardImages[y + 1][x + 1].sequence == "down" and self.boardImages[y - 1][x - 1].sequence == "empty") or
          (self.boardImages[y - 1][x - 1].sequence == "down" and self.boardImages[y + 1][x + 1].sequence == "empty")
        then
          movesLeft = true;
        end
      end
    end
  end

  return { movesLeft = movesLeft, piecesLeft = piecesLeft };

end -- End checkMoreMoves().


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
