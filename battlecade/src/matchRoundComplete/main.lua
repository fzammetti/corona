--utils:log("matchRoundComplete", "Loaded");

local scene = composer.newScene();

scene.resMan = nil;


--- ====================================================================================================================
--  ====================================================================================================================
--  Scene lifecycle Event Handlers
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  --utils:log("matchRoundComplete", "create()");

  self.resMan = utils:newResourceManager();

  local background = self.resMan:newSprite("background", self.view, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("bgSmall"), count = 1, time = 9999 }
  );
  background.x = display.contentCenterX;
  background.y = display.contentCenterY;

  local title = self.resMan:newSprite("title", self.view, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("txtGameOver"), count = 1, time = 9999 }
  );
  title.x = display.contentCenterX;
  title.y = display.contentCenterY - 310;

  self.resMan:newTextCandy("finishedText", {
    parentGroup = self.view, fontName = "fontPlain",
    x = display.contentCenterX, originY = "TOP", y = display.contentCenterY - 40,
    text = "", originX = "CENTER", originY = "CENTER", textFlow = "CENTER"
  });

  local btnAllDone = self.resMan:newSprite("btnAllDone", self.view, uiImageSheet,
    { name = "default", start = uiSheetInfo:getFrameIndex("btnAllDone"), count = 1, time = 9999 }
  );
  btnAllDone.x = display.contentCenterX - 10;
  btnAllDone.y = display.contentCenterY + 200;

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  if inEvent.phase == "did" then

    --utils:log("matchRoundComplete", "show(): did");

    self.resMan:getSprite("btnAllDone"):addEventListener("touch",
      function(inEvent)
        self:btnAllDoneTouchHandler(inEvent);
        return true;
      end
    );

    -- Attach listener for enterFrame event.
    Runtime:addEventListener("enterFrame", self);

    -- Call server to update the status of the match. This calls the callback here, passing it the outcome of the
    -- update.
    serverDelegate:updateMatchStatus(
      function(inResult)

        if inResult == nil then
          composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
          return;
        end

        -- Is this player the opponent?
        local isOpponent = false;
        if currentMatch.opponent == gameState.username then
          isOpponent = true;
        end

        local finishedText = self.resMan:getTextCandy("finishedText");

        -- Display a message about the outcome.
        if inResult == "0" then
          if isOpponent == true then
            finishedText:setText("It's|" .. utils:trim(currentMatch.initiator) .. "'s|turn");
          else
            finishedText:setText("It's|" .. utils:trim(currentMatch.opponent) .. "'s|turn");
          end
        elseif inResult == "i" then
          if isOpponent == true then
            finishedText:setText("You Lost!");
          else
            finishedText:setText("You Won!");
          end
        elseif inResulte == "o" then
          if isOpponent == true then
            finishedText:setText("You Won!");
          else
            finishedText:setText("You Lost!");
          end
          finishedText:setText("You Won!");
        elseif inResult == "t" then
          finishedText:setText("Match ended|in a tie!");
        end

      end
    );

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  if inEvent.phase == "did" then

    --utils:log("matchRoundComplete", "hide(): did");

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

  --utils:log("matchRoundComplete", "destroy()");

  self.resMan:destroyAll();

end -- End destroy().


--- ====================================================================================================================
--  ====================================================================================================================
--  EnterFrame
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the enterFrame event.
--
-- @param inEvent The event object.
--
function scene:enterFrame(inEvent)
end -- End enterFrame().


--- ====================================================================================================================
--  ====================================================================================================================
--  Touch Handlers
--  ====================================================================================================================
--  ====================================================================================================================



---
-- Handler for touch events on the All Done button.
--
-- @param inEvent The event object.
--
function scene:btnAllDoneTouchHandler(inEvent)

  if inEvent.phase == "ended" then
    audio.play(uiTap);
    composer.gotoScene("challengeLobby.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End btnAllDoneTouchHandler().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("matchRoundComplete", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
