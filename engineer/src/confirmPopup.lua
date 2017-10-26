local confirmFadeRect;
local confirmCaption;
local icoNo;
local txtNo;
local icoYes;
local txtYes;
local group;
local onYes;
local onNo;
local confirmDG;


-- ============================================================================
-- Shows a popup confirmation box with  Yes and No buttons.
--
-- @param inGroup   A reference to the current DisplayGroup to fade behind
--                  the popup.
-- @param inCaption The caption (text message) to show in the popup.
-- @param inYes     Function to call when Yes is tapped.
-- Wparam inNo      Function to call when No is tapped.
-- ============================================================================
function showConfirmPopup(inGroup, inCaption, inYes, inNo)

  utils:log("confirmPopup", "showConfirmPopup()");

  -- Flag to switch input events.
  confirmPopupShowing = true;

  -- Fade what's behind us.
  group = inGroup;

  -- Store callbacks.
  onYes = inYes;
  onNo = inNo;

  -- Draw the confirm.

  -- Background.
  confirmFadeRect = display.newRoundedRect(0, 0, 720, 300, 100);
  confirmFadeRect.x = display.contentWidth / 2;
  confirmFadeRect.y = display.contentHeight / 2;
  confirmFadeRect.alpha = .7;
  confirmFadeRect.strokeWidth = 10;
  confirmFadeRect:setStrokeColor(255, 255, 255);
  confirmFadeRect:setFillColor(0, 0, 0);

  -- Caption.
  confirmCaption = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = display.contentWidth / 2, y = (display.contentHeight / 2) - 50,
    text = inCaption,
    originX = "center", originY = "center",
    textFlow = "center", charSpacing = -1, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });

  -- No.
  icoNo = display.newImage("confirmPopup_no.png", true);
  icoNo.x = 200;
  icoNo.y = display.contentHeight / 2 + 80;
  icoNo:addEventListener("touch",
    function(inEvent)
      confirmNoListener(inEvent);
      return true;
    end
  );
  txtNo = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = 250, y = (display.contentHeight / 2) + 83,
    text = "NO", originX = "center", originY = "center",
    textFlow = "center", charSpacing = -1, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  txtNo:addEventListener("touch",
    function(inEvent)
      confirmNoListener(inEvent);
      return true;
    end
  );

  -- Yes.
  icoYes = display.newImage("confirmPopup_yes.png", true);
  icoYes.x = 554;
  icoYes.y = display.contentHeight / 2 + 84;
  icoYes.targetID = "yes";
  icoYes:addEventListener("touch",
    function(inEvent)
      confirmYesListener(inEvent);
      return true;
    end
  );
  txtYes = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = 610, y = (display.contentHeight / 2) + 83,
    text = "YES", originX = "center", originY = "center",
    textFlow = "center", charSpacing = -1, lineSpacing = 0,
    showOrigin = false, color = { 255, 255, 255, 255 }
  });
  txtYes:addEventListener("touch",
    function(inEvent)
      confirmYesListener(inEvent);
      return true;
    end
  );

  -- Add all to group for easy transitioning.
  confirmDG = display.newGroup();
  confirmDG:insert(confirmFadeRect);
  confirmDG:insert(confirmCaption);
  confirmDG:insert(icoNo);
  confirmDG:insert(txtNo);
  confirmDG:insert(icoYes);
  confirmDG:insert(txtYes);

  -- Start transitions.
  confirmDG:setReferencePoint(display.CenterReferencePoint);
  confirmDG.y = -320;
  transition.to(group, { time = 750, alpha = .3 });
  if particleMeter ~= nil then
    transition.to(particleMeter, { time = 750, alpha = .3 });
  end
  transition.to(confirmDG, {
    time = 750, transition = easingX.easeInOutBounce,
    y = display.contentHeight / 2
  });

end -- End showConfirmPopup().


-- ============================================================================
-- Touch listener for No.
--
-- @param inEvent The touch event.
-- ============================================================================
function confirmNoListener(inEvent)

  --utils:log("confirmPopup", "confirmNoListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(txtNo);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(txtNo, true);
    confirmHandleOutcome();
  end

end -- End confirmNoListener().


-- ============================================================================
-- Touch listener for Yes.
--
-- @param inEvent The touch event.
-- ============================================================================
function confirmYesListener(inEvent)

  --utils:log("confirmPopup", "confirmYesListener()");

  if inEvent.phase == "began" then
    display.getCurrentStage():setFocus(inEvent.target);
    applyOrRemoveDownAnimation(txtYes);
  elseif inEvent.phase == "ended" then
    display.getCurrentStage():setFocus(nil);
    applyOrRemoveDownAnimation(txtYes, true);
    confirmHandleOutcome(true);
  end

end -- End confirmYesListener().


-- ============================================================================
-- Handles the outcome of the user tapping either Yes or No.
--
-- @param inYes True is Yes was selected, false if No was selected.
-- ============================================================================
function confirmHandleOutcome(inYes)

  utils:log("confirmPopup", "confirmHandleOutcome()");

  audio.play(sfx.menuBeep);

  transition.to(group, { time = 500, alpha = 1 });
  transition.to(confirmDG, {
    time = 500, transition = easing.inExpo,
    y = -320,
    onComplete = function()

      confirmFadeRect:removeSelf();
      confirmFadeRect = nil;
      textCandy.DeleteText(confirmCaption);
      confirmCaption = nil;
      icoNo:removeSelf();
      icoNo = nil;
      txtNo:removeEventListener("touch", confirmNoListener);
      textCandy.DeleteText(txtNo);
      txtNo = nil;
      icoYes:removeSelf();
      icoYes = nil;
      txtYes:removeEventListener("touch", confirmYesListener);
      textCandy.DeleteText(txtYes);
      txtYes = nil;
      confirmDG:removeSelf();
      confirmDG = nil;
      confirmPopupShowing = false;

      if inYes == true then
        onYes();
      else
        onNo();
      end

    end
  });

end -- End confirmHandleOutcome().
