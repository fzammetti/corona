local miniGameName = "bubbleTrouble";
local miniGamePath = "miniGames/bubbleTrouble/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);


-- Game instructions.
scene.instructions = "Relieves stress? We'll see! Pop as many bubbles as you can before time runs out." ..
"||Tap bubbles to pop them.";

-- How many bubbles have been popped so far.
scene.numPopped = 0;

-- How many bubbles horizontal and vertically.
scene.bubblesX = 8;
scene.bubblesY = 12;


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


  self.parent.create(self, inEvent);
  --utils:log(self.miniGameName, "create()");

  -- Load graphics.

  local imageSheet, sheetInfo = self.resMan:newImageSheet(
    "imageSheet", "miniGames." .. miniGameName .. ".imageSheet", miniGamePath .. "imageSheet.png"
  );

  local i = 1;
  for y = 1, self.bubblesY, 1 do
    for x = 1, self.bubblesX, 1 do
      local s = self.resMan:newSprite("bubbles" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
        { name = "unpopped", start = sheetInfo:getFrameIndex("bubble_unpopped"), count = 1, time = 9999 },
        { name = "popped", start = sheetInfo:getFrameIndex("bubble_popped"), count = 1, time = 9999 }
      });
      s.x = ((x - 1) * s.width) + ((s.width / 2) * 2);
      s.y = ((y - 1) * s.width) + 300;
      i = i + 1;
    end
  end

  -- Load sounds.

  self.resMan:loadSound("pop", self.sharedResourcePath .. "pop.wav");
  self.resMan:loadSound("win", self.sharedResourcePath .. "harp.wav");

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  self.parent.show(self, inEvent);

  if inEvent.phase == "did" then

    --utils:log(self.miniGameName, "show(): did");

    for i = 1, self.bubblesY * self.bubblesX, 1 do
      self.resMan:getSprite("bubbles" .. i):addEventListener("touch",
        function(inEvent) self:bubbleTouchHandler(inEvent); end
      );
    end

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  self.parent.hide(self, inEvent);

  if inEvent.phase == "did" then

    --utils:log(self.miniGameName, "hide(): did");

  end

end -- End hide().


---
-- Handler for the destroy event.
--
-- @param inEvent The event object.
--
function scene:destroy(inEvent)

  self.parent.destroy(self, inEvent);

  --utils:log(self.miniGameName, "destroy()");

end -- End destroy().


---
-- Called when the menu is triggered (either from it being shown or hidden).
--
function scene:menuTriggered()
end -- End menuTriggered().


---
-- Called when the starting countdown begins.
--
function scene:countdownStartEvent()
end -- End countdownStartEvent().


---
-- Called right after "GO!" is displayed to start a game.
--
function scene:startEvent()
end -- End startEvent().


---
-- Called right before "GAME OVER" is shown to end a game.
--
function scene:endEvent()
end -- End endEvent().


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

  self.parent.enterFrame(self, inEvent);

end -- End enterFrame().


--- ====================================================================================================================
--  ====================================================================================================================
--  Touch Handler(s)
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Function that handles touch events on the screen generally.
--
-- @param inEvent The event object.
--
function scene:touch(inEvent)
end -- End touch().


---
-- Handles touches on a bubble.
--
-- @param inEvent The event object.
--
function scene:bubbleTouchHandler(inEvent)

  if inEvent.phase == "ended" then

    -- Get a reference to the selected symbol.
    local bubble = inEvent.target;

    -- If it's not popped already then pop it now.
    if bubble.sequence == "unpopped" then
      bubble:setSequence("popped");
      self.numPopped = self.numPopped + 1;
      self.updateScore(self, 2);
      audio.play(self.resMan:getSound("pop"));
      -- If all have been popped then reset.
      if self.numPopped == self.bubblesY * self.bubblesX then
        audio.play(self.resMan:getSound("win"));
        self.numPopped = 0;
        self.updateScore(self, 50);
        for i = 1, self.bubblesY * self.bubblesX, 1 do
          self.resMan:getSprite("bubbles" .. i):setSequence("unpopped");
        end
      end
    end

  end -- End ended event.

end -- End bubbleTouchHandler().


--- ====================================================================================================================
--  ====================================================================================================================
--  Collision Handler
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Function that handles collision events.
--
-- @param inEvent The event object.
--
function scene:collision(inEvent)
end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


--- ====================================================================================================================
--  ====================================================================================================================
--  ====================================================================================================================
--  ====================================================================================================================


--utils:log(miniGameName, "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
