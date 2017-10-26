local miniGameName = "mathematica";
local miniGamePath = "miniGames/mathematica/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Back to basics: solve the math problems as quickly as you can and as many as you can before time runs out." ..
  "||Tap the correct answer.";


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

  self.resMan:newText(
    "currentQuestion", self.resMan:getDisplayGroup("gameGroup"), "",
    display.contentCenterX, display.contentCenterY - 300, globalNativeFont, 180
  );

  for i = 1, 4, 1 do
    local t = self.resMan:newText(
      "currentChoices" .. i, self.resMan:getDisplayGroup("gameGroup"), "", 0, 0, globalNativeFont, 180
    );
    -- Now position the choice.
    local x;
    local y;
    if i == 1 or i == 3 then
      x = 260;
    else
      x = 800;
    end
    if i == 1 or i == 2 then
      y = display.contentCenterY + 300;
    else
      y = display.contentCenterY + 700;
    end
    t.x = x;
    t.y = y;
  end

  -- Load sounds.
  self.resMan:loadSound("right", self.sharedResourcePath .. "fanfare.wav");
  self.resMan:loadSound("wrong", self.sharedResourcePath .. "buzzer.wav");

  -- Create the first question.
  self:createNewQuestion();

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

    for i = 1, 4, 1 do
      self.resMan:getText("currentChoices" .. i):addEventListener(
        "touch", function(inEvent) self:touchHandler(inEvent); end
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
-- Function that handles touch events.  Note that this game only cares about touch events on specific objects,
-- which have event listeners hooked up to this function.  The global touch() handler is just empty here.
--
-- @param inEvent The event object.
--
function scene:touchHandler(inEvent)

  if self.gameState == self.STATE_PLAYING and inEvent.phase == "ended" then
    if inEvent.target.isRightAnswer == true then
      self.updateScore(self, 5);
      audio.play(self.resMan:getSound("right"));
    else
      self.updateScore(self, -10);
      audio.play(self.resMan:getSound("wrong"));
    end
    self:createNewQuestion();
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


---
-- Create a new question, display it and start it spinning.  Also create the possible answers.
--
-- @param inCleanOnly True to clean up the existing question resources only.  Used in destroy().
--
function scene:createNewQuestion(inCleanOnly)

  -- Randomly create a new question.
  local a;
  local b;
  local op;
  local rightAnswer;
  local chooseAgain = true;
  while chooseAgain do
    a = math.random(1, 25);
    b = math.random(1, 25);
    op = math.random(1, 4);
    if op == 1 then
      rightAnswer = a + b;
      op = " + ";
      chooseAgain = false;
    elseif op == 2 then
      -- Ensure a is always larger to avoid negative answers.
      if b > a then
        local c = a;
        b = a;
        a = c;
      end
      rightAnswer = a - b;
      op = " - ";
      chooseAgain = false;
    elseif op == 3 then
      rightAnswer = a * b;
      op = " * ";
      chooseAgain = false;
    elseif op == 4 then
      -- Ensure a is always larger to avoid decimal answers.
      if b > a then
        local c = a;
        b = a;
        a = c;
      end
      -- Ensure we only get whole number answers.
      if a % b == 0 then
        rightAnswer = a / b;
        op = " / ";
        chooseAgain = false;
      end
    end
  end
  self.resMan:getText("currentQuestion").text = a .. op .. b .. " = ?";

  -- Now create four incorrect answers.  Note that the largest possible answer is 625 (25*25) and the smallest
  -- is 0 (1-1).
  local answersAlreadyChosen = { };
  for i = 1, 4, 1 do
    local chooseAgain = true;
    while chooseAgain do
      -- Ensure all four wrong answers are always of the same length as the right answer, otherwise it's way too easy
      -- to pick out the right answer.
      local wrongAnswer;
      if rightAnswer < 10 then
        wrongAnswer = math.random(0, 9);
      elseif rightAnswer >= 10 and rightAnswer < 100 then
        wrongAnswer = math.random(0, 99);
      else
        wrongAnswer = math.random(100, 625);
      end
      -- Make sure we didn't pick the right answer and also make sure we haven't already picked this wrong answer.
      if wrongAnswer ~= rightAnswer and answersAlreadyChosen[wrongAnswer] == nil then
        chooseAgain = false;
        answersAlreadyChosen[wrongAnswer] = true;
        local t = self.resMan:getText("currentChoices" .. i);
        t.text = wrongAnswer;
        t.isRightAnswer = false;
      end
    end
  end

  -- Now, randomly overwrite one of the wrong answers.  This way, the right answer will be in a random position.
  local whichToOverwrite = math.random(1, 4);
  local cc = self.resMan:getText("currentChoices" .. whichToOverwrite);
  cc.text = rightAnswer;
  cc.isRightAnswer = true;

end -- End createNewQuestion().


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
