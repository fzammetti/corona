local cp = { };

cp.username = nil;
cp.numberOfRounds = 3;
cp.gamesPerRound = 3;
cp.showing = false;
cp.scene = nil;


---
-- Create.
--
-- @param inScene The scene.
--
function cp:create(inScene)

  cp.scene = inScene;

  -- Create group for the challenge popup.
  local dg = self.scene.resMan:newDisplayGroup("cpChallengePopup");
  dg.isVisible = false;

  -- Background and banner text.
  local background = self.scene.resMan:newSprite("cpBackground", dg, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("bgTall"), count = 1, time = 9999 }
  );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY + 170;
  local bannerText = self.scene.resMan:newSprite("cpBannerText", dg, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("txtChallengeSomeone"), count = 1, time = 9999 }
  );
  bannerText.x = display.contentCenterX;
  bannerText.y = display.contentCenterY - 425;

  -- An amount to push everything within the popup down and left.
  local xAdj = -10;
  local yAdj = 130;

  -- Instructions.
  self.scene.resMan:newTextCandy("cpTextInstructions", {
    parentGroup = dg, fontName = "fontInstructions", originY = "TOP", wrapWidth = background.width - 500,
    x = display.contentCenterX + xAdj, y = (background.y - (background.height / 2) + 4) + yAdj + 230,
    textFlow = "CENTER", text = "Who do you want to challenge?"
  });

  -- Username.
  local tfWidth = 500;
  local tfHeight = 100;
  local tfStartX = display.contentCenterX + xAdj;
  local tfStartY = 855;
  local rrWidth = tfWidth + 30;
  local rrHeightPad = tfHeight + 30;
  local rrCornerRadius = 20;
  local rrStrokeWidth = 6;
  local rrUsername = self.scene.resMan:newRoundedRect("cpRRUsername",
    dg, tfStartX, tfStartY + yAdj, rrWidth, rrHeightPad, rrCornerRadius
  );
  rrUsername.strokeWidth = rrStrokeWidth;
  rrUsername:setFillColor(0, 0, 0, 0);
  rrUsername:setStrokeColor(255, 255, 255);
  local tfUsername = self.scene.resMan:newTextField("cpTFUsername", tfStartX, tfStartY + yAdj, tfWidth, tfHeight);
  tfUsername.text = "";
  tfUsername.hasBackground = false;
  tfUsername.placeholder = "Username";
  tfUsername.maxLength = 10;
  tfUsername:setTextColor(1, 1, 1);
  tfUsername.isVisible = false;
  dg:insert(tfUsername);

  -- Number of rounds.
  local xStart = 280 + xAdj;
  local xSpacing = 120;
  local numberOfRoundsYStart = 950;
  local textNumberOfRounds = self.scene.resMan:newTextCandy("cpTextNumberOfRounds", {
    parentGroup = dg, fontName = "fontInstructions", x = display.contentCenterX + xAdj,
    originY = "TOP", y = numberOfRoundsYStart + yAdj, text = "How Many Rounds?"
  });
  local numX = xStart;
  local textNumberOfRounds1 = self.scene.resMan:newTextCandy("cpTextNumberOfRounds1", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = numberOfRoundsYStart + 90 + yAdj, text = "1"
  });
  textNumberOfRounds1.objName = "numberOfRounds1";
  numX = numX + xSpacing;
  local textNumberOfRounds2 = self.scene.resMan:newTextCandy("cpTextNumberOfRounds2", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = numberOfRoundsYStart + 90 + yAdj, text = "2"
  });
  textNumberOfRounds2.objName = "numberOfRounds2";
  numX = numX + xSpacing;
  local textNumberOfRounds3 = self.scene.resMan:newTextCandy("cpTextNumberOfRounds3", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = numberOfRoundsYStart + 90 + yAdj, text = "3"
  });
  textNumberOfRounds3.objName = "numberOfRounds3";
  numX = numX + xSpacing;
  local textNumberOfRounds4 = self.scene.resMan:newTextCandy("cpTextNumberOfRounds4", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = numberOfRoundsYStart + 90 + yAdj, text = "4"
  });
  textNumberOfRounds4.objName = "numberOfRounds4";
  numX = numX + xSpacing;
  local textNumberOfRounds5 = self.scene.resMan:newTextCandy("cpTextNumberOfRounds5", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = numberOfRoundsYStart + 90 + yAdj, text = "5"
  });
  textNumberOfRounds5.objName = "numberOfRounds5";
  local numberOfRoundsSelector = self.scene.resMan:newCircle("cpNumberOfRoundsSelector",
    dg, self.scene.resMan:getTextCandy("cpTextNumberOfRounds3").x + 10, numberOfRoundsYStart + 140 + yAdj, 54
  );
  numberOfRoundsSelector:setFillColor(0, 0, 0, 0);
  numberOfRoundsSelector.strokeWidth = 6;

  -- Games per round.
  local gamesPerRoundYStart = 1170;
  local textGamesPerRound = self.scene.resMan:newTextCandy("cpTextGamesPerRound", {
    parentGroup = dg, fontName = "fontInstructions", x = display.contentCenterX + xAdj,
    originY = "TOP", y = gamesPerRoundYStart + yAdj, text = "Games Per Round?"
  });
  numX = xStart;
  local textGamesPerRound1 = self.scene.resMan:newTextCandy("cpTextGamesPerRound1", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = gamesPerRoundYStart + 90 + yAdj, text = "1"
  });
  textGamesPerRound1.objName = "gamesPerRound1";
  numX = numX + xSpacing;
  local textGamesPerRound2 = self.scene.resMan:newTextCandy("cpTextGamesPerRound2", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = gamesPerRoundYStart + 90 + yAdj, text = "2"
  });
  textGamesPerRound2.objName = "gamesPerRound2";
  numX = numX + xSpacing;
  local textGamesPerRound3 = self.scene.resMan:newTextCandy("cpTextGamesPerRound3", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = gamesPerRoundYStart + 90 + yAdj, text = "3"
  });
  textGamesPerRound3.objName = "gamesPerRound3";
  numX = numX + xSpacing;
  local textGamesPerRound4 = self.scene.resMan:newTextCandy("cpTextGamesPerRound4", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = gamesPerRoundYStart + 90 + yAdj, text = "4"
  });
  textGamesPerRound4.objName = "gamesPerRound4";
  numX = numX + xSpacing;
  local textGamesPerRound5 = self.scene.resMan:newTextCandy("cpTextGamesPerRound5", {
    parentGroup = dg, fontName = "fontPlain",
    x = numX, originY = "TOP", y = gamesPerRoundYStart + 90 + yAdj, text = "5"
  });
  textGamesPerRound5.objName = "gamesPerRound5";
  local gamesPerRoundSelector = self.scene.resMan:newCircle("cpGamesPerRoundSelector",
    dg, self.scene.resMan:getTextCandy("cpTextGamesPerRound3").x + 10, gamesPerRoundYStart + 140 + yAdj, 54
  );
  gamesPerRoundSelector:setFillColor(0, 0, 0, 0);
  gamesPerRoundSelector.strokeWidth = 6;

  -- Buttons.
  local btnCancel = self.scene.resMan:newSprite("cpBtnCancel", dg, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("btnCancel"), count = 1, time = 9999 }
  );
  btnCancel.x = display.contentCenterX - 110;
  btnCancel.y = display.contentCenterY + 640;
  local btnOk = self.scene.resMan:newSprite("cpBtnOk", dg, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("btnOk"), count = 1, time = 9999 }
  );
  btnOk.x = display.contentCenterX + 190;
  btnOk.y = display.contentCenterY + 640;
  btnOk.alpha = 0.5;

