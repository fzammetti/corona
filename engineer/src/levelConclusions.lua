local levelConclusionFadeRect;
local levelConclusionText;
local levelConclusionExit;
local levelConclusionNext;
local levelConclusionRetry;
local star1;
local star2;
local star3;


-- ============================================================================
-- Called when the current level is successfully completed.
-- ============================================================================
function levelComplete()

  utils:log("levelConclusions", "levelComplete()");

  -- Stop all activity on the level and clean up a bit.
  stopLevelActivity(MODE_LEVEL_COMPLETE);

  -- Figure out how many stars they get.  They'll always get at least one.
  local numStars = calcStars();

  -- Is the game over? If so, should we show the game conclusion scene?
  if gameState.currentLevel == 30 and gameState.conclusionDone == false then
    currentMode = MODE_GAME_FINISHED;
    --utils:log("levelConclusions", "Game won! Going to conclusion scene.");
    gameState.levelStars[gameState.currentLevel] = numStars;
    gameState.conclusionDone = true;
    utils:xpcall("levelConclusions.lua:Calling saveState()", saveState);
    storyboard.gotoScene("conclusionScene", sceneTransitionEffect, 500);
    return;
  end

  --utils:log("levelConclusions", "Game NOT won, so no conclusion scene.");

  -- Fade rect.
  levelConclusionFadeRect = display.newRect(
    0, 0, display.contentWidth, display.contentHeight
  );
  levelConclusionFadeRect:setReferencePoint(display.TopLeftReferencePoint);
  levelConclusionFadeRect:setFillColor(0, 0, 0);
  levelConclusionFadeRect.alpha = 0;
  transition.to(levelConclusionFadeRect, { alpha = .8, time = 1000 });

  if numStars == 3 then
    star1 = display.newImage("levelConclusion_star.png", true);
    star1.x = (display.contentWidth / 2) - 150;
    star1.y = display.contentHeight - 45;
    star2 = display.newImage("levelConclusion_star.png", true);
    star2.x = display.contentWidth / 2;
    star2.y = display.contentHeight - 45;
    star3 = display.newImage("levelConclusion_star.png", true);
    star3.x = (display.contentWidth / 2) + 150;
    star3.y = display.contentHeight - 45;
  elseif numStars == 2 then
    star1 = display.newImage("levelConclusion_star.png", true);
    star1.x = (display.contentWidth / 2) - 75;
    star1.y = display.contentHeight - 45;
    star2 = display.newImage("levelConclusion_star.png", true);
    star2.x = (display.contentWidth / 2 + 75);
    star2.y = display.contentHeight - 45;
  else
    star1 = display.newImage("levelConclusion_star.png", true);
    star1.x = display.contentWidth / 2;
    star1.y = display.contentHeight - 45;
  end

  -- Transition stars into view.
  star1.xScale = .1;
  star1.yScale = .1;
  transition.to(star1, {
    time = 250, xScale = 4, yScale = 4,
    onComplete = function()
      transition.to(star1, {
        time = 750, xScale = 1, yScale = 1,
        transition = easingX.easeOut
      });
    end
  });
  if numStars == 2 or numStars == 3 then
    star2.xScale = .1;
    star2.yScale = .1;
    transition.to(star2, {
      time = 250, xScale = 4, yScale = 4,
      onComplete = function()
        transition.to(star2, {
          time = 750, xScale = 1, yScale = 1,
          transition = easingX.easeOut
        });
      end
    });
  end
  if numStars ==3 then
    star3.xScale = .1;
    star3.yScale = .1;
    transition.to(star3, {
      time = 250, xScale = 4, yScale = 4,
      onComplete = function()
        transition.to(star3, {
          time = 750, xScale = 1, yScale = 1,
          transition = easingX.easeOut
        });
      end
    });
  end

  -- Animated text.
  levelConclusionText = textCandy.CreateText({
    fontName = "fontLED",
    x = display.contentWidth / 2,
    y = (display.contentHeight / 2) - 40,
    text = "YOU DID IT! GREAT JOB! ",
    originX = "center", originY = "center", textFlow = "center",
    charSpacing = 40, lineSpacing = 0, showOrigin = false
  });
  levelConclusionText:applyDeform({
    type = textCandy.DEFORM_CIRCLE, radius = 160,
    autoStep = true, ignoreSpaces = false
  });
  levelConclusionText:applyInOutTransition({
    hideCharsBefore = true, hideCharsAfter = true,
    startNow = true, loop = false, autoRemoveText = false,
    restartOnChange = true, inDelay = 0, inCharDelay = 40,
    inMode = "LEFT_RIGHT",
    AnimateFrom = {
      xScale = 0.01, yScale = 0.01, time = 1000, transition = easing.outQuad
    }
  });

  -- Exit button.
  levelConclusionExit = textCandy.CreateText({
    fontName = "fontMediumSilver", x = 5, y = 5;
    text = "EXIT", originX = "left", originY = "top",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  levelConclusionExit:addEventListener("touch",
    function(inEvent)
      levelConclusionExitListener(inEvent);
      return true;
    end
  );

  -- Next button.
  if gameState.currentLevel == 30 and gameState.conclusionDone == true then
    -- Don't render Next button when we're on level 30 and game was
    -- fully completed already.
  else
    levelConclusionNext = textCandy.CreateText({
      fontName = "fontMediumSilver", x = display.contentWidth - 134, y = 5,
      text = "NEXT", originX = "left", originY = "top",
      textFlow = "center", charSpacing = 0, lineSpacing = 0,
      showOrigin = false, color = { 255, 255, 255, 255 }
    });
    levelConclusionNext:addEventListener("touch",
      function(inEvent)
        levelConclusionNextListener(inEvent);
        return true;
      end
    );
  end

  -- Level completed sound.
  sfx.levelCompletedChannel = audio.play(sfx.levelCompleted);

  -- Bump up current level, unlocking it, and persist updated state.
  --utils:log("levelConclusions", "Elements drawn, updating state");
  gameState.levelStars[gameState.currentLevel] = numStars;
  gameState.currentLevel = gameState.currentLevel + 1;
  gameState.levelLocks[gameState.currentLevel] = false;
  utils:xpcall("levelConclusions.lua:Calling saveState()", saveState);

end -- End levelComplete().


-- ============================================================================
-- Figure out how many stars the player gets for completing a level.
--
-- @return The number of stars they get.
-- ============================================================================
function calcStars()

  utils:log("levelConclusions", "calcStars()");

  -- Figure out how many stars they get.  They'll always get at least one.
  local numPortExplosionsWeight = currentLevel.levelDef.numPortExplosionsWeight;
  local numPortExplosionsWeighted =
    currentLevel.numPortExplosions * numPortExplosionsWeight;
  local numDiverterExplosionsWeight =
    currentLevel.levelDef.numDiverterExplosionsWeight;
  local numDiverterExplosionsWeighted =
    currentLevel.numDiverterExplosions * numDiverterExplosionsWeight;
  local numAntimatterExplosionsWeight =
    currentLevel.levelDef.numAntimatterExplosionsWeight;
  local numAntimatterExplosionsWeighted =
    currentLevel.numAntimatterExplosions * numAntimatterExplosionsWeight;
  local numParticlesInSinkWeight =
    currentLevel.levelDef.numParticlesInSinkWeight;
  local numParticlesInSinkWeighted =
    currentLevel.numParticlesInSink * numParticlesInSinkWeight;
  local numParticlesInPrisonWeight =
    currentLevel.levelDef.numParticlesInPrisonWeight;
  local numParticlesInPrisonWeighted =
    currentLevel.numParticlesInPrison * numParticlesInPrisonWeight;
  local finalWeight =
    numPortExplosionsWeighted + numDiverterExplosionsWeighted +
    numAntimatterExplosionsWeighted + numParticlesInSinkWeighted +
    numParticlesInPrisonWeighted;
  local weightBreakForTwoStars = currentLevel.levelDef.weightBreakForTwoStars;
  local weightBreakForThreeStars =
    currentLevel.levelDef.weightBreakForThreeStars;
  local numStars = 1;
  if finalWeight < weightBreakForTwoStars then
    numStars = 3;
  elseif finalWeight < weightBreakForThreeStars then
    numStars = 2;
  end
  return numStars;

end -- End calcStars().


-- ============================================================================
-- Called when the current level is failed.
-- ============================================================================
function levelFailed()

  utils:log("levelConclusions", "levelFailed()");

  -- Stop all activity on the level and clean up a bit.
  stopLevelActivity(MODE_LEVEL_FAILED);

  -- Fade rect.
  levelConclusionFadeRect = display.newRect(
    0, 0, display.contentWidth, display.contentHeight
  );
  levelConclusionFadeRect:setReferencePoint(display.TopLeftReferencePoint);
  levelConclusionFadeRect:setFillColor(0, 0, 0);
  levelConclusionFadeRect.alpha = 0;
  transition.to(levelConclusionFadeRect, { alpha = .8, time = 1000 });

  -- Animated text.
  levelConclusionText = textCandy.CreateText({
    fontName = "fontLED",
    x = display.contentWidth / 2,
    y = display.contentHeight / 2,
    text = "YOU BLEW IT!|TRY AGAIN!",
    originX = "center", originY = "center", textFlow = "center",
    charSpacing = 0, lineSpacing = 0, showOrigin = false
  });
  levelConclusionText:applyInOutTransition({
    hideCharsBefore = true, hideCharsAfter = true,
    startNow = true, loop = false, autoRemoveText = false,
    restartOnChange = true, inDelay = 0, inCharDelay = 40,
    inMode = "LEFT_RIGHT",
    AnimateFrom = {
      xScale = 0.01, yScale = 0.01, time = 1000, transition = easing.outQuad
    }
  });
  levelConclusionText:applyAnimation({
    startNow = true, restartOnChange = true, charWise = true,
    frequency = 250, startAlpha = 0.65, alphaRange = 0.35
  });

  -- Exit button.
  levelConclusionExit = textCandy.CreateText({
    fontName = "fontMediumSilver", x = 5, y = 5;
    text = "EXIT", originX = "left", originY = "top",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  levelConclusionExit:addEventListener("touch",
    function(inEvent)
      levelConclusionExitListener(inEvent);
      return true;
    end
  );

  -- Retry button.
  levelConclusionRetry = textCandy.CreateText({
    fontName = "fontMediumSilver", x = display.contentWidth - 162, y = 5,
    text = "RETRY", originX = "left", originY = "top",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  levelConclusionRetry:addEventListener("touch",
    function(inEvent)
      levelConclusionRetryListener(inEvent);
      return true;
    end
  );

  -- Level failed sound.
  sfx.levelFailedChannel = audio.play(sfx.levelFailed);

end -- End levelFailed().


-- ============================================================================
-- Called when a level ends (either outcome) to stop all current activity.
--
-- @param inMode The new mode to flip the game into.
-- ============================================================================
function stopLevelActivity(inMode)

  utils:log("levelConclusions", "stopLevelActivity()");

  -- Flip game mode so particles stop moving.
  currentMode = inMode;

  -- Ensure no powerups are running.
  powerupOfflineActive = false;
  powerupGravityActive = false;

  -- Stop active powerup text animation, if any.
  if powerupsCountdownText ~= nil then
    powerupsCountdownText:removeSelf();
    powerupsCountdownText = nil;
  end

  -- Get rid of powerups menu if showing.
  if powerupsMenuShowing == true then
    utils:xpcall(
      "levelConclusions.lua:Calling destroyPowerupsMenu()", destroyPowerupsMenu
    );
  end

  -- Destroy all particles.
  local i = #currentLevel.particles;
 	if i > 0 then
    local stillMore = true;
    while stillMore == true do
      currentLevel.particles[i]:removeSelf();
      table.remove(currentLevel.particles, i);
      i = i - 1;
      if i == 0 then
        stillMore = false;
      end
    end
  end

end -- End stopLevelActivity().


-- ============================================================================
-- Updates the rotation animation for the level complete text.
-- ============================================================================
function updateLevelCompleteAnimation()

  levelConclusionText.rotation = levelConclusionText.rotation - 1.5;
  levelConclusionText.yScale = math.sin(system.getTimer() / 1000) * 1.0;

end -- End updateLevelCompleteAnimation().


-- ============================================================================
-- Touch listener for Exit.
--
-- @param inEvent The touch event.
-- ============================================================================
function levelConclusionExitListener(inEvent)

  --utils:log("levelConclusions", "levelConclusionExitListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    -- Clean up.
    currentMode = nil;
    particleCandy.ClearParticles();
    textCandy.DeleteTexts();
    levelConclusionText = nil;
    levelConclusionExit = nil;
    levelConclusionNext = nil;
    levelConclusionFadeRect:removeSelf();
    levelConclusionFadeRect = nil;
    if star1 ~= nil then
      star1:removeSelf();
      star1 = nil;
    end
    if star2 ~= nil then
      star2:removeSelf();
      star2 = nil;
    end
    if star3 ~= nil then
      star3:removeSelf();
      star3 = nil;
    end
    -- Switch to title scene.
    storyboard.gotoScene("titleScene", sceneTransitionEffect, 500 );
  end

end -- End levelConclusionExitListener().


-- ============================================================================
-- Touch listener for Next.
--
-- @param inEvent The touch event.
-- ============================================================================
function levelConclusionNextListener(inEvent)

  --utils:log("levelConclusions", "levelConclusionNextListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    -- Reset mode and stop any still-running particle animations.
    currentMode = nil;
    particleCandy.ClearParticles();
    -- Transition the various elements.
    transition.to(levelConclusionText,
      { delta = true, x = 1000, time = 500,
        onComplete = function(inTarget)
          -- Clean up.
          textCandy.DeleteText(levelConclusionText);
          levelConclusionText = nil;
        end
      }
    );
    transition.to(levelConclusionExit,
      { x = -1000, time = 500,
        onComplete = function(inTarget)
          textCandy.DeleteText(levelConclusionExit);
          levelConclusionExit = nil;
        end
      }
    );
    transition.to(levelConclusionNext,
      { x = -1000, time = 500,
        onComplete = function(inTarget)
          textCandy.DeleteText(levelConclusionNext);
          levelConclusionNext = nil;
        end
      }
    );
    transition.to(levelConclusionFadeRect,
      { alpha = 0, time = 500,
        onComplete = function(inTarget)
          levelConclusionFadeRect:removeSelf();
          levelConclusionFadeRect = nil;
        end
      }
    );
    transition.to(star1, {
      y = display.contentHeight + 80, time = 500,
      onComplete = function()
        star1:removeSelf();
        star1 = nil;
      end
    });
    if star2 ~= nil then
      transition.to(star2, {
        y = display.contentHeight + 80, time = 500,
        onComplete = function()
          star2:removeSelf();
          star2 = nil;
        end
      });
    end
    if star3 ~= nil then
      transition.to(star3, {
        y = display.contentHeight + 80, time = 500,
        onComplete = function()
          star3:removeSelf();
          star3 = nil;
        end
      });
    end
    -- Start the next level.  By the time the transitions are done we'll
    -- be ready to play.
    utils:xpcall("levelConclusions.lua:Calling startLevel()", startLevel);
    particleMeter.isVisible = true;
  end

end -- End levelConclusionNextListener().


-- ============================================================================
-- Touch listener for Retry.
--
-- @param inEvent The touch event.
-- ============================================================================
function levelConclusionRetryListener(inEvent)

  --utils:log("levelConclusions", "levelConclusionRetryListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    -- Reset mode and stop any still-running particle animations.
    currentMode = nil;
    particleCandy.ClearParticles();
    -- Transition the various elements.
    transition.to(levelConclusionText,
      { delta = true, x = 1000, time = 500,
        onComplete = function(inTarget)
          -- Clean up.
          textCandy.DeleteText(levelConclusionText);
          levelConclusionText = nil;
        end
      }
    );
    transition.to(levelConclusionExit,
      { x = -1000, time = 500,
        onComplete = function(inTarget)
          textCandy.DeleteText(levelConclusionExit);
          levelConclusionExit = nil;
        end
      }
    );
    transition.to(levelConclusionRetry,
      { x = -1000, time = 500,
        onComplete = function(inTarget)
          textCandy.DeleteText(levelConclusionRetry);
          levelConclusionRetry = nil;
        end
      }
    );
    transition.to(levelConclusionFadeRect,
      { alpha = 0, time = 500,
        onComplete = function(inTarget)
          levelConclusionFadeRect:removeSelf();
          levelConclusionFadeRect = nil;
        end
      }
    );
    -- Start the next level.  By the time the transitions are done we'll
    -- be ready to play.
    utils:xpcall("levelConclusions.lua:Calling startLevel()", startLevel);
    particleMeter.isVisible = true;
  end

end -- End levelConclusionRetryListener().
