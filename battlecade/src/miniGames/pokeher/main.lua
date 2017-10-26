local miniGameName = "pokeher";
local miniGamePath = "miniGames/pokeher/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Hey Moe! She might get so mad her face turns red, or she'll laugh at you!" ..
  "||Tap the eye that opens, but not the eye that stays closed.";


-- Count of how many frames have elapsed since we last changed the face.
scene.framesSinceLastChange = 0;


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

  -- The face itself.
  local face = self.resMan:newSprite("face", self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
    { name = "neutral", start = sheetInfo:getFrameIndex("neutral"), count = 1, time = 9999 },
    { name = "left", start = sheetInfo:getFrameIndex("left"), count = 1, time = 9999 },
    { name = "right", start = sheetInfo:getFrameIndex("right"), count = 1, time = 9999 },
    { name = "hit", start = sheetInfo:getFrameIndex("hit"), count = 1, time = 9999 },
    { name = "miss", start = sheetInfo:getFrameIndex("miss"), count = 1, time = 9999 }
  });
  face.xScale = 2;
  face.yScale = 2;
  face.x = display.contentCenterX;
  face.y = display.contentCenterY;
  face:setSequence("neutral");
  face:play();

  -- Two touch targets over the eyes.
  local touchTargetLeftEye = self.resMan:newCircle("touchTargetLeftEye",
    self.resMan:getDisplayGroup("gameGroup"), display.contentCenterX - 225, display.contentCenterY - 75, 170
  );
  local touchTargetRightEye = self.resMan:newCircle("touchTargetRightEye",
    self.resMan:getDisplayGroup("gameGroup"), display.contentCenterX + 225, display.contentCenterY - 75, 170
  );
  touchTargetLeftEye.isHitTestable = true;
  touchTargetRightEye.isHitTestable = true;
  touchTargetLeftEye.whichEye = "left";
  touchTargetRightEye.whichEye = "right";
  touchTargetLeftEye:setFillColor(255, 0, 0, 0);
  touchTargetRightEye:setFillColor(255, 0, 0, 0);
  touchTargetLeftEye:setStrokeColor(0, 0, 0);
  touchTargetRightEye:setStrokeColor(0, 0, 0);

  -- Load sounds.

  self.resMan:loadSound("laugh", miniGamePath .. "laugh.wav");
  self.resMan:loadSound("ouch", miniGamePath .. "ouch.wav");

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

    self.resMan:getCircle("touchTargetLeftEye"):addEventListener("touch",
      function(inEvent) self:eyeTouchHandler(inEvent); end
    );
    self.resMan:getCircle("touchTargetRightEye"):addEventListener("touch",
      function(inEvent) self:eyeTouchHandler(inEvent); end
    );

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

  self.framesSinceLastChange = self.framesSinceLastChange + 1;

  local face = self.resMan:getSprite("face");

  -- Change the face once a second.
  if self.framesSinceLastChange == 30 then

    self.framesSinceLastChange = 0;

    -- Open one eye or the other.
    if face.sequence == "neutral" then

      if math.random(1, 2) == 1 then
        face:setSequence("left");
      else
        face:setSequence("right");
      end

    -- Taunt the player, they didn't hit it.
    elseif face.sequence == "left" or face.sequence == "right" then

      audio.play(self.resMan:getSound("laugh"));
      face:setSequence("miss");
      transition.scaleTo(face, {
        xScale = 6, yScale = 6, time = 100
      });
      transition.scaleTo(face, {
        xScale = 2, yScale = 2, time = 100, delay = 100
      });

    -- Taunting or anger is over, back to neutral.
    elseif face.sequence == "hit" or face.sequence == "miss" then

      face:setSequence("neutral");

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
-- Handles touches on the eyes.
--
-- @param inEvent The event object.
--
function scene:eyeTouchHandler(inEvent)

  local face = self.resMan:getSprite("face");

  -- Only handle touches on the eyes if one is open.
  if inEvent.phase == "ended" and (face.sequence == "left" or face.sequence == "right") then

    -- Get a reference to the tapped eye.
    local eye = inEvent.target;

    -- Scale animation.
    transition.scaleTo(face, {
      xScale = 6, yScale = 6, time = 100
    });
    transition.scaleTo(face, {
      xScale = 2, yScale = 2, time = 100, delay = 100
    });

    -- Switch to the appropriate sequence and score.
    if (eye.whichEye == "left" and face.sequence == "left") or
      (eye.whichEye == "right" and face.sequence == "right") then
      audio.play(self.resMan:getSound("ouch"));
      face:setSequence("hit");
      self.framesSinceLastChange = 0;
      self.updateScore(self, 5);
    else
      audio.play(self.resMan:getSound("laugh"));
      face:setSequence("miss");
      self.framesSinceLastChange = 0;
      self.updateScore(self, -15);
    end

  end -- End ended event.

end -- End eyeTouchHandler().


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
