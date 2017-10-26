local scene = storyboard.newScene();
local startOver;
local back;
local numStarsStar;
local numStarsText;
local numTexts = { };


-- ============================================================================
-- Called when the scene's view does not exist.
-- ============================================================================
function scene:createScene(inEvent)

  utils:log("levelSelectionScene", "createScene()");

  local group = self.view;

  -- The width and height of the icons.
  local w = 56;
  local h = 60;

  -- The horizontal and vertical pixels between icons.
  local horizSep = 24;
  local vertSep = 50;

  -- Number of columns and rows to render.  Note that there has to be an even
  -- number of levels and it has to be evenly divisible by numCols or this
  -- will probably not work right.
  local numCols = 10;
  local numRows = numLevels / numCols;

  -- X and Y location a row starts at.
  local xStart = (800 - ((numCols * w) + ((numCols - 1) * horizSep))) / 2;
  local yStart = (480 - ((numRows * h) + ((numRows - 1) * vertSep))) / 2;

  -- Render the level icons.
  local x = xStart;
  local y = yStart;
  local rowBreak = 0;
  local numStarsDone = 0;

  for i = 1, numLevels, 1 do

    numStarsDone = numStarsDone + gameState.levelStars[i];

    -- Create level icon.
    local level = display.newRoundedRect(x, y, w, h, 15);
    level:setFillColor(165, 42, 42)
    level.targetID = "level_" .. i;
    level:setReferencePoint(display.TopLeftReferencePoint);
    level.x = x;
    level.y = y;
    group:insert(level);

    -- Now the level number on it.
    local numText = textCandy.CreateText({
      fontName = "fontSmallSilver", x = x + 29, y = y + 22;
      text = i, originX = "center", originY = "center",
      textFlow = "center", charSpacing = 0, lineSpacing = 0,
      showOrigin = false, color = { 255, 255, 255, 255 }
    });
    numTexts[i] = numText;
    group:insert(numText);

    -- Now the stars for the level.
    local star;
    if gameState.levelStars[i] >= 1 then
      star = display.newImage("levelSelection_starOn.png", true);
    else
      star = display.newImage("levelSelection_starOff.png", true);
    end
    star:setReferencePoint(display.TopLeftReferencePoint);
    star.x = x + 2;
    star.y = y + 35;
    group:insert(star);
    if gameState.levelStars[i] >= 2 then
      star = display.newImage("levelSelection_starOn.png", true);
    else
      star = display.newImage("levelSelection_starOff.png", true);
    end
    star:setReferencePoint(display.TopLeftReferencePoint);
    star.x = x + 20;
    star.y = y + 35;
    group:insert(star);
    if gameState.levelStars[i] == 3 then
      star = display.newImage("levelSelection_starOn.png", true);
    else
      star = display.newImage("levelSelection_starOff.png", true);
    end
    star:setReferencePoint(display.TopLeftReferencePoint);
    star.x = x + 38;
    star.y = y + 35;
    group:insert(star);

    -- Create lock icon if applicable, or hook up event handler.
    if gameState.levelLocks[i] == true and allLevelsUnlocked == false then
      local lock = display.newImage("levelSelection_lock.png", true);
      lock:setReferencePoint(display.TopLeftReferencePoint);
      lock.x = x + 8;
      lock.y = y + 3;
      group:insert(lock);
    else
      level:addEventListener("touch", scene);
    end

    -- Update X/Y locations.
    x = x + w + horizSep;
    rowBreak = rowBreak + 1;
    if rowBreak >= numCols then
      y = y + h + vertSep;
      x = xStart;
      rowBreak = 0;
    end

  end -- End level iteration.

  -- Back button.
  back = textCandy.CreateText({
    fontName = "fontMediumSilver", x = 4, y = 5;
    text = "BACK", originX = "left", originY = "top",
    textFlow = "center", charSpacing = -2, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  back.targetID = "back";
  back:addEventListener("touch",
    function(inEvent)
      scene:backListener(inEvent);
      return true;
    end
  );
  group:insert(back);

  -- Number of stars done.
  numStarsStar = display.newImage("levelSelection_starOn.png", true);
  numStarsStar.xScale = 2;
  numStarsStar.yScale = 2;
  numStarsStar.x = 686;
  numStarsStar.y = 28;
  group:insert(numStarsStar);
  local numStarsTxt = "";
  if numStarsDone < 10 then
    numStarsTxt = "0";
  end
  numStarsTxt = numStarsTxt .. numStarsDone .. "/90";
  numStarsText = textCandy.CreateText({
    fontName = "fontSmallSilver", x = 712, y = 17;
    text = numStarsTxt, originX = "left", originY = "top",
    textFlow = "center", charSpacing = -2, lineSpacing = 0,
    showOrigin = false
  });
  group:insert(numStarsText);

  -- Start Over button.
  startOver = textCandy.CreateText({
    fontName = "fontMediumSilver",
    x = display.contentWidth / 2, y = display.contentHeight - 26;
    text = "START OVER", originX = "center", originY = "center",
    textFlow = "center", charSpacing = -2, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  startOver.targetID = "startOver";
  startOver:addEventListener("touch",
    function(inEvent)
      scene:startOverListener(inEvent);
      return true;
    end
  );
  group:insert(startOver);

end -- End createScene().


-- ============================================================================
-- Called immediately after scene has moved onscreen.
-- ============================================================================
function scene:enterScene(inEvent)

  utils:log("levelSelectionScene", "enterScene()");

end -- End enterScene().


-- ============================================================================
-- Called when scene is about to move off screen.
-- ============================================================================
function scene:exitScene(inEvent)

  utils:log("levelSelectionScene", "exitScene()");

end -- End exitScene().


-- ============================================================================
-- Called prior to the removal of scene's "view" (display group)
-- ============================================================================
function scene:destroyScene(inEvent)

  utils:log("levelSelectionScene", "destroyScene()");

  -- This will only happen when removeAll() in gameScene or introScene
  -- is called.
  for i = 1, numLevels, 1 do
    if numTexts[i] ~= nil then
      textCandy.DeleteText(numTexts[i]);
      numTexts[i] = nil;
    end
  end
  if back ~= nil then
    textCandy.DeleteText(back);
    back = nil;
  end
  if numStarsText ~= nil then
    textCandy.DeleteText(numStarsText);
    back = numStarsText;
  end
  if startOver ~= nil then
    textCandy.DeleteText(startOver);
    startOver = nil;
  end

end -- End destroyScene().


-- ============================================================================
-- Touch listener for Back.
--
-- @param inEvent The touch event.
-- ============================================================================
function scene:backListener(inEvent)

  if confirmPopupShowing == true then
    return;
  end

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    storyboard.gotoScene("titleScene", sceneTransitionEffect, 500);
  end

end -- End backListener().



-- ============================================================================
-- Touch listener for Start Over.
--
-- @param inEvent The touch event.
-- ============================================================================
function scene:startOverListener(inEvent)

  if confirmPopupShowing == true then
    return;
  end

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    -- Show confirmation message box.
    audio.play(sfx.menuBeep);
    showConfirmPopup(self.view,
      "ALL PROGRESS WILL BE LOST!|||ARE YOU SURE YOU WANT TO START OVER?",
      function()
        audio.play(sfx.levelSelection);
        utils:xpcall("levelSelectionScene.lua:Calling newGame()", newGame);
        utils:xpcall(
          "levelSelectionScene.lua:Calling launchGame()", launchGame
        );
      end,
      function()
      end
    );
  end

end -- End startOverListener().


-- ============================================================================
-- Handle touch events.
-- ============================================================================
function scene:touch(inEvent)

  --utils:log("levelSelectionScene", "touch()");

  if inEvent.phase == "began" then

    -- Take what level they selected to start at and make that our
    -- current level.
    audio.play(sfx.levelSelection);
    gameState.currentLevel = tonumber(
      utils:split(inEvent.target.targetID, "_")[2]
    );
    utils:xpcall("levelSelectionScene.lua:Calling launchGame()", launchGame);

  end

  return true;

end -- End touch().


-- ============================================================================
-- Called to launch the game scene.  Separated out so common code doesn't need
-- to be repeated.
-- ============================================================================
function launchGame()

  utils:log("levelSelectionScene", "launchGame()");

  if gameState.introDone == true then
    -- Intro has been seen already, so go to the game.
    storyboard.gotoScene("gameScene", sceneTransitionEffect, 500);
  else
    -- Intro hasn't been seen yet, so show it now.
    storyboard.gotoScene("introScene", sceneTransitionEffect, 500);
  end

end -- End launchGame().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("levelSelectionScene", "Beginning execution");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;
