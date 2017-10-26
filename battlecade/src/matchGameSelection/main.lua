--utils:log("matchGameSelection", "Loaded");

local scene = composer.newScene();

scene.resMan = nil;

scene.isCycling = true;
scene.cyclingFrameSkip = 3;
scene.cyclingFrameCount = 0;
scene.frameCountUntilNextChoice = 30; -- One second between choices (change in enterFrame too if needed!).
scene.selectedGames = { };

scene.spriteSequences = { };


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

  --utils:log("matchGameSelection", "create()");

  self.resMan = utils:newResourceManager();

  for i = 1, #gameList do
    local gameName = gameList[i].internalName;
    scene.spriteSequences[i] = { name = gameName,
      start = screenshotsSheetInfo:getFrameIndex(gameName), count = 1, time = 9999
    };
  end

  local screenshot = self.resMan:newSprite("screenshot", self.view, screenshotsImageSheet, self.spriteSequences);
  screenshot.x = 140;
  screenshot.y = display.contentCenterY - 180;
  screenshot.lastIndexShown = 999;

  -- Back button.
  local btnBack = self.resMan:newSprite("btnBack", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnBack"), count = 1, time = 9999 }
  });
  btnBack.x = display.contentCenterX;
  btnBack.y = display.contentHeight - 100;

  -- Go button.
  local btnGo = self.resMan:newSprite("btnGo", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnGo"), count = 1, time = 9999 }
  });
  btnGo.x = display.contentCenterX;
  btnGo.y = display.contentHeight - 400;
  btnGo.alpha = 0.5

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  if inEvent.phase == "did" then

    --utils:log("matchGameSelection", "show(): did");

    if textTitle.isVisible == false then
      textTitle.isVisible = true;
      textTitle:startAnimation();
    end

    self.resMan:getSprite("btnBack"):addEventListener("touch",
      function(inEvent)
        self:btnBackTouchHandler(inEvent);
        return true;
      end
    );
    self.resMan:getSprite("btnGo"):addEventListener("touch",
      function(inEvent)
        self:btnGoTouchHandler(inEvent);
        return true;
      end
    );

    -- Attach listener for enterFrame event.
    Runtime:addEventListener("enterFrame", self);

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  if inEvent.phase == "did" then

    --utils:log("matchGameSelection", "hide(): did");

    -- Detach listener for enterFrame event.
    Runtime:removeEventListener("enterFrame", self);

  end

end -- End hide().


---
-- Handler for the destroy event.
--
-- @param inEvent The event object.
--
function scene:destroy(inEvent)

  --utils:log("matchGameSelection", "destroy()");

  self.resMan:destroyAll();

end -- End destroy().


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

  if self.isCycling == true then
    -- Skip some frames so it's not too fast.
    self.cyclingFrameCount = self.cyclingFrameCount + 1;
    if self.cyclingFrameCount == self.cyclingFrameSkip then
      self.cyclingFrameCount = 0;
      audio.play(uiScreenshotCycle);
      -- Choose the next screenshot to show.
      local nextImage = math.random(1, #gameList);
      local screenshot = self.resMan:getSprite("screenshot");
      -- If it's the same as the one just shown, choose a different one.  This keeps it looking smooth on screen.
      if screenshot.lastIndexShown == nextImage then
        nextImage = nextImage + 1;
        if nextImage > #gameList then
          nextImage = 1;
        end
      end
      -- Update the sequence.
      screenshot.lastIndexShown = nextImage;
      screenshot:setSequence(gameList[nextImage].internalName);
      screenshot:play();
    end
    -- Now see if it's time to choose a game.
    self.frameCountUntilNextChoice = self.frameCountUntilNextChoice - 1;
    if self.frameCountUntilNextChoice == 0 then
      self.frameCountUntilNextChoice = 30;
      audio.play(uiGameSelected);
      local screenshot = self.resMan:getSprite("screenshot");
      -- Keep randomly selecting a game until we get one that hasn't been chosen yet.
      local selectedGameIndex;
      local chooseGame = true;
      while chooseGame == true do
        selectedGameIndex = math.random(1, #gameList);
        if not utils:doesArrayContainValue(self.selectedGames, selectedGameIndex) then
          chooseGame = false;
          table.insert(self.selectedGames, selectedGameIndex);
        end
      end
      -- Create the screenshot for the game and start it moving.
      local nextScreenshot = self.resMan:newSprite(
        "nextScreenshot" .. #self.selectedGames, self.view, screenshotsImageSheet, self.spriteSequences
      );
      nextScreenshot:setSequence(gameList[selectedGameIndex].internalName);
      nextScreenshot.x = screenshot.x;
      nextScreenshot.y = screenshot.y;
      nextScreenshot:scale(0.5, 0.5);
      nextScreenshot.selectedGameIndex = selectedGameIndex;
      local targetX = 500;
      local targetY = 320 + (180 * #self.selectedGames);
      transition.to(nextScreenshot, { x = targetX, y = targetY, time = 500,
        onComplete = function(inNewScreenshot)
          -- When the image is in place, show it's name.
          self.resMan:newTextCandy("gameCaption" .. #self.selectedGames, {
            parentGroup = self.view, fontName = "fontInstructions", x = inNewScreenshot.x + 70, y = inNewScreenshot.y,
            text = gameList[inNewScreenshot.selectedGameIndex].caption, textFlow = "LEFT", originX = "LEFT"
          });
          -- If we've chosen the correct number of games for this round then we're done, player can begin.
          if #self.selectedGames == currentMatch.numGamesPerRound then
            self.isCycling = false;
            self.resMan:getSprite("screenshot").alpha = 0.5;
            self.resMan:getSprite("btnGo").alpha = 1.0;
          end
        end
      });
    end
  end

end -- End enterFrame().


--- ====================================================================================================================
--  ====================================================================================================================
--  Touch Handlers
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for touch events on the Go button.
--
-- @param inEvent The event object.
--
function scene:btnGoTouchHandler(inEvent)

  if inEvent.phase == "began" and inEvent.target.alpha == 1.0 then

    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);

  elseif (inEvent.phase == "ended" or inEvent.phase == "cancelled") and inEvent.target.alpha == 1.0 then

    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);

    -- Start the round.
    matchRoundGames = self.selectedGames;
    matchRoundGameIndex = 1;
    isPlayingMatchRound = true;
    matchRoundScore = 0;
    textTitle:stopAnimation();
    textTitle.isVisible = false;
    composer.gotoScene(
      "miniGames." .. gameList[matchRoundGames[1]].internalName .. ".main",
      SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME
    );

  end

end -- End btnGoTouchHandler().


---
-- Handler for touch events on the Back item.
--
-- @param inEvent The event object.
--
function scene:btnBackTouchHandler(inEvent)

  if inEvent.phase == "began" then
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);
  elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    composer.gotoScene("challengeLobby.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End btnBackTouchHandler().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("matchGameSelection", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
