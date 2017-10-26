local miniGameName = "virus";
local miniGamePath = "miniGames/virus/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Virus? Why Virus? Well, so that it wasn't gems or candy!" ..
  "||Tap symbols to remove adjacent similar symbols, making as large a groups as possible at once.";


-- Amount to shift all elements right and down to center on screen.
scene.xAdj = 50;
scene.yAdj = 360;

-- Game data.
scene.symbols = { };


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

  for i = 1, #self.symbols, 1 do
    self.symbols[i]:removeSelf();
    self.symbols[i] = nil;
  end
  self.symbols = { { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { } };

  -- Now do the creations and fill up the field.
  for y = 1, 14, 1 do
    for x = 1, 11, 1 do
      local s = display.newSprite(self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
        { name = "empty", start = sheetInfo:getFrameIndex("symbol_empty"), count = 1, time = 9999 },
        { name = "symbol_1", start = sheetInfo:getFrameIndex("symbol_1"), count = 1, time = 9999 },
        { name = "symbol_2", start = sheetInfo:getFrameIndex("symbol_2"), count = 1, time = 9999 },
        { name = "symbol_3", start = sheetInfo:getFrameIndex("symbol_3"), count = 1, time = 9999 }
      });
      s.gridX = x;
      s.gridY = y;
      s.gridX = x;
      s.gridY = y;
      s.x = ((x - 1) * s.width) + self.xAdj;
      s.y = ((y - 1) * s.width) + self.yAdj;
      table.insert(self.symbols[y], s);
    end
  end

  self:randomizeSymbols();

  -- Load sounds.

  self.resMan:loadSound("clear", self.sharedResourcePath .. "pop2.wav");
  self.resMan:loadSound("win", self.sharedResourcePath .. "harp.wav");
  self.resMan:loadSound("resetSound", self.sharedResourcePath .. "buzzer.wav");

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

    for y = 1, 14, 1 do
      for x = 1, 11, 1 do
        self.symbols[y][x]:addEventListener("touch", function(inEvent) self:symbolTouchHandler(inEvent); end );
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

  for y = 1, 14, 1 do
    for x = 1, 11, 1 do
      self.symbols[y][x]:removeSelf();
      self.symbols[y][x] = nil;
    end
    self.symbols[y] = nil;
  end
  self.symbols = nil;

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
-- Handles touches on a symbol.
--
-- @param inEvent The event object.
--
function scene:symbolTouchHandler(inEvent)

  if inEvent.phase == "ended" then

    -- Get a reference to the selected symbol.
    local symbol = inEvent.target;

    -- Count of how many mathches there are.
    local numMatches = 1;

    -- Record the sequence of the tapped symbol and empty it.  This is necessary or the check logic below won't work.
    local origSeq = symbol.sequence;
    symbol:setSequence("empty");

    -- Now check the rest of the symbols.
    local keepGoing = true;
    local symbolGrid = self.symbols;

    local s1;

    while keepGoing do

      -- Assume no more matches.
      keepGoing = false;

      -- Check every symbol in the grid.
      for y = 1, 14, 1 do
        for x = 1, 11, 1 do

          -- Get a reference to the next symbol to check.
          local s = symbolGrid[y][x];

          -- If it's of the appropriate type and IS NOT empty...
          if s.symbolType == symbol.symbolType and s.sequence ~= "empty" then

            -- See if the symbol to the left, if any, is the same type and IS empty.
            if x > 1 then
              s1 = symbolGrid[y][x - 1];
              if s1.symbolType == symbol.symbolType and s1.sequence == "empty" then
                keepGoing = true;
                s:setSequence("empty");
                numMatches = numMatches + 1;
              end
            end
            -- See if the symbol to the right, if any, is the same type and IS empty.
            if x < 11 then
              s1 = symbolGrid[y][x + 1];
              if s1.symbolType == symbol.symbolType and s1.sequence == "empty" then
                keepGoing = true;
                s:setSequence("empty");
                numMatches = numMatches + 1;
              end
            end
            -- See if the symbol above, if any, is the same type and IS empty.
            if y > 1 then
              s1 = symbolGrid[y - 1][x];
              if s1.symbolType == symbol.symbolType and s1.sequence == "empty" then
                keepGoing = true;
                s:setSequence("empty");
                numMatches = numMatches + 1;
              end
            end
            -- See if the symbol below, if any, is the same type and IS empty.
            if y < 14 then
              s1 = symbolGrid[y + 1][x];
              if s1.symbolType == symbol.symbolType and s1.sequence == "empty" then
                keepGoing = true;
                s:setSequence("empty");
                numMatches = numMatches + 1;
              end
            end

          end -- End check s.

        end -- End x loop.
      end -- End y loop.

    end -- End do loop.

    -- If there's only one match then it wasn't actually a valid move, so abort.  Otherwise, hide the tapped symbol
    -- and continue on.
    if numMatches == 1 then
      -- Restore the tapped symbol to it's original sequence (remember that it had to be empty or the above check
      -- logic wouldn't work, but we of course don't want it empty now).
      symbol:setSequence(origSeq);
      return;
    end
    symbol:setSequence("empty");
    self.updateScore(self, numMatches * 2);
    audio.play(self.resMan:getSound("clear"));

    -- Shift columns downward to fill in blanks.  We do this by creating two arrays, an empty array and a visible
    -- array.  After creating them, we'll empty the symbols on the top of the column according to the contents of
    -- the blank array, then fill the bottom from the visible array.
    local emptyArray;
    local visibleArray;
    for x = 1, 11, 1 do
      emptyArray = { };
      visibleArray = { };
      for y = 1, 14, 1 do
        local s = symbolGrid[y][x];
        if s.sequence == "empty" then
          table.insert(emptyArray, s.symbolType);
        else
          table.insert(visibleArray, s.symbolType);
        end
      end
      local emptyCount = #emptyArray;
      for y1 = 1, emptyCount, 1 do
        symbolGrid[y1][x].symbolType = "#";
        symbolGrid[y1][x]:setSequence("empty");
      end
      for y2 = 1, #visibleArray, 1 do
        symbolGrid[emptyCount + y2][x].symbolType = visibleArray[y2];
        symbolGrid[emptyCount + y2][x]:setSequence("symbol_" .. visibleArray[y2]);
      end
    end

    -- Now shift columns left to fill in empty columns.  Do this by first going through each column and copying any
    -- non-empty columns to a temp array, then setting symbolType and sequence on all elements in symbolGrid according
    -- to what's in the temp array.  tempGrid is an array of arrays where each sub-array is a column
    local tempGrid = {
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" },
      { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" }
    };
    local tempGridColCount = 0;
    for col = 1, 11, 1 do
      local emptyCount = 0;
      local thisCol = { "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#" };
      for row = 1, 14, 1 do
        thisCol[row] = symbolGrid[row][col].symbolType;
        if symbolGrid[row][col].sequence == "empty" then
          emptyCount = emptyCount + 1;
        end
      end
      if emptyCount ~= 14 then
        tempGridColCount = tempGridColCount + 1;
        tempGrid[tempGridColCount] = thisCol;
      end
    end
    -- Now, set types according to tempGrid.
    for col = 1, 11, 1 do
      local thisCol = tempGrid[col];
      for row = 1, 14, 1 do
        local symbolType = thisCol[row];
        symbolGrid[row][col].symbolType = symbolType;
        if symbolType == "#" then
          symbolGrid[row][col]:setSequence("empty");
        else
          symbolGrid[row][col]:setSequence("symbol_" .. symbolType);
        end
      end
    end

    -- Now, see if there's any moves left and reset the board if not.  This just means going through each non-empty
    -- symbol and see if there's a match in any of the four possible directions.
    local noMatch = true;
    local numEmpty = 0;
    for x = 1, 11, 1 do
      for y = 1, 14, 1 do
        local symbolType = symbolGrid[y][x].symbolType;
        if symbolType ~= "#" then
          if x > 1 then
            if symbolGrid[y][x - 1].symbolType == symbolType then
              noMatch = false;
            end
          end
          if x < 11 then
            if symbolGrid[y][x + 1].symbolType == symbolType then
              noMatch = false;
            end
          end
          if y > 1 then
            if symbolGrid[y - 1][x].symbolType == symbolType then
              noMatch = false;
            end
          end
          if y < 14 then
            if symbolGrid[y + 1][x].symbolType == symbolType then
              noMatch = false;
            end
          end
        else
          numEmpty = numEmpty + 1;
        end
      end
    end
    if noMatch == true then
      if numEmpty == (11 * 14) then
        self.updateScore(self, 20);
        audio.play(self.resMan:getSound("win"));
      else
        self.updateScore(self, -500);
      end
      audio.play(self.resMan:getSound("resetSound"));
      self:randomizeSymbols();
    end

  end -- End ended event.

end -- End symbolTouchHandler().


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
-- Randomize the field of symbols when the game starts or restarts.
--
function scene:randomizeSymbols()

  for y = 1, 14, 1 do
    for x = 1, 11, 1 do
      local s = self.symbols[y][x];
      s.symbolType = math.random(1, 3);
      s:setSequence("symbol_" .. s.symbolType);
    end
  end

end -- End randomizeSymbols().


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
