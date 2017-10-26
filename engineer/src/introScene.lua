local scene = storyboard.newScene();
local readDelay = 10000;
local switchTimer1;
local switchTimer2;
local switchTimer3;
local page1;
local page2;
local page3;
local page3Background;
local ie;
local diverterSpriteSheet;
local diverterSpriteSet;
local transitionInFlight;
local startGameText;
local onPage3 = false;


-- ============================================================================
-- Called when the scene's view does not exist.
-- ============================================================================
function scene:createScene(inEvent)

  utils:log("introScene", "createScene()");

  -- Clear memory by getting rid of the previous scenes.
  storyboard:removeAll();

  -- Set flag so we only see this once.
  gameState.introDone = true;
  utils:xpcall("introScene.lua:Calling saveState()", saveState);

  local group = self.view;

  -- Page1.
  page1 = display.newImage("intro_page1.png", true);
  page1.targetID = "page1";
  page1.x = display.contentWidth / 2;
  page1.y = display.contentHeight / 2;
  page1.alpha = 1;
  page1:addEventListener("touch", scene);
  group:insert(page1);

  -- Page2.
  page2 = display.newImage("intro_page2.png", true);
  page2.targetID = "page2";
  page2.x = display.contentWidth / 2;
  page2.y = display.contentHeight / 2;
  page2.alpha = 0;
  page2:addEventListener("touch", scene);
  group:insert(page2);

  -- Blurred background for the page 3 instructions.
  page3Background = display.newImage("intro_page3_background.png", true);
  page3Background.x = display.contentWidth / 2;
  page3Background.y = display.contentHeight / 2;
  page3Background.alpha = 0;
  group:insert(page3Background);

  -- Start Game text for page 3.
  startGameText = textCandy.CreateText({
    fontName = "fontMediumSilver", x = display.contentWidth - 172, y = 5,
    text = "START", originX = "left", originY = "top",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  startGameText.alpha = 0;
  startGameText.targetID = "startGameText";
  startGameText:addEventListener("touch", scene);

  -- The actual page 3 instructions.
  page3 = display.newGroup();
  ie = { };
  local y = 0;
  ie[1] = scene:makeText("..YOUR GOAL..", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("PASS ALL 30 LEVELS TO COMPLETE THE GAME!", y);
   y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("..HOW TO PLAY..", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("TO COMPLETE A LEVEL FILL UP THE ENERGY BAR:", y);
  y = y + ie[#ie].height;
  local meter = widgetCandy.NewProgBar({
    x = "center", y = 1, width = 592,
    theme = "widgetCandy_theme2",
    value = 0.5, border = { }, name = "ieMeter",
    textFormatter = function(value)
      return "";
    end
} )
  ie[#ie + 1] = meter;
  ie[#ie].y = y + (ie[#ie].height / 2) + 6; y = y + ie[#ie].height + 60;
  ie[#ie + 1] = scene:makeText("...BY DIRECTING PARTICLES:", y);
  y = y + ie[#ie].height;
  local pRed = sprite.newSprite(particleResources.sets.red, true);
  pRed.x = (display.contentWidth / 2) - (pRed.width * 2) - 20;
  pRed:prepare("default"); pRed:play();
  local pBlue = sprite.newSprite(particleResources.sets.blue, true);
  pBlue.x = (display.contentWidth / 2) - 32;
  pBlue:prepare("default"); pBlue:play();
  local pGreen = sprite.newSprite(particleResources.sets.green, true);
  pGreen.x = (display.contentWidth / 2) + 32;
  pGreen:prepare("default"); pGreen:play();
  local pYellow = sprite.newSprite(particleResources.sets.yellow, true);
  pYellow.x = (display.contentWidth / 2) + (pYellow.width * 2) + 20;
  pYellow:prepare("default"); pYellow:play();
  local pGroup = display.newGroup();
  pGroup:insert(pRed); pGroup:insert(pBlue); pGroup:insert(pGreen); pGroup:insert(pYellow);
  ie[#ie + 1] = pGroup;
  ie[#ie].y = y + (pRed.height / 2) + 26; y = y + pRed.height + 59;
  ie[#ie + 1] = scene:makeText("...WHICH EMERGE FROM GENERATORS:", y);
  y = y + ie[#ie].height;
  local generator = sprite.newSprite(generatorResources.set, true);
  generator:prepare("default"); generator:play();
  ie[#ie + 1] = generator;
  ie[#ie].x = display.contentWidth / 2; ie[#ie].y = y + (ie[#ie].height / 2) + 24; y = y + ie[#ie].height + 56;
  ie[#ie + 1] = scene:makeText("...INTO MATCHING PORTS:", y);
  y = y + ie[#ie].height;
  local rRed = sprite.newSprite(portResources.sets.red, true);
  rRed.x = (display.contentWidth / 2) - (rRed.width * 2) - 21;
  rRed:prepare("damaged0"); rRed:play();
  local rBlue = sprite.newSprite(portResources.sets.blue, true);
  rBlue.x = (display.contentWidth / 2) - 53;
  rBlue:prepare("damaged0"); rBlue:play();
  local rGreen = sprite.newSprite(portResources.sets.green, true);
  rGreen.x = (display.contentWidth / 2) + 53;
  rGreen:prepare("damaged0"); rGreen:play();
  local rYellow = sprite.newSprite(portResources.sets.yellow, true);
  rYellow.x = (display.contentWidth / 2) + (rYellow.width * 2) + 21;
  rYellow:prepare("damaged0"); rYellow:play();
  local rGroup = display.newGroup();
  rGroup:insert(rRed); rGroup:insert(rBlue); rGroup:insert(rGreen); rGroup:insert(rYellow);
  ie[#ie + 1] = rGroup;
  ie[#ie].y = y + (rRed.height / 2) + 24; y = y + rRed.height + 55;
  ie[#ie + 1] = scene:makeText("TO DIRECT PARTICLES YOU MANIPULATE DIVERTERS:", y);
  y = y + ie[#ie].height;
  diverterSpriteSheet = sprite.newSpriteSheet("intro_page3_diverter.png", 42, 42);
  diverterSpriteSet = sprite.newSpriteSet(diverterSpriteSheet, 1, 7);
  sprite.add(diverterSpriteSet, "default", 1, 7, 1500);
  local diverterSprite = sprite.newSprite(diverterSpriteSet, true);
  diverterSprite:prepare("default"); diverterSprite:play();
  ie[#ie + 1] = diverterSprite;
  ie[#ie].x = display.contentWidth / 2; ie[#ie].y = y + (ie[#ie].height / 2) + 5; y = y + ie[#ie].height + 18;
  ie[#ie + 1] = scene:makeText("TAP A DIVERTER TO CHANGE ITS PATH. A PARTICLE", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("WILL CONTINUE IN THE SAME DIRECTION IT WAS", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("GOING WHEN IT ENTERED A DIVERTER AS LONG AS THE", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("DIVERTER IS SET PROPERLY TO CONTINUE THE PATH.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("IF A PARTICLE CANNOT CONTINUE THEN IT EXPLODES.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("IF A PARTICLE ENTERS A GENERATOR THE LEVEL ENDS.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("IF A PARTICLE ENTERS THE WRONG PORT THE PORT", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("GETS DAMAGED. IF A PORT IS DAMAGED TOO MUCH", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("THE LEVEL ENDS.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("..ANTIPARTICLES..", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("THERE ARE SOMETIMES ANTIPARTICLES TO DEAL WITH:", y);
  y = y + ie[#ie].height;
  local aRed = sprite.newSprite(particleResources.sets.red_anti, true);
  aRed.x = (display.contentWidth / 2) - (aRed.width * 2) - 20;
  aRed:prepare("default"); aRed:play();
  local aBlue = sprite.newSprite(particleResources.sets.blue_anti, true);
  aBlue.x = (display.contentWidth / 2) - 32;
  aBlue:prepare("default"); aBlue:play();
  local aGreen = sprite.newSprite(particleResources.sets.green_anti, true);
  aGreen.x = (display.contentWidth / 2) + 32;
  aGreen:prepare("default"); aGreen:play();
  local aYellow = sprite.newSprite(particleResources.sets.yellow_anti, true);
  aYellow.x = (display.contentWidth / 2) + (aYellow.width * 2) + 20;
  aYellow:prepare("default"); aYellow:play();
  local aGroup = display.newGroup();
  aGroup:insert(aRed); aGroup:insert(aBlue); aGroup:insert(aGreen); aGroup:insert(aYellow);
  ie[#ie + 1] = aGroup;
  ie[#ie].y = y + (aRed.height / 2) + 26; y = y + aRed.height + 59;
  ie[#ie + 1] = scene:makeText("IF A PARTICLE COMES IN CONTACT WITH ITS", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("ANTIPARTICLE COUNTERPART THEN THEY EXPLODE.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("ANTIPARTICLES CANNOT GO INTO PORTS OR GENERATORS.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("INSTEAD DISPOSE OF THEM IN AN ANTIPARTICLE SINK:", y);
  y = y + ie[#ie].height;
  local sink = sprite.newSprite(antimatterSinkResources.set, true);
  sink:prepare("default"); sink:play();
  ie[#ie + 1] = sink;
  ie[#ie].x = display.contentWidth / 2; ie[#ie].y = y + (ie[#ie].height / 2) + 24; y = y + ie[#ie].height + 45;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("..POWERUPS..", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("POWERUPS APPEAR OCCASIONALLY TO AID YOU:", y);
  y = y + ie[#ie].height;
  local powerup = sprite.newSprite(particleResources.sets.powerup, true);
  powerup:prepare("default"); powerup:play();
  ie[#ie + 1] = powerup;
  ie[#ie].x = display.contentWidth / 2; ie[#ie].y = y + (ie[#ie].height / 2) + 24; y = y + ie[#ie].height + 52;
  ie[#ie + 1] = scene:makeText("YOU NEED TO DIRECT THEM INTO A POWERUP PRISON:", y);
  y = y + ie[#ie].height;
  local prison = sprite.newSprite(particlePrisonResources.set, true);
  prison:prepare("default"); prison:play();
  ie[#ie + 1] = prison;
  ie[#ie].x = display.contentWidth / 2; ie[#ie].y = y + (ie[#ie].height / 2) + 25; y = y + ie[#ie].height + 58;
  ie[#ie + 1] = scene:makeText("...TO STORE THEM FOR LATER USE.", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("THE AVAILABLE POWERUPS ARE:", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("GRAVITY - TEMPORARILY SLOWS DOWN ALL PARTICLES", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("FIXIT - REPAIRS ALL DAMAGED PORTS", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("OFFLINE - TEMPORARILY FREEZES GENERATORS", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("DEGAUSS - ELIMINATES ALL EXISTING PARTICLES", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText(" ", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("THAT COVERS IT, YOU ARE READY TO GO! HAVE FUN", y);
  y = y + ie[#ie].height;
  ie[#ie + 1] = scene:makeText("AND TAP THE SCREEN TO START ENGINEERING!", y);
  y = y + ie[#ie].height;

  -- Insert all instruction elements into display group and hide the group.
  for i = 1, #ie, 1 do
    page3:insert(ie[i]);
  end
  page3.alpha = 0;
  page3.y = display.contentHeight + 20;
  group:insert(page3);

  -- Start the transition between the first two pages.
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
      -- Now start the transition to page 3.
      switchTimer1 = transition.to(page2, {
        delay = readDelay, time = 2000, alpha = 0
      });
      switchTimer2 = transition.to(page3, {
        delay = readDelay, time = 2000, alpha = 1,
        onStart = function()
          transitionInFlight = true;
        end,
        onComplete = function()
          transitionInFlight = false;
          utils:xpcall(
            "introScene.lua:Calling startScroll()", scene.startScroll
          );
        end
      });
      switchTimer3 = transition.to(page3Background, {
        delay = readDelay, time = 2000, alpha = 1
      });
    end
  });

  -- Start music.
  introMusic = audio.loadStream(utils:getAudioFilename("introMusic"));
  introMusicChannel = audio.play(
    introMusic, { loops =- 1, fadein = 500 }
  );

end -- End createScene().


-- ============================================================================
-- Called immediately after scene has moved onscreen.
-- ============================================================================
function scene:enterScene(inEvent)

  utils:log("introScene", "enterScene()");

end -- End enterScene().


-- ============================================================================
-- Called when scene is about to move off screen.
-- ============================================================================
function scene:exitScene(inEvent)

  utils:log("introScene", "exitScene()");

end -- End exitScene().


-- ============================================================================
-- Called prior to the removal of scene's "view" (display group)
-- ============================================================================
function scene:destroyScene(inEvent)

  utils:log("introScene", "destroyScene()");

  page1:removeSelf();
  page1 = nil;
  page2:removeSelf();
  page2 = nil;

  for i = 1, #ie, 1 do
    if ie[i].name ~= nil and
      ie[i].name == "FXText" then
      textCandy.DeleteText(ie[i]);
    elseif ie[i].Props ~= nil and ie[i].Props.name ~= nil and
      ie[i].Props.name == "ieMeter" then
      widgetCandy:RemoveAllWidgets();
    else
      ie[i]:removeSelf();
    end
    ie[i] = nil;
  end
  ie = nil;
  page3:removeSelf();
  page3 = nil;
  textCandy.DeleteText(startGameText);
  diverterSpriteSheet:dispose();
  diverterSpriteSheet = nil;

  audio.stop();
  audio.dispose(introMusic);

end -- End destroyScene().


-- ============================================================================
-- Handle touch events.
-- ============================================================================
function scene:touch(inEvent)

  --utils:log("introScene", "touch()");

  if transitionInFlight == true then
    return true;
  end

  if inEvent.phase == "began" then

    -- First, cancel any active timers.
    if switchTimer1 ~= nil and onPage3 == false then
      transition.cancel(switchTimer1);
    end
    if switchTimer2 ~= nil and onPage3 == false then
      transition.cancel(switchTimer2);
    end
    if switchTimer3 ~= nil and onPage3 == false then
      transition.cancel(switchTimer3);
    end

    -- Now, if on page 1, start transition to page 2, and if on page 2
    -- then start transition to instructions (and start scrolling).
    if inEvent.target.targetID == "page1" and onPage3 == false then

      transitionInFlight = true;
      switchTimer2 = transition.to(page2, {
        delay = 0, time = 2000, alpha = 1,
        onComplete = function()
          transitionInFlight = false;
          -- Now start the transition to page 3.
          switchTimer1 = transition.to(page2, {
            delay = readDelay, time = 2000, alpha = 0,
            onStart = function()
              transitionInFlight = true;
            end
          });
          switchTimer2 = transition.to(page3, {
            delay = readDelay, time = 2000, alpha = 1,
            onComplete = function()
              utils:xpcall(
                "introScene.lua:Calling startScroll()", scene.startScroll
              );
            end
          });
          switchTimer3 = transition.to(page3Background, {
            delay = readDelay, time = 2000, alpha = 1
          });
        end
      });

    elseif inEvent.target.targetID == "page2" and onPage3 == false then

      -- Now start the transition to page instructions.
      page2:removeEventListener("touch", scene);
      transitionInFlight = true;
      switchTimer2 = transition.to(page3, {
        delay = 0, time = 2000, alpha = 1,
        onComplete = function()
          transitionInFlight = false;
          utils:xpcall(
            "introScene.lua:Calling startScroll()", scene.startScroll
          );
        end
      });
      switchTimer3 = transition.to(page3Background, {
        delay = 0, time = 2000, alpha = 1
      });

    elseif inEvent.target.targetID == "startGameText" and onPage3 == true then

      storyboard.gotoScene("gameScene", sceneTransitionEffect, 500);

    end

  end

  return true;

end -- End touch().


-- ============================================================================
-- Utility function to create a TextCandy text object.  Just done to reduce
-- the amount of repetitive code in createScene().
--
-- @param inText The text to render.
-- @param inY    The Y location of the text.
-- ============================================================================
function scene:makeText(inText, inY)

  --utils:log("introScene", "makeText()");

  return textCandy.CreateText({
    fontName = "fontSmallSilver", x = display.contentWidth / 2, y = inY,
    text = inText, originX = "center", originY = "top",
    textFlow = "center", charSpacing = -2, lineSpacing = 0, showOrigin = false,
    color = { 255, 255, 255, 255 }
  });

end -- End makeText().


-- ============================================================================
-- Starts the instructions scrolling.
-- ============================================================================
function scene:startScroll()

  utils:log("introScene", "startScroll()");

  -- While here, start the animation of the start game text.
  startGameText:applyAnimation({
    startNow = true, restartOnChange = true, charWise = false,
    frequency = 250, startAlph1 = 0, alphaRange = 1
  });

  -- Total number of milliseconds it will take for the ENTIRE set of
  -- instructions to scroll by.  Remember, the bigger the group is the
  -- faster it will scroll, so adjust this higher to compensate.
  local scrollTime = 60000;

  -- Scroll.
  switchTimer1 = transition.to(page3, {
    time = scrollTime, y = -page3.height,
    onComplete = function()
      page3.y = display.contentHeight + 20;
      utils:xpcall("introScene.lua:Calling startScroll()", scene.startScroll);
    end
  });

  onPage3 = true;

end -- End startScroll().


-- ****************************************************************************
-- ****************************************************************************
-- **********                 EXECUTION BEGINS HERE.                 **********
-- ****************************************************************************
-- ****************************************************************************


utils:log("introScene", "Beginning execution");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;
