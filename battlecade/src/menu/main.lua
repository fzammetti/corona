--utils:log("menu", "Loaded");

local scene = composer.newScene();

scene.resMan = nil;


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  --utils:log("menu", "create()");

  self.resMan = utils:newResourceManager();

  -- Create menu items.
  local btnChallenge = self.resMan:newSprite("btnChallenge", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnChallenge"), count = 1, time = 9999 }
  });
  btnChallenge.x = display.contentCenterX;
  btnChallenge.y = display.contentCenterY - 200;
  local btnPractice = self.resMan:newSprite("btnPractice", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnPractice"), count = 1, time = 9999 }
  });
  btnPractice.x = display.contentCenterX;
  btnPractice.y = display.contentCenterY + 200;
  self.resMan:newTextCandy("textCredits", {
    parentGroup = self.view, fontName = "fontPlain", x = display.contentCenterX, y = display.contentCenterY + 800,
    text = "Credits"
  });

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  if inEvent.phase == "did" then

    --utils:log("menu", "show(): did");

    if textTitle.isVisible == false then
      textTitle.isVisible = true;
      textTitle:startAnimation();
    end

    -- Attach listeners to TextCandy objects.
    self.resMan:getSprite("btnChallenge"):addEventListener("touch",
      function(inEvent)
        self:btnChallengeTouchHandler(inEvent);
        return true;
      end
    );
    self.resMan:getSprite("btnPractice"):addEventListener("touch",
      function(inEvent)
        self:btnPracticeTouchHandler(inEvent);
        return true;
      end
    );
    self.resMan:getTextCandy("textCredits"):addEventListener("touch",
      function(inEvent)
        self:textCreditsTouchHandler(inEvent);
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

    --utils:log("menu", "hide(): did");

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

  --utils:log("menu", "destroy()");

  self.resMan:destroyAll();

end -- End destroy().


---
-- Handler for the enterFrame event.
--
-- @param inEvent The event object.
--
function scene:enterFrame(inEvent)
end -- End enterFrame().


---
-- Handler for touch events on the Challenge item.
--
-- @param inEvent The event object.
--
function scene:btnChallengeTouchHandler(inEvent)

  if inEvent.phase == "began" then
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);
  elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    if gameState.username == nil then
      composer.gotoScene("newUserRegistration.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
    else
      composer.gotoScene("challengeLobby.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
    end
  end

end -- End btnChallengeTouchHandler().


---
-- Handler for touch events on the Practice item.
--
-- @param inEvent The event object.
--
function scene:btnPracticeTouchHandler(inEvent)

  if inEvent.phase == "began" then
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);
  elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    composer.gotoScene("practiceSelection.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End btnPracticeTouchHandler().


---
-- Handler for touch events on the Credits item.
--
-- @param inEvent The event object.
--
function scene:textCreditsTouchHandler(inEvent)

  if inEvent.phase == "ended" then
    audio.play(uiTap);
    composer.gotoScene("credits.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End textCreditsTouchHandler().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("menu", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
