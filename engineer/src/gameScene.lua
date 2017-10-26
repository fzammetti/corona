local scene = storyboard.newScene();


-- ============================================================================
-- Called when the scene's view does not exist.
-- ============================================================================
function scene:createScene(inEvent)
  utils:log("gameScene", "createScene()");

  -- Clear memory by getting rid of the previous scenes.
  storyboard:removeAll();

  local group = self.view;
  currentLevel.sceneGroup = group;

  -- Creates the "global" display objects at the top.
  utils:xpcall("gameScene.lua:Calling createGlobalDisplayObjects()",
    createGlobalDisplayObjects
  );

  -- Start the specified level.
  utils:xpcall("gameScene.lua:Calling startLevel()", startLevel);

  -- Background hum always present.
  sfx.backgroundHumChannel =
    audio.play(sfx.backgroundHum, { loops = -1 });

end -- End createScene().


-- ============================================================================
-- Called immediately after scene has moved onscreen.
-- ============================================================================
function scene:enterScene(inEvent)

  utils:log("gameScene", "enterScene()");

  -- Not sure why, but the particle meter doesn't seem to want to properly
  -- add to the main game group, so it isn't affected by the scene
  -- transition, which means it just initially floats there.  So, I created
  -- it hidden, and we then show it once the scene transition concludes.
  particleMeter.isVisible = true;

  -- Event listener to make this all work.
  Runtime:addEventListener("enterFrame", enterFrame);

end -- End enterScene().


-- ============================================================================
-- Called when scene is about to move off screen.
-- ============================================================================
function scene:exitScene(inEvent)

  utils:log("gameScene", "exitScene()");

end -- End exitScene().


-- ============================================================================
-- Called prior to the removal of scene's "view" (display group)
-- ============================================================================
function scene:destroyScene(inEvent)

  utils:log("gameScene", "destroyScene()");

  -- Remove enterFrame event listener.
  Runtime:removeEventListener("enterFrame", enterFrame);

  -- Make sure there's no current mode (shouldn't be necessary, but safety
  -- first boys and girls!)
  currentMode = nil;

  -- Get rid of any text objects.
  textCandy.DeleteTexts();

  -- Get rid of any particle objects.
  particleCandy.ClearParticles();

  -- Get rid of any widget objects.
  widgetCandy:RemoveAllWidgets();
  particleMeter = nil;

  -- Get rid of level DisplayGroup and make sure we don't hold a reference to
  -- the scene's DisplayGroup.
  currentLevel.dg:removeSelf();
  currentLevel.dg = nil;
  currentLevel.sceneGroup = nil;

  -- Don't hold reference to pause button trigger (it's already been removed
  -- though so no need for removeSelf() call);
  pause.button = nil;

  -- Don't hold reference to powerups button (it's already been removed
  -- though so no need for removeSelf() call);
  powerupsButton.sprite = nil;

  audio.stop();

end -- End destroyScene().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("gameScene", "Beginning execution");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;
