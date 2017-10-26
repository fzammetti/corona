local dialog = { };

dialog.isShowing = false;
dialog.resMan = nil;
dialog.allowButtonClicks = false;


---
-- Show a dialog.
--
-- @param inConfig   A table with the following attributes:
--                     text ........ The text to show in the dialog.
-- @oaran inCallback A function to call when a button is clicked.  Will be passed a string identifying the button
--                   that was clicked (only "ok" right now).
function dialog:show(inConfig)

  -- Reset variables.
  dialog.isShowing = true;
  dialog.allowButtonClicks = false;

  -- Create a ResourceManager instance for this occurance of the dialog.
  self.resMan = utils:newResourceManager();

  -- Background scrim.
  local scrim = self.resMan:newRect("scrim", display.currentStage,
    display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight
  );
  scrim:setFillColor(0, 0, 0, .75);
  scrim:toFront();
  scrim.alpha = 0;
  scrim:addEventListener("tap",
    function()
      return true;
    end
  );
  scrim:addEventListener("touch",
    function()
      return true;
    end
  );

  -- Dialog group and components.
  local dialogGroup = self.resMan:newDisplayGroup("dialogGroup");

  local dialogBackground = self.resMan:newSprite("background", dialogGroup, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("bgTall"), count = 1, time = 9999 }
  );

  local dialogTitle = self.resMan:newSprite("title", dialogGroup, ui2ImageSheet,
    { name = "default", start = ui2SheetInfo:getFrameIndex("txtHeyThereHuman"), count = 1, time = 9999 }
  );
  dialogTitle.x = 0;
  dialogTitle.y = -580;

  local dialogText = self.resMan:newTextCandy("dialogText", {
    parentGroup = dialogGroup, fontName = "fontInstructionsSmaller", originX = "CENTER", originY = "TOP",
    x = display.contentCenterX - 560, y = dialogBackground.y - 240,
    text = inConfig.text, wrapWidth = dialogBackground.width - 460, textFlow = "LEFT",
  });

  local btnOk = self.resMan:newSprite("btnOk", dialogGroup, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("btnOk"), count = 1, time = 9999 }
  );
  btnOk.x = 0;
  btnOk.y = 460;
  btnOk.buttonType = "ok";
  btnOk.buttonCallback = inConfig.callback;
  btnOk:addEventListener("touch",
    function(inEvent)
      if dialog.allowButtonClicks == true then
        if inEvent.phase == "began" then
          inEvent.target.fill.effect = "filter.monotone";
          inEvent.target.fill.effect.r = 1;
          display.getCurrentStage():setFocus(inEvent.target);
        elseif inEvent.phase == "ended" then
          inEvent.target.fill.effect = nil;
          display.getCurrentStage():setFocus(nil);
          audio.play(uiTap);
          dialog.allowButtonClicks = false;
          dialog.selectedButtonType = inEvent.target.buttonType;
          dialog.selectedButtonCallback = inEvent.target.buttonCallback;
          transition.to(self.resMan:getRect("scrim"), { time = 740, alpha = 0 });
          transition.to(self.resMan:getDisplayGroup("dialogGroup"),
            { time = 750, y = -(display.contentHeight * 2), transition = easing.inOutExpo,
              onComplete = function()
                self.resMan:destroyAll();
                dialog.selectedButtonCallback(dialog.selectedButtonType);
              end
            }
          );
          return true;
        end
      end
    end
  );

  -- Put dialog off-screen.
  dialogGroup.x = display.contentCenterX;
  dialogGroup.y = -(display.contentHeight * 2);

  -- Now show it.
  transition.to(scrim, { time = 750, alpha = 1 });
  transition.to(dialogGroup,
    { time = 750, y = display.contentCenterY, transition = easing.inOutBounce,
      onComplete = function(inDialogGroup)
        dialog.allowButtonClicks = true;
      end
    }
  );

end -- End show().


return dialog;
