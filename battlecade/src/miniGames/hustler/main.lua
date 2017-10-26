local miniGameName = "hustler";
local miniGamePath = "miniGames/hustler/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "It sounds easy, but it's not! Watch the ball, don't lose track of it!" ..
  "||Tap the cup the ball is under after they're shuffled.";


-- Which cup the ball is under.
scene.whichCup = nil;

-- The sequence of random moves.  Each element is an object with three properties: cup1, cup2 and cup3 and the value of
-- each is what position that cup moves to for that move.
scene.moveSequence = nil;

-- Which move of the sequence we're doing ow.
scene.moveSequenceIndex = nil;

-- X locations of the three cup positions.
scene.cupsX = { 200, 538, 878 };

-- True when it's time for the user to choose.
scene.userCanChoose = false;


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

  self.resMan:newSprite("ball", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("ball"), count = 1, time = 9999 }
  );

  local cup1 = self.resMan:newSprite("cup1", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("cup"), count = 1, time = 9999 }
  );
  cup1.cupNumber = 1;
  local cup2 = self.resMan:newSprite("cup2", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("cup"), count = 1, time = 9999 }
  );
  cup2.cupNumber = 2;
  local cup3 = self.resMan:newSprite("cup3", self.resMan:getDisplayGroup("gameGroup"), imageSheet,
    { name = "default", start = sheetInfo:getFrameIndex("cup"), count = 1, time = 9999 }
  );
  cup3.cupNumber = 3;

  self:resetGame();

  -- Load sounds.
  self.resMan:loadSound("move", self.sharedResourcePath .. "step.wav");
  self.resMan:loadSound("right", self.sharedResourcePath .. "fanfare.wav");
  self.resMan:loadSound("wrong", self.sharedResourcePath .. "buzzer.wav");
  self.resMan:loadSound("raise", self.sharedResourcePath .. "boing.wav");
  self.resMan:loadSound("reset", self.sharedResourcePath .. "whoosh.wav");

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

    self.resMan:getSprite("cup1"):addEventListener("touch", function(inEvent) self:cupTouchHandler(inEvent); end );
    self.resMan:getSprite("cup2"):addEventListener("touch", function(inEvent) self:cupTouchHandler(inEvent); end );
    self.resMan:getSprite("cup3"):addEventListener("touch", function(inEvent) self:cupTouchHandler(inEvent); end );

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

    transition.cancel();

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

  self:showBall();

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
-- Handles touches on a cup.
--
-- @param inEvent The event object.
--
function scene:cupTouchHandler(inEvent)

  if inEvent.phase == "ended" and self.userCanChoose == true then

    self.userCanChoose = false;
    local cup = inEvent.target;
    -- Raise the cup.
    audio.play(self.resMan:getSound("raise"));
    transition.to(cup, {
      y = -200, delta = true, time = 500, easing = easing.outInQuad,
      onComplete = function(inCup)
        -- Update score as appropriate.
        if inCup.cupNumber == self.whichCup then
          self.updateScore(self, 10);
          audio.play(self.resMan:getSound("right"));
        else
          self.updateScore(self, -5);
          audio.play(self.resMan:getSound("wrong"));
        end
        -- Just a do-nothing transition so the cup stays up half a second.
        transition.to(inCup, {
          y = 0, delta = true, time = 500, easing = easing.outInQuad,
          onComplete = function(inCup)
            -- Put the cup back down.
            transition.to(inCup, {
              y = 200, delta = true, time = 500, easing = easing.outInQuad,
              onComplete = function(inCup)
                -- Move cups back to their starting positions with a little scaling flare.
                audio.play(self.resMan:getSound("reset"));
                self.resMan:getSprite("ball").isVisible = false;
                transition.to(self.resMan:getSprite("cup1"), {
                  x = self.cupsX[1], xScale = 2, yScale = 2, time = 250, easing = easing.outInQuad
                });
                transition.to(self.resMan:getSprite("cup2"), {
                  x = self.cupsX[2], xScale = 2, yScale = 2, time = 250, easing = easing.outInQuad
                });
                transition.to(self.resMan:getSprite("cup3"), {
                  x = self.cupsX[3], xScale = 2, yScale = 2, time = 250, easing = easing.outInQuad,
                  onComplete = function(inCup)
                    -- Now scale them back to normal.
                    transition.to(self.resMan:getSprite("cup1"), {
                      xScale = 1, yScale = 1, time = 250, easing = easing.outInQuad
                    });
                    transition.to(self.resMan:getSprite("cup2"), {
                      xScale = 1, yScale = 1, time = 250, easing = easing.outInQuad
                    });
                    transition.to(self.resMan:getSprite("cup3"), {
                      xScale = 1, yScale = 1, time = 250, easing = easing.outInQuad,
                      onComplete = function()
                        -- Animations done, reset the game and kick if off.
                        self:resetGame();
                        self:showBall();
                      end
                    });
                  end
                });
              end
            });
          end
        });
      end
    });

  end -- End ended event.

