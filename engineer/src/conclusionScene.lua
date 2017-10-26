local scene = storyboard.newScene();
local readDelay = 10000;
local switchTimer1;
local switchTimer2;
local page1;
local page2;
local transitionInFlight;


-- ============================================================================
-- Called when the scene's view does not exist.
-- ============================================================================
function scene:createScene(inEvent)

  utils:log("conclusionScene", "createScene()");

  -- Clear memory by getting rid of the previous scenes.
  storyboard:removeAll();

  local group = self.view;

  -- Page1.
  page1 = display.newImage("conclusion_page1.png", true);
  page1.targetID = "page1";
  page1.x = display.contentWidth / 2;
  page1.y = display.contentHeight / 2;
  page1:addEventListener("touch", scene);
  group:insert(page1);

  -- Page2.
  page2 = display.newImage("conclusion_page2.png", true);
  page2.targetID = "page2";
  page2.x = display.contentWidth / 2;
  page2.y = display.contentHeight / 2;
  page2.alpha = 0;
  page2:addEventListener("touch", scene);
  group:insert(page2);

  -- Start transition from page 1 to page 2.
  switchTimer1 = transition.to(page1, {
    delay = readDelay, time = 2000, alpha = 0
  });
  switchTimer2 = transition.to(page2, {
    delay = readDelay, time = 2000, alpha = 1,
    onStart = function()
      transitionInFlight = true;
    end,
    onComplete = function()
      transitionInFlight = false;
      -- Now start the transition to fade page 2 out and return to title.
      switchTimer1 = transition.to(page2, {
        delay = readDelay, time = 2000, alpha = 0,
        onStart = function()
          transitionInFlight = true;
        end,
        onComplete = function()
          transitionInFlight = false;
          storyboard.gotoScene("titleScene", sceneTransitionEffect, 500);
        end
      });
    end
  });

  -- Start music.
  conclusionMusic = audio.loadStream(utils:getAudioFilename("conclusionMusic"));
  conclusionMusicChannel = audio.play(
    conclusionMusic, { loops =- 1, fadein = 500 }
  );

end -- End createScene().


-- ============================================================================
-- Called immediately after scene has moved onscreen.
-- ============================================================================
function scene:enterScene(inEvent)

  utils:log("conclusionScene", "enterScene()");

end -- End enterScene().


-- ============================================================================
-- Called when scene is about to move off screen.
-- ============================================================================
function scene:exitScene(inEvent)

  utils:log("conclusionScene", "exitScene()");

end -- End exitScene().


-- ============================================================================
-- Called prior to the removal of scene's "view" (display group)
-- ============================================================================
function scene:destroyScene(inEvent)

  utils:log("conclusionScene", "destroyScene()");

  page1:removeSelf();
  page1 = nil;
  page2:removeSelf();
  page2 = nil;

  audio.stop();
  audio.dispose(conclusionMusic);

end -- End destroyScene().


-- ============================================================================
-- Handle touch events.
-- ============================================================================
function scene:touch(inEvent)

  --utils:log("conclusionScene", "touch()");

  if transitionInFlight == true then
    return;
  end

  if inEvent.phase == "began" then

    -- First, cancel any active timers.
    if switchTimer1 ~= nil then
      transition.cancel(switchTimer1);
    end
    if switchTimer2 ~= nil then
      transition.cancel(switchTimer2);
    end

    if inEvent.target.targetID == "page1" then

      transitionInFlight = true;
      switchTimer1 = transition.to(page1, {
        delay = 0, time = 2000, alpha = 0
      });
      switchTimer2 = transition.to(page2, {
        delay = 0, time = 2000, alpha = 1,
        onComplete = function()
          transitionInFlight = false;
          -- Now start the transition to fade page 2 out and return to title.
          switchTimer1 = transition.to(page2, {
            delay = readDelay, time = 2000, alpha = 0,
            onStart = function()
              transitionInFlight = true;
            end,
            onComplete = function()
              transitionInFlight = false;
              storyboard.gotoScene("titleScene", sceneTransitionEffect, 500);
            end
          });
        end
      });

    else

      transitionInFlight = true;
      -- Now start the transition to fade page 2 out and return to title.
      switchTimer1 = transition.to(page2, {
        delay = 0, time = 2000, alpha = 0,
        onComplete = function()
          transitionInFlight = false;
          storyboard.gotoScene("titleScene", sceneTransitionEffect, 500);
        end
      });

    end

  end

  return true;

end -- End touch().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("conclusionScene", "Beginning execution");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;