end -- End create().


---
-- Show.
--
function cp:show()

  -- Listeners for number of rounds.
  self.scene.resMan:getTextCandy("cpTextNumberOfRounds1"):addEventListener("touch",
    function(inEvent)
      self:numberOfRoundsHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextNumberOfRounds2"):addEventListener("touch",
    function(inEvent)
      self:numberOfRoundsHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextNumberOfRounds3"):addEventListener("touch",
    function(inEvent)
      self:numberOfRoundsHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextNumberOfRounds4"):addEventListener("touch",
    function(inEvent)
      self:numberOfRoundsHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextNumberOfRounds5"):addEventListener("touch",
    function(inEvent)
      self:numberOfRoundsHandler(inEvent);
    end
  );
  -- Listeners for games per round.
  self.scene.resMan:getTextCandy("cpTextGamesPerRound1"):addEventListener("touch",
    function(inEvent)
      self:gamesPerRoundHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextGamesPerRound2"):addEventListener("touch",
    function(inEvent)
      self:gamesPerRoundHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextGamesPerRound3"):addEventListener("touch",
    function(inEvent)
      self:gamesPerRoundHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextGamesPerRound4"):addEventListener("touch",
    function(inEvent)
      self:gamesPerRoundHandler(inEvent);
    end
  );
  self.scene.resMan:getTextCandy("cpTextGamesPerRound5"):addEventListener("touch",
    function(inEvent)
      self:gamesPerRoundHandler(inEvent);
    end
  );

  -- Button listeners.
  self.scene.resMan:getSprite("cpBtnOk"):addEventListener("touch",
    function(inEvent)
      self:btnOkHandler(inEvent);
    end
  );
  self.scene.resMan:getSprite("cpBtnCancel"):addEventListener("touch",
    function(inEvent)
      self:btnCancelHandler(inEvent);
    end
  );

  -- Attach listeners to native text field.
  self.scene.resMan:getTextField("cpTFUsername"):addEventListener("userInput",
    function(inEvent)
      self:usernameTextInputHandler(inEvent);
      return true;
    end
  );

