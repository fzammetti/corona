--utils:log("practiceSelection", "Loaded");

local scene = composer.newScene();

scene.resMan = nil;


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  --utils:log("practiceSelection", "create()");

  self.resMan = utils:newResourceManager();

  -- Back button.
  local btnBack = self.resMan:newSprite("btnBack", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnBack"), count = 1, time = 9999 }
  });
  btnBack.x = display.contentCenterX;
  btnBack.y = display.contentHeight - 100;
btnBack.isVisible = false;

  -- Construct TableView widget.listRowHeight
  local myList = widget.newTableView({
    noLines = true, hideBackground = true, hideScrollBar = true,
    x = display.contentCenterX + 40, y = display.contentCenterY + 120,
    width = display.contentWidth - 200, height = 1500,
    onRowRender = function(inEvent)
      local row = inEvent.row;
      local index = row.index;
      -- Screenshot.
      local screenshot = display.newSprite(row, screenshotsImageSheet, {
        { name = "default",
          start = screenshotsSheetInfo:getFrameIndex(gameList[index].internalName),
          count = 1, time = 9999
        },
      });
      screenshot.anchorX = 0;
      screenshot.anchorY = 0;
      screenshot.x = 0;
      screenshot.y = 18;
      -- Name.
      local nameText = display.newText(row, row.params.caption, 260, 130, globalNativeFont, 64);
      nameText.anchorX = -0.5;
      nameText.anchorY = 0;
      nameText:setFillColor(255, 255, 255);
      return true;
    end,
    onRowTouch = function(inEvent)
      if inEvent.phase == "tap" or inEvent.phase == "release" then
        self:gameSelectedHandler(inEvent.target.params);
      end
    end
  });
  self.view:insert(myList);
  -- Populate TableView.
  for i = 1, #gameList do
    myList:insertRow({
      rowHeight = 340,
      rowColor = {
        default = { 0, 0, 0, 0 },
        over = { 255, 0, 0 }
      };
      isCategory = false,
      params = gameList[i]
    });
  end

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  --utils:log("practiceSelection", "show()");

  if inEvent.phase == "did" then

    --utils:log("practiceSelection", "show(): did");

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

  --utils:log("practiceSelection", "hide()");

  if inEvent.phase == "did" then

    --utils:log("practiceSelection", "hide(): did");

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

  --utils:log("practiceSelection", "destroy()");

  self.resMan:destroyAll();
  self.resMan = nil;

end -- End destroy().


---
-- Handler for the enterFrame event.
--
-- @param inEvent The event object.
--
function scene:enterFrame(inEvent)
end -- End enterFrame().


---
-- Handler for touch events on a selected game
--
-- @param inGameDescriptor An object that describes the selected game.
--
function scene:gameSelectedHandler(inGameDescriptor)

  audio.play(uiTap);
  textTitle:stopAnimation();
  textTitle.isVisible = false;
  composer.gotoScene(
    "miniGames." .. inGameDescriptor.internalName .. ".main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME
  );

end -- End gameSelectedHandler().


---
-- Handler for touch events on the Back item.
--
-- @param inEvent The event object.
--
function scene:btnBackTouchHandler(inEvent)

  if inEvent.phase == "began" then
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);
  elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End btnBackHandler().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("practiceSelection", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
