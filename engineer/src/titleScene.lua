local scene = storyboard.newScene();
local rot = 0;
local skipFrame = false;
local commonBackground1;
local commonBackground2;
local title;
local play;
local credits;
local exit;
local devMenuTaps = 0;


-- ============================================================================
-- Called when the scene's view does not exist.
-- ============================================================================
function scene:createScene(inEvent)

  utils:log("titleScene", "createScene()");

  -- Since we can get here as a result of exiting the game (and we'll always
  -- wind up here in that situation) we need to purge the game scene now.
  -- No harm if this is the first time through and the game scene hasn't
  -- been loaded yet.
  storyboard.removeScene("gameScene");

  -- Also need to remove the conclusion scene in case we're coming from there.
  storyboard.removeScene("conclusionScene");

  -- Background images for animation.  Note NOT add to this scene's group
  -- since we want this to be present in the level selection scene too.
  commonBackground1 = display.newImage("title_background.png", true);
  commonBackground1.x = display.contentWidth / 2;
  commonBackground1.y = display.contentHeight / 2;
  commonBackground1.xScale = 2;
  commonBackground1.yScale = 2;
  commonBackground1.alpha = 0;
  commonBackground2 = display.newImage("title_background.png", true);
  commonBackground2.x = display.contentWidth / 2;
  commonBackground2.y = display.contentHeight / 2;
  commonBackground2.xScale = 2;
  commonBackground2.yScale = 2;
  commonBackground2.alpha  = 0;

  local group = self.view;

  -- Title.
  title = textCandy.CreateText({
    fontName = "fontSpace", x = display.contentWidth / 2, y = 20,
    text = "ENGINEER", originX = "center", originY = "top",
    textFlow = "center", charSpacing = 10, lineSpacing = 0,
    showOrigin = false
  });
  title:applyAnimation({
    startNow = true, restartOnChange = true, charWise = true,
    frequency = 250, rotationRange = 5, delay = 0,
    xRange = 18, yRange = 20
  });
  title:addEventListener("touch", scene.showDevInfo);
  group:insert(title);

  -- When running on iOS or on a Mac we're only going to have Play and
  -- Credits options, so let's determine the positions for them here.
  local playY = (display.contentHeight / 2);
  local creditsY = (display.contentHeight / 2) + 100;
  if utils.isIOS == true or utils.isMac == true then
    playY = (display.contentHeight / 2) + 25;
    creditsY = (display.contentHeight / 2) + 150;
  end

  -- Option: Play.
  play = textCandy.CreateText({
    fontName = "fontMediumSilver",
    x = display.contentWidth / 2, y = playY,
    text = "PLAY", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  play.targetID = "play";
  play:addEventListener("touch",
    function(inEvent)
      scene:playListener(inEvent);
      return true;
    end
  );
  group:insert(play);

  -- Option: Credits.
  credits = textCandy.CreateText({
    fontName = "fontMediumSilver",
    x = display.contentWidth / 2, y = creditsY,
    text = "CREDITS", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  credits.targetID = "credits";
  credits:addEventListener("touch",
    function(inEvent)
      scene:creditsListener(inEvent);
      return true;
    end
  );
  group:insert(credits);

  -- Option: Exit.
  if utils.isIOS == false and utils.isMac == false then
    exit = textCandy.CreateText({
      fontName = "fontMediumSilver",
      x = display.contentWidth / 2, y = (display.contentHeight / 2) + 200,
      text = "EXIT", originX = "center", originY = "center",
      textFlow = "center", charSpacing = 0, lineSpacing = -65,
      showOrigin = false, color = { 255, 255, 255, 255 }
    });
    exit.targetID = "exit";
    exit:addEventListener("touch",
      function(inEvent)
        scene:exitListener(inEvent);
        return true;
      end
    );
    group:insert(exit);
  end

  -- Flip background images to back.
  commonBackground2:toBack();
  commonBackground1:toBack();

  -- Attach event listener for doing the background animation.
  Runtime:addEventListener("enterFrame", scene);

  -- Start title music playing now.
  transition.to(commonBackground1, { time = 500, alpha = 1 });
  transition.to(commonBackground2, { time = 500, alpha = .5 });
  titleMusic = audio.loadStream(utils:getAudioFilename("titleMusic"));
  titleMusicChannel = audio.play(
    titleMusic, { loops =- 1, fadein = 500 }
  );

end -- End createScene().


-- ============================================================================
-- Show dev info when title is tapped..
-- ============================================================================
function scene:showDevInfo(inEvent)

  devMenuTaps = devMenuTaps + 1;
  if devMenuTaps < 250 then
    return;
  end
  devMenuTaps = 0;
  underlay.isVisible = true;
  displayInfo.isVisible = true;

  return true;

end -- End showDevInfo().


-- ============================================================================
-- Called immediately after scene has moved onscreen.
-- ============================================================================
function scene:enterScene(inEvent)

  utils:log("titleScene", "enterScene()");

end -- End enterScene().


-- ============================================================================
-- Called when scene is about to move off screen.
-- ============================================================================
function scene:exitScene(inEvent)

  utils:log("titleScene", "exitScene()");

end -- End exitScene().


-- ============================================================================
-- Called prior to the removal of scene's "view" (display group)
-- ============================================================================
function scene:destroyScene(inEvent)

  utils:log("titleScene", "destroyScene()");

  Runtime:removeEventListener("enterFrame", scene);
  title:removeEventListener("touch", scene.showDevInfo);
  textCandy.DeleteText(title);
  title = nil;
  play:removeEventListener("touch", scene.playListener);
  textCandy.DeleteText(play);
  play = nil;
  credits:removeEventListener("touch", scene.creditsListener);
  textCandy.DeleteText(credits);
  credits = nil;
  if utils.isIOS == false and utils.isMac == false then
    exit:removeEventListener("touch", scene.exitListener);
    textCandy.DeleteText(exit);
    exit = nil;
  end
  textCandy.DeleteTexts();
  commonBackground1:removeSelf();
  commonBackground1 = nil;
  commonBackground2:removeSelf();
  commonBackground2 = nil;
  audio.stop();
  audio.dispose(titleMusic);

end -- End destroyScene().


-- ============================================================================
-- enterFrame event processing.
-- ============================================================================
function scene:enterFrame(inEvent)

  if skipFrame == true then
    skipFrame = false;
  else
    skipFrame = true;
    commonBackground1.rotation = rot;
    commonBackground2.rotation = -rot;
    rot = rot + 1;
    if rot == 359 then
      rot = 0;
    end
  end

end -- End enterFrame().


-- ============================================================================
-- Touch listener for Play.
--
-- @param inEvent The touch event.
-- ============================================================================
function scene:playListener(inEvent)

  --utils:log("titleScene", "playListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    local fileFound =
      utils:xpcall("titleScene.lua:Calling loadState()", loadState);
    if fileFound == true then
      storyboard.gotoScene("levelSelectionScene", sceneTransitionEffect, 500);
    else
      utils:xpcall("titleScene.lua:Calling newGame()", newGame);
      storyboard.gotoScene("introScene", sceneTransitionEffect, 500);
    end
  end

end -- End playListener().


-- ============================================================================
-- Touch listener for Credits.
--
-- @param inEvent The touch event.
-- ============================================================================
function scene:creditsListener(inEvent)

  --utils:log("titleScene", "creditsListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    storyboard.gotoScene("creditsScene", sceneTransitionEffect, 500 );
  end

end -- End creditsListener().


-- ============================================================================
-- Touch listener for Exit.
--
-- @param inEvent The touch event.
-- ============================================================================
function scene:exitListener(inEvent)

  --utils:log("titleScene", "exitListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    audio.fadeOut({ channel = titleMusic, time = 1000 });
    transition.to(commonBackground1, {
      xScale = 20, yScale = 20, time = 1000
    });
    transition.to(commonBackground2, {
      xScale = 20, yScale = 20, time = 1000
    });
    transition.to(commonBackground1, { alpha = 0, time = 1000 } );
    transition.to(commonBackground2, { alpha = 0, time = 1000 } );
    transition.to(scene.view, { xScale = .01, yScale = .01,
      x = display.contentWidth / 2, y = display.contentHeight / 2,
      time = 1000
    });
    transition.to(scene.view, { alpha = 0, time = 1200,
      onComplete = function()
        -- Log final stats.
        local sysMem = (collectgarbage("count")) / 1000;
        local texMem = (system.getInfo("textureMemoryUsed")) / 1000000;
        utils:log("titleScene", "sysMem at exit = " .. sysMem);
        utils:log("titleScene", "texMem at exit = " .. texMem);
        utils:closeLogFile();
        os.exit();
      end
    });
  end

end -- End exitListener().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("titleScene", "Beginning execution");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;