end -- End cupTouchHandler().


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


---
-- Repositions ball and cups to start a new game and chooses a random cup for the ball to be under.
--
function scene:resetGame()

  self.userCanChoose = false;

  -- Cups to their starting positions.
  local cups = { };
  cups[1] = self.resMan:getSprite("cup1");
  cups[1].x = self.cupsX[1];
  cups[1].y = display.contentCenterY;
  cups[2] = self.resMan:getSprite("cup2");
  cups[2].x = self.cupsX[2];
  cups[2].y = display.contentCenterY;
  cups[3] = self.resMan:getSprite("cup3");
  cups[3].x = self.cupsX[3];
  cups[3].y = display.contentCenterY;

  -- Choose a cup for the ball.
  self.whichCup = math.random(1, 3);

  -- Choose a sequence of moves.  There will be 10 moves, and for each move, each cup randomly moves (or doesn't move
  -- at all) to one of the three positions.
  self.moveSequence = { };
  for i = 1, 10, 1 do
    local nextMove = { };
    local lastMove = { cup1 = 0, cup2 = 0, cup3 = 0 };
    if i > 1 then
      lastMove = self.moveSequence[i - 1];
    end
    nextMove.cup1 = math.random(1, 3);
    nextMove.cup2 = math.random(1, 3);
    nextMove.cup3 = math.random(1, 3);
    while
      (nextMove.cup1 + nextMove.cup2 + nextMove.cup3) ~= 6 or
      (nextMove.cup1 == 2 and nextMove.cup2 == 2 and nextMove.cup3 == 2) or
      (nextMove.cup1 == lastMove.cup1 and nextMove.cup2 == lastMove.cup2 and nextMove.cup3 == lastMove.cup3)
    do
      nextMove.cup1 = math.random(1, 3);
      nextMove.cup2 = math.random(1, 3);
      nextMove.cup3 = math.random(1, 3);
    end
    self.moveSequence[i] = nextMove;
  end
  self.moveSequenceIndex = 1;

  -- Position the ball.
  local ball = self.resMan:getSprite("ball");
  ball.x = cups[self.whichCup].x;
  ball.y = display.contentCenterY + 100;

end -- End resetGame();


---
-- Shows which cup the ball is under.
--
function scene:showBall()

  local cup = self.resMan:getSprite("cup" .. self.whichCup);

  -- Raise the cup.
  audio.play(self.resMan:getSound("raise"));
  self.resMan:getSprite("ball").isVisible = true;
  transition.to(cup, {
    y = -200, delta = true, time = 500, easing = easing.outInQuad,
    onComplete = function(inCup)
      -- Just a do-nothing transition so the cup stays up half a second.
      transition.to(inCup, {
        y = 0, delta = true, time = 500, easing = easing.outInQuad,
        onComplete = function(inCup)
          -- Put the cup back down.
          transition.to(inCup, {
            y = 200, delta = true, time = 500, easing = easing.outInQuad,
            onComplete = function(inCup)
              self.resMan:getSprite("ball").isVisible = false;
              self:doNextMoveSequence();
            end
          });
        end
      });
    end
  });

end -- End showBall().


---
-- Does the transition for the next move in the move sequence.
--
function scene:doNextMoveSequence()

  self.moveSequenceIndex = self.moveSequenceIndex + 1;
  if self.moveSequenceIndex > 10 then
   -- Time to choose.  But first, put the ball under the correct cup.
   local ball = self.resMan:getSprite("ball");
   ball.x = self.resMan:getSprite("cup" .. self.whichCup).x;
   ball.isVisible = true;
   self.userCanChoose = true;
  else
    audio.play(self.resMan:getSound("move"));
    transition.to(self.resMan:getSprite("cup1"), {
      x = self.cupsX[self.moveSequence[self.moveSequenceIndex].cup1], time = 500, easing = easing.outInQuad,
    });
    transition.to(self.resMan:getSprite("cup2"), {
      x = self.cupsX[self.moveSequence[self.moveSequenceIndex].cup2], time = 500, easing = easing.outInQuad,
    });
    transition.to(self.resMan:getSprite("cup3"), {
      x = self.cupsX[self.moveSequence[self.moveSequenceIndex].cup3], time = 500, easing = easing.outInQuad,
      onComplete = function()
        self:doNextMoveSequence();
      end
    });
  end

end -- End doNextMoveSequence().


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
