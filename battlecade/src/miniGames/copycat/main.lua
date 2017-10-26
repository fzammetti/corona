local miniGameName = "copycat"
local miniGamePath = "miniGames/copycat/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Don't let the weird faces scare you, or so Simon says!" ..
  "||Repeat the sequence when it's your turn as long as you can.";


-- Constants for the modes the game can be in while being played.
scene.MODE_PRE_REMEMBER_DELAY = "pre_remember_delay";
scene.MODE_REMEMBER = "remember";
scene.MODE_REPEAT = "repeat";

-- Flag that tells us whether we're in "remember"" mode (when the sequence is being played) or "repeat"" mode, when
-- the user is expected to repeat the sequence.
scene.mode = scene.MODE_REMEMBER;

-- The current sequence.
scene.sequence = { math.random(1, 6) };

-- Index into the sequence when playing back to point to the next element to play.
scene.sequenceIndex = 1;

-- Counter used to count how many frames are left when highlghting an element during sequence playback.
scene.playDelay = 0;

-- The index of the icon the user is currently pressed down on.
scene.selectedIcon = nil;


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

  local yAdjust = 200;
  local iconWidth = 400;
  local iconHalfWidth = 270;
  local iconHeight = 520;
  local iconHalfHeight = 290;
  local icons1 = self.resMan:newSprite("icons1", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon1_0"), count = 1, time = 9999 }
  });
  icons1.targetID = "1";
  icons1.x = iconHalfWidth;
  icons1.y = iconHalfHeight + yAdjust;
  local icons2 = self.resMan:newSprite("icons2", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon1_1"), count = 1, time = 9999 }
  });
  icons2.x = iconHalfWidth;
  icons2.y = iconHalfHeight + yAdjust;
  icons2.isVisible = false;
  local icons3 = self.resMan:newSprite("icons3", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon2_0"), count = 1, time = 9999 }
  });
  icons3.targetID = "2";
  icons3.x = display.contentWidth - iconHalfWidth;
  icons3.y = iconHalfHeight + yAdjust;
  local icons4 = self.resMan:newSprite("icons4", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon2_1"), count = 1, time = 9999 }
  });
  icons4.x = display.contentWidth - iconHalfWidth;
  icons4.y = iconHalfHeight + yAdjust;
  icons4.isVisible = false;
  local icons5 = self.resMan:newSprite("icons5", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon3_0"), count = 1, time = 9999 }
  });
  icons5.targetID = "3";
  icons5.x = icons1.x;
  icons5.y = icons1.y + iconHeight;
  local icons6 = self.resMan:newSprite("icons6", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon3_1"), count = 1, time = 9999 }
  });
  icons6.x = icons2.x;
  icons6.y = icons2.y + iconHeight;
  icons6.isVisible = false;
  local icons7 = self.resMan:newSprite("icons7", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon4_0"), count = 1, time = 9999 }
  });
  icons7.targetID = "4";
  icons7.x = icons3.x;
  icons7.y = icons3.y + iconHeight;
  local icons8 = self.resMan:newSprite("icons8", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon4_1"), count = 1, time = 9999 }
  });
  icons8.x = icons4.x;
  icons8.y = icons4.y + iconHeight;
  icons8.isVisible = false;
  local icons9 = self.resMan:newSprite("icons9", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon5_0"), count = 1, time = 9999 }
  });
  icons9.targetID = "5";
  icons9.x = icons5.x;
  icons9.y = icons5.y + iconHeight;
  local icons10 = self.resMan:newSprite("icons10", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon5_1"), count = 1, time = 9999 }
  });
  icons10.x = icons6.x;
  icons10.y = icons6.y + iconHeight;
  icons10.isVisible = false;
  local icons11 = self.resMan:newSprite("icons11", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon6_0"), count = 1, time = 9999 }
  });
  icons11.targetID = "6";
  icons11.x = icons7.x;
  icons11.y = icons7.y + iconHeight;
  local icons12 = self.resMan:newSprite("icons12", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "default", start = sheetInfo:getFrameIndex("icon6_1"), count = 1, time = 9999 }
  });
  icons12.x = icons8.x;
  icons12.y = icons8.y + iconHeight;
  icons12.isVisible = false;

  -- Load sounds.
  for i = 1, 6, 1 do
    self.resMan:loadSound("tones" .. i, miniGamePath .. "tone-" .. i .. ".wav");
  end
  self.resMan:loadSound("buzzer", self.sharedResourcePath .. "buzzer.wav");

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

    -- Attach touch handlers to icons.
    for i = 1, 12, 1 do
      self.resMan:getSprite("icons" .. i):addEventListener("touch", function(inEvent) self:touchHandler(inEvent); end );
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

  if self.mode == self.MODE_REMEMBER then
    -- Highlight the current element in the sequence.
    if self.playDelay == 0 then
      self.resMan:getSprite("icons" .. (self.sequence[self.sequenceIndex] * 2) - 1).isVisible = false;
      self.resMan:getSprite("icons" .. self.sequence[self.sequenceIndex] * 2).isVisible = true;
      audio.play(self.resMan:getSound("tones" .. self.sequence[self.sequenceIndex]));
    end
    self.playDelay = self.playDelay + 1;
    if self.playDelay == 20 then
      -- After it's been highlighted for a second, reset to it's non-highlighted state.
      self.resMan:getSprite("icons" .. (self.sequence[self.sequenceIndex] * 2) - 1).isVisible = true;
      self.resMan:getSprite("icons" .. self.sequence[self.sequenceIndex] * 2).isVisible = false;
      -- Move on to the next in the sequence if any.
      self.playDelay = 0;
      self.sequenceIndex = self.sequenceIndex + 1;
      if self.sequenceIndex > #self.sequence then
        self.mode = self.MODE_REPEAT;
        self.sequenceIndex = 1;
      end
    end
  elseif self.mode == self.MODE_PRE_REMEMBER_DELAY then
    self.playDelay = self.playDelay + 1;
    if self.playDelay == 15 then
      self.playDelay = 0;
      self.mode = self.MODE_REMEMBER;
    end
  end

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
-- Function that handles touch events.  Note that this game only cares about touch events on specific objects,
-- which have event listeners hooked up to this function.  The global touch() handler is just empty here.
--
-- @param inEvent The event object.
--
function scene:touchHandler(inEvent)

  if self.gameState == self.STATE_PLAYING and self.mode == self.MODE_REPEAT then
    if inEvent.phase == "began" then
      self.selectedIcon = tonumber(inEvent.target.targetID);
      self.resMan:getSprite("icons" .. self.selectedIcon * 2).isVisible = true;
      self.resMan:getSprite("icons" .. (self.selectedIcon * 2) - 1).isVisible = false;
      audio.play(self.resMan:getSound("tones" .. self.selectedIcon));
    elseif inEvent.phase == "ended" then
      -- If the user taps too aggressively and gets the timing just "right" we can wind up processing an end event
      -- without having processed a began event.  In this case, we need to abort because otherwise we'll throw an
      -- error due to self.selectedIcon being nil here.
      if self.selectedIcon == nil then
        return true;
      end
      self.resMan:getSprite("icons" .. self.selectedIcon * 2).isVisible = false;
      self.resMan:getSprite("icons" .. (self.selectedIcon * 2) - 1).isVisible = true;
      -- See if this selection matched the next in the sequence.
      if self.selectedIcon == self.sequence[self.sequenceIndex] then
        -- Ok, it matched, now see if we reached the end of the sequence.  If so, add another element to the sequence
        -- and flip to "remember" mode.  If not, we'll just await further user input.
        self.updateScore(self, 5);
        self.sequenceIndex = self.sequenceIndex + 1;
        if self.sequenceIndex > #self.sequence then
          self.sequenceIndex = 1;
          table.insert(self.sequence, math.random(1, 6));
          self.mode = self.MODE_PRE_REMEMBER_DELAY;
        else
        end
      else
        -- It didn't match, restart game (after a slight delay).
        self.updateScore(self, -50);
        audio.play(self.resMan:getSound("buzzer"), {
          onComplete = function(inEvent)
            self.sequence = { math.random(1, 6) };
            self.sequenceIndex = 1;
            self.mode = self.MODE_PRE_REMEMBER_DELAY;
          end
        });

      end
    end
  end

  return true;

end -- End touchHandler().


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
