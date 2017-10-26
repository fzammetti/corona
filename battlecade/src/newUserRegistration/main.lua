--utils:log("newUserRegistration", "Loaded");

local scene = composer.newScene();

scene.resMan = nil;


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  --utils:log("newUserRegistration", "create()");

  self.resMan = utils:newResourceManager();

  local totalYAdj = 50;

  -- Instructions text.
  self.resMan:newTextCandy("textInstructions", {
    parentGroup = self.view, fontName = "fontInstructions", lineSpacing = -14, textFlow = "CENTER",
    x = display.contentCenterX, originY = "TOP", y = 320 + totalYAdj, wrapWidth = display.contentWidth - 80,
    text = "To play challenges against others you need to be registered.  If you've already registered then log " ..
      "in below.  If this is your first time here then choose a username and password.";
  });

  local tfWidth = display.contentWidth - 100;
  local tfHeight = 100;
  local tfStartX = display.contentCenterX;
  local tfStartY = 800 + totalYAdj;
  local tfYInc = 150;
  local rrWidth = tfWidth + 30;
  local rrHeightPad = tfHeight + 30;
  local rrCornerRadius = 20;
  local rrStrokeWidth = 6;

  -- Username text field.
  local rrUsername = self.resMan:newRoundedRect(
    "rrUsername", self.view, tfStartX, tfStartY, rrWidth, rrHeightPad, rrCornerRadius
  );
  rrUsername.strokeWidth = rrStrokeWidth;
  rrUsername:setFillColor(0, 0, 0, 0);
  rrUsername:setStrokeColor(255, 255, 255);
  local tfUsername = self.resMan:newTextField("tfUsername", tfStartX, tfStartY, tfWidth, tfHeight);
  tfUsername.text = "";
  tfUsername.hasBackground = false;
  tfUsername.placeholder = "Username";
  tfUsername.maxLength = 10;
  tfUsername:setTextColor(1, 1, 1);
  tfUsername.isVisible = false;
  self.view:insert(tfUsername);

  -- Password text field.
  local rrPassword = self.resMan:newRoundedRect(
    "rrPassword", self.view, tfStartX, self.resMan:getTextField("tfUsername").y + tfYInc,
    rrWidth, rrHeightPad, rrCornerRadius
  );
  rrPassword.strokeWidth = rrStrokeWidth;
  rrPassword:setFillColor(0, 0, 0, 0);
  rrPassword:setStrokeColor(255, 255, 255);
  local tfPassword = self.resMan:newTextField(
    "tfPassword", tfStartX, self.resMan:getTextField("tfUsername").y + tfYInc, tfWidth, tfHeight
  );
  tfPassword.text = "";
  tfPassword.hasBackground = false;
  tfPassword.placeholder = "Password";
  tfPassword.maxLength = 25;
  tfPassword:setTextColor(1, 1, 1);
  tfPassword.isVisible = false;
  self.view:insert(tfPassword);

  -- Go button.
  local btnGo = self.resMan:newSprite("btnGo", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnGo"), count = 1, time = 9999 }
  });
  btnGo.x = display.contentCenterX;
  btnGo.y = 1150 + totalYAdj;
  btnGo.alpha = 0.5;

  -- Back button.
  local btnBack = self.resMan:newSprite("btnBack", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnBack"), count = 1, time = 9999 }
  });
  btnBack.x = display.contentCenterX;
  btnBack.y = display.contentHeight - 100;

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  if inEvent.phase == "did" then

    --utils:log("newUserRegistration", "show(): did");

    if textTitle.isVisible == false then
      textTitle.isVisible = true;
      textTitle:startAnimation();
    end

    -- Attach listeners to TextCandy objects.
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

    -- Attach listeners to native text fields.
    self.resMan:getTextField("tfUsername"):addEventListener("userInput",
      function(inEvent)
        self:textInputHandler(inEvent);
        return true;
      end
    );
    self.resMan:getTextField("tfPassword"):addEventListener("userInput",
      function(inEvent)
        self:textInputHandler(inEvent);
        return true;
      end
    );

    -- Attach listener for enterFrame event.
    Runtime:addEventListener("enterFrame", self);

    self.resMan:getTextField("tfUsername").isVisible = true;
    self.resMan:getTextField("tfPassword").isVisible = true;

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  if inEvent.phase == "did" then

    --utils:log("newUserRegistration", "hide(): did");

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

  --utils:log("newUserRegistration", "destroy()");

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
-- Handler for touch events on the Back button.
--
-- @param inEvent The event object.
--
function scene:btnBackTouchHandler(inEvent)

  if inEvent.phase == "began" then
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);
  elseif inEvent.phase == "ended" then
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    self.resMan:getTextField("tfUsername").isVisible = false;
    self.resMan:getTextField("tfPassword").isVisible = false;
    composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End btnBackTouchHandler().


---
-- Handler for typing events on the native text fields.
--
-- @param inEvent The event object.
--
function scene:textInputHandler(inEvent)

  if inEvent.phase == "editing" then

    -- Limit to these characters.
    for i = 1, string.len(inEvent.text), 1 do
      if string.find(
        "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789!#$*()-_'.",
        string.sub(inEvent.text, i, i), 1, true
      ) == nil then
        inEvent.target.text = inEvent.oldText;
      end
    end

    -- Ensure it doesn't exceed the max allowed.
    if string.len(inEvent.text) > inEvent.target.maxLength then
      inEvent.target.text = inEvent.oldText;
    end

    -- Also, whenever all entry fields have a value, enable the Register text.
    if string.len(self.resMan:getTextField("tfUsername").text) ~= 0 and
      string.len(self.resMan:getTextField("tfPassword").text) ~= 0 then
      self.resMan:getSprite("btnGo").alpha = 1;
    else
      self.resMan:getSprite("btnGo").alpha = 0.5;
    end

  end

end -- End textInputHandler().


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
    self.resMan:getTextField("tfUsername").isVisible = false;
    self.resMan:getTextField("tfPassword").isVisible = false;
    serverDelegate:registerUser(
      self.resMan:getTextField("tfUsername").text, self.resMan:getTextField("tfPassword").text,
      function(inResult)
        self.resMan:getTextField("tfUsername").text = "";
        self.resMan:getTextField("tfPassword").text = "";
        if inResult == "registered" then
          dialog:show({
            text = "Success!  You are now registered and logged in and can enter the Challenge Lobby. " ..
              "I'll take you there right now.",
            callback = function(inButtonType)
              composer.gotoScene("challengeLobby.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
            end
          });
        elseif inResult == "alreadyRegistered" then
          dialog:show({
            text = "I'm sorry but that username is already taken. If it's yours then please check the password " ..
            "and try again. If you DID NOT previously register it then please choose a new username.",
            callback = function(inButtonType)
              self.resMan:getTextField("tfUsername").isVisible = true;
              self.resMan:getTextField("tfPassword").isVisible = true;
            end
          });
        elseif inResult == "loggedIn" then
          dialog:show({
            text = "Welcome back, " .. utils:trim(serverDelegate.username) .. "! " ..
              "You are now logged in and can enter the Challenge Lobby. I'll take you there right now.",
            callback = function(inButtonType)
              composer.gotoScene("challengeLobby.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
            end
          });
        end
      end
    );
  end

end -- End btnGoTouchHandler().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("newUserRegistration", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