end -- End show().


---
-- Destroy.
--
function cp:destroy()

  self.scene = nil;

end -- End destroy().


---
-- Handler for touch events on any of the number of rounds numbers on the challenge popup.
--
-- @param inEvent The event object.
--
function cp:numberOfRoundsHandler(inEvent)

  if inEvent.phase == "ended" and self.showing == true then

    audio.play(uiTap);

    if inEvent.target.objName == "numberOfRounds1" then
      self.numberOfRounds = 1;
      self.scene.resMan:getCircle("cpNumberOfRoundsSelector").x =
      self.scene.resMan:getTextCandy("cpTextNumberOfRounds1").x + 2;
    elseif inEvent.target.objName == "numberOfRounds2" then
      self.numberOfRounds = 2;
      self.scene.resMan:getCircle("cpNumberOfRoundsSelector").x =
      self.scene.resMan:getTextCandy("cpTextNumberOfRounds2").x + 10;
    elseif inEvent.target.objName == "numberOfRounds3" then
      self.numberOfRounds = 3;
      self.scene.resMan:getCircle("cpNumberOfRoundsSelector").x =
      self.scene.resMan:getTextCandy("cpTextNumberOfRounds3").x + 10;
    elseif inEvent.target.objName == "numberOfRounds4" then
      self.numberOfRounds = 4;
      self.scene.resMan:getCircle("cpNumberOfRoundsSelector").x =
      self.scene.resMan:getTextCandy("cpTextNumberOfRounds4").x + 10;
    elseif inEvent.target.objName == "numberOfRounds5" then
      self.numberOfRounds = 5;
      self.scene.resMan:getCircle("cpNumberOfRoundsSelector").x =
      self.scene.resMan:getTextCandy("cpTextNumberOfRounds5").x + 10;
    end

  end

end -- End numberOfRoundsHandler().


---
-- Handler for touch events on any of the games per round numbers on the challenge popup.
--
-- @param inEvent The event object.
--
function cp:gamesPerRoundHandler(inEvent)

  if inEvent.phase == "ended" and self.showing == true then

    audio.play(uiTap);

    if inEvent.target.objName == "gamesPerRound1" then
      self.gamesPerRound = 1;
      self.scene.resMan:getCircle("cpGamesPerRoundSelector").x =
      self.scene.resMan:getTextCandy("cpTextGamesPerRound1").x + 2;
    elseif inEvent.target.objName == "gamesPerRound2" then
      self.gamesPerRound = 2;
      self.scene.resMan:getCircle("cpGamesPerRoundSelector").x =
      self.scene.resMan:getTextCandy("cpTextGamesPerRound2").x + 10;
    elseif inEvent.target.objName == "gamesPerRound3" then
      self.gamesPerRound = 3;
      self.scene.resMan:getCircle("cpGamesPerRoundSelector").x =
      self.scene.resMan:getTextCandy("cpTextGamesPerRound3").x + 10;
    elseif inEvent.target.objName == "gamesPerRound4" then
      self.gamesPerRound = 4;
      self.scene.resMan:getCircle("cpGamesPerRoundSelector").x =
      self.scene.resMan:getTextCandy("cpTextGamesPerRound4").x + 10;
    elseif inEvent.target.objName == "gamesPerRound5" then
      self.gamesPerRound = 5;
      self.scene.resMan:getCircle("cpGamesPerRoundSelector").x =
      self.scene.resMan:getTextCandy("cpTextGamesPerRound5").x + 10;
    end

  end

