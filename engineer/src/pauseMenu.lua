local btnContinue;
local btnRestartLevel;
local btnSaveAndExit;


-- ============================================================================
-- Shows the pause menu when triggered by the user tapping the pause button.
-- ============================================================================
function showPauseMenu()

  utils:log("pauseMenu", "showPauseMenu()");

  -- Flip into game paused mode.
  currentMode = MODE_PAUSED;

  -- Create display group for all menu elements (except fade rectangle).
  pause.group = display.newGroup();

  -- Create fade rectangle.
  pause.fadeRect = display.newRect(
    0, 0, display.contentWidth, display.contentHeight
  );
  pause.fadeRect:setReferencePoint(display.TopLeftReferencePoint);
  pause.fadeRect:setFillColor(0, 0, 0);
  pause.fadeRect.alpha = 0;

  -- Create menu background
  local background = display.newImage("pauseMenu_background.png", true);
  background.x = display.contentWidth / 2;
  background.y = display.contentHeight / 2;
  pause.group:insert(background);

  -- Add menu items.
  btnContinue = textCandy.CreateText({
    fontName = "fontMediumSilver",
    x = display.contentWidth / 2, y = (display.contentHeight / 2) - 120,
    text = "CONTINUE", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  btnContinue.targetID = "pause_btnContinue";
  btnContinue:addEventListener("touch",
    function(inEvent)
      pauseContinueListener(inEvent);
      return true;
    end
  );
  pause.group:insert(btnContinue);
  btnRestartLevel = textCandy.CreateText({
    fontName = "fontMediumSilver",
    x = display.contentWidth / 2, y = (display.contentHeight / 2),
    text = "RESTART LEVEL", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  btnRestartLevel.targetID = "pause_btnRestartLevel";
  btnRestartLevel:addEventListener("touch",
  function(inEvent)
    pauseRestartLevelListener(inEvent);
    return true;
  end
);
  pause.group:insert(btnRestartLevel);
  btnSaveAndExit = textCandy.CreateText({
    fontName = "fontMediumSilver",
    x = display.contentWidth / 2, y = (display.contentHeight / 2) + 120,
    text = "SAVE AND EXIT", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  btnSaveAndExit.targetID = "pause_btnSaveAndExit";
  btnSaveAndExit:addEventListener("touch",
    function(inEvent)
      pauseSaveAndExitListener(inEvent);
      return true;
    end
  );
  pause.group:insert(btnSaveAndExit);

  -- Move the group off-screen then slide it down while also fading in the
  -- fade rect.
  pause.group:toFront();
  pause.group.y = -500;
  transition.to(pause.group, { time = 250, y = 0 });
  transition.to(pause.fadeRect, { time = 250, alpha = .8 });

end -- End showPauseMenu().


-- ============================================================================
-- Touch listener for Continue.
--
-- @param inEvent The touch event.
-- ============================================================================
function pauseContinueListener(inEvent)

  --utils:log("pauseMenu", "pauseContinueListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    -- Fade rect.
    transition.to(pause.fadeRect, {
      time = 250, alpha = 0,
      onComplete = function()
        pause.fadeRect:removeSelf();
        pause.fadeRect = nil;
      end
    });
    -- Transition the menu off.
    transition.to(pause.group,
      { time = 1000, alpha = 0, xScale = 30.0, yScale = 30.0,
        onComplete = function(inTarget)
          btnContinue:removeEventListener("touch", pauseContinueListener);
          btnRestartLevel:removeEventListener(
            "touch", pauseRestartLevelListener
          );
          btnSaveAndExit:removeEventListener(
            "touch", pauseSaveAndExitListener
          );
          textCandy.DeleteText(btnContinue);
          textCandy.DeleteText(btnRestartLevel);
          textCandy.DeleteText(btnSaveAndExit);
          btnContinue = nil;
          btnRestartLevel = nil;
          btnSaveAndExit = nil;
          pause.group:removeSelf();
          pause.group = nil;
          currentMode = MODE_PLAYING;
        end
      }
    );
  end

  return true;

end -- End pauseContinueListener().


-- ============================================================================
-- Touch listener for Restart Level.
--
-- @param inEvent The touch event.
-- ============================================================================
function pauseRestartLevelListener(inEvent)

  --utils:log("pauseMenu", "pauseRestartLevelListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    -- Get rid of menu immediately.
    btnContinue:removeEventListener("touch", pauseContinueListener);
    btnRestartLevel:removeEventListener(
      "touch", pauseRestartLevelListener
    );
    btnSaveAndExit:removeEventListener(
      "touch", pauseSaveAndExitListener
    );
    textCandy.DeleteText(btnContinue);
    textCandy.DeleteText(btnRestartLevel);
    textCandy.DeleteText(btnSaveAndExit);
    btnContinue = nil;
    btnRestartLevel = nil;
    btnSaveAndExit = nil;
    pause.group:removeSelf();
    pause.group = nil;
    pause.fadeRect:removeSelf();
    pause.fadeRect = nil;
    -- Show confirmation message box.
    showConfirmPopup(currentLevel.dg,
      "ALL PROGRESS WILL BE LOST!|||ARE YOU SURE YOU WANT TO|RESTART THIS LEVEL?",
      function()
        -- Start the same level again.
        utils:xpcall("pauseMenu.lua:Calling startLevel()", startLevel);
        particleMeter.isVisible = true;
      end,
      function()
        currentMode = MODE_PLAYING;
      end
    );
  end

  return true;

end -- End pauseRestartLevelListener().


-- ============================================================================
-- Touch listener for Save And Exit.
--
-- @param inEvent The touch event.
-- ============================================================================
function pauseSaveAndExitListener(inEvent)

  --utils:log("pauseMenu", "pauseSaveAndExitListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    -- Save current game state.
    utils:xpcall("pauseMenu.lua:Calling saveState()", saveState);
    -- Clean up the menu.
    btnContinue:removeEventListener("touch", pauseContinueListener);
    btnRestartLevel:removeEventListener(
      "touch", pauseRestartLevelListener
    );
    btnSaveAndExit:removeEventListener(
      "touch", pauseSaveAndExitListener
    );
    textCandy.DeleteText(btnContinue);
    textCandy.DeleteText(btnRestartLevel);
    textCandy.DeleteText(btnSaveAndExit);
    btnContinue = nil;
    btnRestartLevel = nil;
    btnSaveAndExit = nil;
    pause.fadeRect:removeSelf();
    pause.fadeRect = nil;
    pause.group:removeSelf();
    pause.group = nil;
    -- Switch to title scene.
    storyboard.gotoScene("titleScene", sceneTransitionEffect, 500 );
  end

  return true;

end -- End pauseSaveAndExitListener().
