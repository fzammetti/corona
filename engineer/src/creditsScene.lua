local scene = storyboard.newScene();
local creditText = {
  "ENGINEER V1.0 " .. buildVersion .. "|A GAME BY|ETHERIENT",
  "IN ASSOCIATION WITH|CRACKHEAD|CREATIONS",
  "PROGRAMMING|FRANK W. ZAMMETTI",
  "GRAPHICS|ANTHONY VOLPE|FRANK W. ZAMMETTI",
  "IN-GAME BACKGROUNDS|PATRICK HOESLY|WWW.FLICKR.COM|/PEOPLE/ZOOBOING",
  "MUSIC AND SOUND|FRANK W. ZAMMETTI",
  "LEVEL DESIGN|FRANK W. ZAMMETTI|ANDREW ZAMMETTI|ASHLEY ZAMMETTI|TRACI ZAMMETTI",
  "(C)2012 ETHERIENT|AND|FRANK W. ZAMMETTI|ALL RIGHTS|RESERVED",
  "THANK YOU|AND ENJOY!"
};
local creditTextIndex;
local currentText;
local back;


-- ----------------------------------------------------------------------------
-- Called when the scene's view does not exist.
-- ----------------------------------------------------------------------------
function scene:createScene(inEvent)

  utils:log("creditsScene", "createScene()");

  local group = self.view;

  -- Back button.
  back = textCandy.CreateText({
    fontName = "fontMediumSilver", x = 5, y = 5,
    text = "BACK", originX = "left", originY = "top",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
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

end -- End createScene().


-- ----------------------------------------------------------------------------
-- Called immediately after scene has moved onscreen.
-- ----------------------------------------------------------------------------
function scene:enterScene(inEvent)

  utils:log("creditsScene", "enterScene()");

  creditTextIndex = 1;

  -- First text item.
  currentText = textCandy.CreateText({
  	fontName = "fontLED", text = creditText[creditTextIndex],
  	x = display.contentWidth / 2, y = display.contentHeight / 2,
  	originX = "CENTER", originY = "CENTER", textFlow = "CENTER",
  	wrapWidth = 800, showOrigin = false
  });
  self.view:insert(currentText);

  -- Animate it in and begin the process of flipping to more text.
  utils:xpcall("creditsScene.lua:Calling animateText()", scene.animateText);

end -- End enterScene().


-- ----------------------------------------------------------------------------
-- Called when scene is about to move off screen.
-- ----------------------------------------------------------------------------
function scene:exitScene(inEvent)

  utils:log("creditsScene", "exitScene()");

end -- End exitScene().


-- ----------------------------------------------------------------------------
-- Called prior to the removal of scene's "view" (display group)
-- ----------------------------------------------------------------------------
function scene:destroyScene(inEvent)

  utils:log("creditsScene", "destroyScene()");

end -- End destroyScene().


-- ============================================================================
-- Touch listener for Back.
--
-- @param inEvent The touch event.
-- ============================================================================
function scene:backListener(inEvent)

  --utils:log("creditsScene", "backListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(inEvent.target);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(inEvent.target, true);
    audio.play(sfx.menuBeep);
    audio.play(sfx.menuBeep);
    timer.performWithDelay(1000,
      function()
        currentText:removeInOutTransition();
        textCandy.DeleteText(currentText);
        currentText = nil;
      end
    );
    storyboard.gotoScene("titleScene", sceneTransitionEffect, 500);
  end

end -- End backListener().


-- ----------------------------------------------------------------------------
-- Creates the next text element and shows it.
-- ----------------------------------------------------------------------------
function scene:animateText()

  utils:log("creditsScene", "animateText()");

  currentText:applyInOutTransition({
    hideCharsBefore = true, hideCharsAfter = true, startNow = true,
    loop = false, autoRemoveText = false, restartOnChange = true,
    restoreOnComplete = false,
    inDelay = 0, inCharDelay = 40, inMode = "LEFT_RIGHT",
    AnimateFrom = {
      xScale = -4.0, yScale = 4.0, x = -display.contentWidth, time = 1000,
      transition = easing.outQuad
    },
    outDelay = 3000, outCharDelay = 40, outMode = "LEFT_RIGHT",
    AnimateTo = {
      xScale = -4.0, yScale = 4.0, x = display.contentWidth, time = 1000,
      transition = easing.inQuad
    },
    CompleteListener = function()
      creditTextIndex = creditTextIndex + 1;
      if creditTextIndex > #creditText then
        creditTextIndex = 1;
      end
      currentText:setText(creditText[creditTextIndex]);
    end
  });

end -- End animateText().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("creditsScene", "Beginning execution");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;