end -- End gamesPerRoundHandler().


---
-- Handler for typing events on the native text fields.
--
-- @param inEvent The event object.
--
function cp:usernameTextInputHandler(inEvent)

  if inEvent.phase == "editing" and self.showing == true then

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

    -- Also, whenever the entry field has a value, enable the Ok button.
    if string.len(inEvent.target.text) ~= 0 then
      self.scene.resMan:getSprite("cpBtnOk").alpha = 1;
    else
      self.scene.resMan:getSprite("cpBtnOk").alpha = 0.5;
    end

  end

end -- End usernameTextInputHandler().


---
-- Handler for touch events on the Cancel button the challenge popup.
--
-- @param inEvent The event object.
--
function cp:btnCancelHandler(inEvent)

  if self.showing == true then
    if inEvent.phase == "began" then
      inEvent.target.fill.effect = "filter.monotone";
      inEvent.target.fill.effect.r = 1;
      display.getCurrentStage():setFocus(inEvent.target);
    elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
      inEvent.target.fill.effect = nil;
      display.getCurrentStage():setFocus(nil);
      audio.play(uiTap);
      -- Fade screen back in and fade challenge popup out.
      self.scene.resMan:getTextField("cpTFUsername").isVisible = false;
      transition.to(self.scene.view, { alpha = 1, duration = 500 });
      transition.to(self.scene.resMan:getDisplayGroup("cpChallengePopup"), {
        time = 500, y = -display.contentHeight, transition = easing.inOutExpo,
        onComplete = function()
          self.scene.resMan:getDisplayGroup("cpChallengePopup").isVisible = false;
          self.showing = false;
        end
      });
    end
  end

end -- End btnCancelHandler().


---
-- Handler for touch events on the Send Invitation item on the challenge popup.
--
-- @param inEvent The event object.
--
function cp:btnOkHandler(inEvent)

  if self.showing == true then
    if inEvent.phase == "began" and inEvent.target.alpha == 1.0 then
      inEvent.target.fill.effect = "filter.monotone";
      inEvent.target.fill.effect.r = 1;
      display.getCurrentStage():setFocus(inEvent.target);
    elseif (inEvent.phase == "ended" or inEvent.phase == "cancelled") and inEvent.target.alpha == 1.0 then
      inEvent.target.fill.effect = nil;
      display.getCurrentStage():setFocus(nil);
      audio.play(uiTap);
      self.scene.resMan:getTextField("cpTFUsername").isVisible = false;
      local opponentUsername = self.scene.resMan:getTextField("cpTFUsername").text;
      serverDelegate:sendInvitation(opponentUsername, self.numberOfRounds, self.gamesPerRound,
        function(inList)
          self.scene.resMan:getTextField("cpTFUsername").text = "";
          if inList == "unknownUser" then
            dialog:show({
              text = "I'm sorry but I can't seem to find that user. Please make sure you have the correct username " ..
                  "and try again.",
              callback = function(inButtonType)
                self.scene.resMan:getTextField("cpTFUsername").isVisible = true;
              end
            });
          elseif inList == nil then
            self.scene.resMan:getTextField("cpTFUsername").isVisible = true;
          else
            self.scene:populateList(inList);
            transition.to(self.scene.view, { alpha = 1, duration = 500 });
            transition.to(self.scene.resMan:getDisplayGroup("cpChallengePopup"), {
              alpha = 0, duration = 500,
              onComplete = function()
                self.showing = false;
              end
            });
          end
        end
      );
    end
  end

end -- End btnOkHandler().


return cp;
