local json = require("json");

local miniGameBase = { };


---
-- Creates a Composer scene object specifically for mini-games.  This contains lots of code common to all
-- mini-games and presents a roughly object-oriented inheritance chain for mini-games.
--
-- @param inMiniGameName The name of the mini-game.  This should actually be the filename since it will be used
--                       for log output.
--
function miniGameBase:newMiniGameScene(inMiniGameName)


  -- Ask Composer for a new Scene object that we'll then augment.
  local scene = composer.newScene();

  -- Path to resources shared by multiple games
  scene.sharedResourcePath = "miniGames/sharedResources/";

  -- ResourceManager instance.
  scene.resMan = utils:newResourceManager();

  -- How many seconds a game lasts for.
  scene.matchTimeSeconds = 60;

  -- The name of the mini-game.  This is used for logging as the filename.
  scene.miniGameName = inMiniGameName;

  -- Explosion emitter config data.
  scene.explosionEmitterParams = nil;

  -- The parent attribute will hold references to all base class functions.  This allows us to call the base class
  -- methods from a subclass.
  scene.parent = { };

  -- States a mini-game can be in.
  scene.STATE_INSTRUCTIONS = 0;
  scene.STATE_COUNTDOWN = 1;
  scene.STATE_PLAYING = 2;
  scene.STATE_PAUSED = 4;
  scene.STATE_FINISHED = 5;

  -- The current state of the mini-game.
  scene.gameState = nil;

  -- The current score for this mini-game.
  scene.score = nil;

  -- The time remaining for this mini-game.
  scene.timeRemaining = nil;
  scene.timeRemainingCounter = nil;

  -- Constants for player movements for games that use the directional swipe input mechanism.
  scene.SWIPE_UP = 1;
  scene.SWIPE_DOWN = 2;
  scene.SWIPE_LEFT = 3;
  scene.SWIPE_RIGHT = 4;


  --- ==================================================================================================================
  --  ==================================================================================================================
  --  Scene lifecycle Event Handlers
  --  ==================================================================================================================
  --  ==================================================================================================================


  ---
  -- Handler for the create event.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local create = function(inScene, inEvent)

    local self = inScene;

    --utils:log("BASE", "create()");

    self.resMan:newImageSheet(
      "gameTitles", "miniGames.miniGameTitles_imageSheet", "miniGames/miniGameTitles_imageSheet.png"
    );

    -- Create the game group for game-specific objects.
    local gameGroup = self.resMan:newDisplayGroup("gameGroup");
    gameGroup.isVisible = false;
    self.view:insert(gameGroup);

    -- Create Instructions objects.
    local instructionsGroup = self.resMan:newDisplayGroup("instructionsGroup");
    local instructionsBackground = self.resMan:newSprite("instructionsBackground", instructionsGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("bgTall"), count = 1, time = 9999 }
    );
    instructionsBackground.x = display.contentCenterX;
    instructionsBackground.y = display.contentCenterY;
    -- Game title.  First, construct sequence data object from game list, then create the text sprite.= using it.
    local gameTitlesSequenceData = { };
    for i = 1, #gameList do
      table.insert(gameTitlesSequenceData, {
        name = gameList[i].internalName,
        start = self.resMan:getImageSheetInfo("gameTitles"):getFrameIndex(gameList[i].internalName),
        count = 1, time = 9999
      });
    end
    local gameTitle = self.resMan:newSprite(
      "gameTitle", instructionsGroup, self.resMan:getImageSheet("gameTitles"), gameTitlesSequenceData
    );
    gameTitle:setSequence(self.miniGameName);
    gameTitle.x = display.contentCenterX;
    gameTitle.y = display.contentCenterY - 595;
    local instructionsText = self.resMan:newTextCandy("instructionsText", {
      parentGroup = instructionsGroup, fontName = "fontInstructionsSmaller", originX = "CENTER", originY = "TOP",
      x = display.contentCenterX - 20,
      y = instructionsBackground.y - 260,
      text = self.instructions, wrapWidth = instructionsBackground.width - 460, textFlow = "LEFT",
    });
    local instructionsBegin = self.resMan:newSprite("instructionsBegin", instructionsGroup, uiImageSheet, {
      { name = "default", start = uiSheetInfo:getFrameIndex("btnStart"), count = 1, time = 9999 }
    });
    instructionsBegin.x = display.contentCenterX - 10;
    instructionsBegin.y = instructionsBackground.y + 450;
    self.view:insert(instructionsGroup);

    -- Background at the top.
    local topBG = self.resMan:newRect("topBG", self.view, display.contentCenterX, 50, display.contentWidth + 200, 100);
    topBG:setFillColor(0, 0, 0);

    -- Create menu objects.
    local menuTrigger = self.resMan:newSprite("menuTrigger", self.view, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("pauseIcon"), count = 1, time = 9999 }
    );
    menuTrigger.x = (self.resMan:getSprite("menuTrigger").width / 2) + 10;
    menuTrigger.y = (self.resMan:getSprite("menuTrigger").height / 2) + 10;
    local menuGroup = self.resMan:newDisplayGroup("menuGroup");
    local pauseMenu = self.resMan:newSprite("pauseMenu", menuGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("bgSmall"), count = 1, time = 9999 }
    );
    local pauseTitle = self.resMan:newSprite("pauseTitle", menuGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("txtPaused"), count = 1, time = 9999 }
    );
    pauseTitle.x = 0;
    pauseTitle.y = -316;
    local menuResumeTT = self.resMan:newSprite("menuResumeTT", menuGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("btnResume"), count = 1, time = 9999 }
    );
    menuResumeTT.x = 0;
    menuResumeTT.y = -40;
    local menuExitTT = self.resMan:newSprite("menuExitTT", menuGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("btnExit"), count = 1, time = 9999 }
    );
    menuExitTT.x = 0;
    menuExitTT.y = 180;
    menuGroup.x = display.contentCenterX;
    menuGroup.isVisible = false;
    self.view:insert(menuGroup);

    -- Create score object.
    self.resMan:newTextCandy("scoreText", {
      parentGroup = self.view, fontName = "fontPlain", x = display.contentWidth - 120, y = 48, text = ""
    });

    -- Create time remaining object
    self.resMan:newTextCandy("timeRemainingText", {
      parentGroup = self.view, fontName = "fontPlain", x = display.contentCenterX, y = 48, text = ""
    });

    -- Create finished dialog objects.
    local finishedGroup = self.resMan:newDisplayGroup("finishedGroup");
    local finishedBackground = self.resMan:newSprite("finishedBackground", finishedGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("bgSmall"), count = 1, time = 9999 }
    );
    finishedBackground.x = display.contentCenterX;
    finishedBackground.y = display.contentCenterY;
    local finishedTitle = self.resMan:newSprite("finishedTitle", finishedGroup, uiImageSheet,
      { name = "default", start = uiSheetInfo:getFrameIndex("txtGameOver"), count = 1, time = 9999 }
    );
    finishedTitle.x = display.contentCenterX;
    finishedTitle.y = display.contentCenterY - 310;
    self.resMan:newTextCandy("finishedText", {
      parentGroup = finishedGroup, fontName = "fontPlain",
      x = display.contentCenterX, originY = "TOP", y = display.contentCenterY - 24,
      text = "", originX = "CENTER", originY = "CENTER", textFlow = "CENTER"
    });
    local finishedExit = self.resMan:newSprite("finishedExit", finishedGroup, uiImageSheet, {
      { name = "default", start = uiSheetInfo:getFrameIndex("btnExit"), count = 1, time = 9999 }
    });
    finishedExit.x = display.contentCenterX;
    finishedExit.y = display.contentCenterY + 200;
    local finishedContinue = self.resMan:newSprite("finishedContinue", finishedGroup, uiImageSheet, {
      { name = "default", start = uiSheetInfo:getFrameIndex("btnContinue"), count = 1, time = 9999 }
    });
    finishedContinue.x = display.contentCenterX;
    finishedContinue.y = display.contentCenterY + 200;
    finishedGroup.isVisible = false;
    self.view:insert(finishedGroup);

    -- Explosion particle emitter data.
    local pfp = system.pathForFile(self.sharedResourcePath .. "explosion.json", nil);
    local pf = io.open(pfp, "r");
    local pfd = pf:read("*a");
    pf:close();
    self.explosionEmitterParams = json.decode(pfd);

    -- Reset score.
    self.score = 0;
    self:updateScore(0);

    -- Reset time remaining (in seconds).
    self.timeRemaining = self.matchTimeSeconds;
    self.timeRemainingCounter = math.round(1000 / display.fps);
    self.resMan:getTextCandy("timeRemainingText"):setText(self.timeRemaining);

    -- Initial game state.
    self.gameState = self.STATE_INSTRUCTIONS;

  end -- End create().
  scene.create = create;
  scene.parent.create = create;


  ---
  -- Handler for the show event.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local show = function(inScene, inEvent)

    local self = inScene;

    if inEvent.phase == "will" then

      --utils:log("BASE", "show(): will");

      -- Menu and finished dialog are initially hidden.
      self.resMan:getDisplayGroup("menuGroup").isVisible = false;
      self.resMan:getDisplayGroup("finishedGroup").isVisible = false;

      self.obscureGroup(self.resMan:getDisplayGroup("gameGroup"), 0);

      -- Bring elements to the foreground that need to be.
      self.resMan:getDisplayGroup("instructionsGroup"):toFront();
      self.resMan:getDisplayGroup("menuGroup"):toFront();
      self.resMan:getSprite("menuTrigger"):toFront();
      self.resMan:getTextCandy("scoreText"):toFront();
      self.resMan:getTextCandy("timeRemainingText"):toFront();
      self.resMan:getDisplayGroup("finishedGroup"):toFront();

    else

      --utils:log("BASE", "show(): did");

      -- Attach listeners to instructions objects.
      self.resMan:getSprite("instructionsBegin"):addEventListener("touch",
        function(inEvent)
          self.instructionsBeginTouchHandler(self, inEvent);
          return true;
        end
      );

      -- Attach listeners to menu objects.
      self.resMan:getSprite("menuTrigger"):addEventListener("touch",
        function(inEvent)
          self.menuTriggerTouchHandler(self, inEvent);
          return true;
        end
      );
      self.resMan:getSprite("menuResumeTT"):addEventListener("touch",
        function(inEvent)
          self.menuResumeTouchHandler(self, inEvent);
          return true;
        end
      );
      self.resMan:getSprite("menuExitTT"):addEventListener("touch",
        function(inEvent)
          self.menuExitTouchHandler(self, inEvent);
          return true;
        end
      );

      -- Attach listeners to finished popup objects.
      self.resMan:getSprite("finishedExit"):addEventListener("touch",
        function(inEvent)
          self.finishedExitTouchHandler(self, inEvent);
          return true;
        end
      );
      self.resMan:getSprite("finishedContinue"):addEventListener("touch",
        function(inEvent)
          self.finishedContinueTouchHandler(self, inEvent);
          return true;
        end
      );

      -- Attach listener for enterFrame and touch events.
      Runtime:addEventListener("enterFrame",
        function(inEvent)
          if self.gameState == self.STATE_PLAYING then
            self:enterFrame(inEvent);
          end
        end
      );
      Runtime:addEventListener("touch",
        function(inEvent)
          if self.gameState == self.STATE_PLAYING then
            self:touch(inEvent);
          end
          return true;
        end
      );
      Runtime:addEventListener("collision",
        function(inEvent)
          if self.gameState == self.STATE_PLAYING then
            self:collision(inEvent);
          end
        end
      );

    end

  end -- End show().
  scene.show = show;
  scene.parent.show = show;


  ---
  -- Handler for the hide event.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local hide = function(inScene, inEvent)

    local self = inScene;

    if inEvent.phase == "did" then

      --utils:log("BASE", "hide(): did");

      -- Detach listener for enterFrame and touch events.
      Runtime:removeEventListener("enterFrame", self);
      Runtime:removeEventListener("touch", self);
      Runtime:removeEventListener("collision", self);

    end

  end -- End hide().
  scene.hide = hide;
  scene.parent.hide = hide;


  ---
  -- Handler for the destroy event.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local destroy = function(inScene, inEvent)

    local self = inScene;

    --utils:log("BASE", "destroy()");

    self.resMan:destroyAll();

  end -- End destroy().
  scene.destroy = destroy;
  scene.parent.destroy = destroy;


  ---
  -- Called when a game ends.
  --
  -- @param inScene   Reference to the game's scene object.
  --
  local endGame = function(inScene)

    local self = inScene;

    -- First, call the endEvent() method.
    self:endEvent();

    -- If the player is playing a match round, show the Continue text, otherwise show Exit.
    if isPlayingMatchRound == true then
      self.resMan:getSprite("finishedContinue").isVisible = true;
      self.resMan:getSprite("finishedExit").isVisible = false;
      -- Add this game's score to the match round score.
      matchRoundScore = matchRoundScore + self.score;
    else
      self.resMan:getSprite("finishedContinue").isVisible = false;
      self.resMan:getSprite("finishedExit").isVisible = true;
    end

    self.gameState = self.STATE_FINISHED;
    self.resMan:getTextCandy("finishedText"):setText("Final Score:|" .. self.score);
    self.obscureGroup(self.resMan:getDisplayGroup("gameGroup"));
    self.resMan:getDisplayGroup("finishedGroup").isVisible = self;

  end -- End endGame().
  scene.endGame = endGame;
  scene.parent.endGame = endGame;


  --- ==================================================================================================================
  --  ==================================================================================================================
  --  EnterFrame
  --  ==================================================================================================================
  --  ==================================================================================================================


  ---
  -- Handler for the enterFrame event.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local enterFrame = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_INSTRUCTIONS then
    elseif self.gameState == self.STATE_COUNTDOWN then
    elseif self.gameState == self.STATE_PAUSED then
    elseif self.gameState == self.STATE_FINISHED then
    elseif self.gameState == self.STATE_PLAYING then

      self.timeRemainingCounter = self.timeRemainingCounter - 1;
      if self.timeRemainingCounter == 0 then
        self.timeRemainingCounter = math.round(1000 / display.fps);
        self.timeRemaining = self.timeRemaining - 1;
        self.resMan:getTextCandy("timeRemainingText"):setText(self.timeRemaining);
        if self.timeRemaining == 0 then
          self:endGame();
        end
      end

    end

  end -- End enterFrame().
  scene.enterFrame = enterFrame;
  scene.parent.enterFrame = enterFrame;


  --- ==================================================================================================================
  --  ==================================================================================================================
  --  Object Touch Handlers
  --  ==================================================================================================================
  --  ==================================================================================================================


  ---
  -- Handler for touch events on the instruction's Begin option.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local instructionsBeginTouchHandler = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_INSTRUCTIONS then

      if inEvent.phase == "began" then

        inEvent.target.fill.effect = "filter.monotone";
        inEvent.target.fill.effect.r = 1;

      elseif inEvent.phase == "ended" then

        inEvent.target.fill.effect = nil;
        audio.play(uiTap);

        -- Hide instructions.
        self.resMan:getDisplayGroup("instructionsGroup").isVisible = false;

        self:countdownStartEvent();

        -- Countdown and begin game when done.
        self.gameState = STATE_COUNTDOWN;
        self.showMessage(self, "3 ",
          function()
            self.showMessage(self, "2 ",
              function()
                self.showMessage(self, "1",
                  function()
                    self.resMan:getDisplayGroup("gameGroup").isVisible = true;
                    self.unObscureGroup(self.resMan:getDisplayGroup("gameGroup"));
                    self.showMessage(self, "GO!",
                      function()
                        self:startEvent();
                        self.gameState = self.STATE_PLAYING;
                      end
                    );
                  end
                );
              end
            );
          end
        );

      end

    end

  end -- End menuBeginTouchHandler().
  scene.instructionsBeginTouchHandler = instructionsBeginTouchHandler;
  scene.parent.instructionsBeginTouchHandler = instructionsBeginTouchHandler;


  ---
  -- Handler for touch events on the menu's trigger button.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local menuTriggerTouchHandler = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_PLAYING then
      if inEvent.phase == "began" then
        inEvent.target.fill.effect = "filter.monotone";
        inEvent.target.fill.effect.r = 1;
      elseif inEvent.phase == "ended" then
        transition.pause();
        inEvent.target.fill.effect = nil;
        audio.play(uiTap);
        self.gameState = self.STATE_PAUSED;
        self.obscureGroup(self.resMan:getDisplayGroup("gameGroup"));
        self.resMan:getDisplayGroup("menuGroup").y = -(display.contentHeight * 2);
        transition.to(self.resMan:getDisplayGroup("menuGroup"),
          { time = 750, y = display.contentCenterY, transition = easing.inOutBounce }
        );
        self.resMan:getDisplayGroup("menuGroup").isVisible = true;
        self:menuTriggered();
      end
    end

  end -- End menuTriggerTouchHandler().
  scene.menuTriggerTouchHandler = menuTriggerTouchHandler;
  scene.parent.menuTriggerTouchHandler = menuTriggerTouchHandler;


  ---
  -- Handler for touch events on the menu's Resume X.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local menuResumeTouchHandler = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_PAUSED then
      if inEvent.phase == "began" then
        inEvent.target.fill.effect = "filter.monotone";
        inEvent.target.fill.effect.r = 1;
        display.getCurrentStage():setFocus(inEvent.target);
      elseif inEvent.phase == "ended" then
        inEvent.target.fill.effect = nil;
        display.getCurrentStage():setFocus(nil);
        audio.play(uiTap);
        transition.to(self.resMan:getDisplayGroup("menuGroup"),
          { time = 750, y = -display.contentHeight, transition = easing.inOutExpo }
        );
        self.unObscureGroup(self.resMan:getDisplayGroup("gameGroup"), 750,
          function()
            self.gameState = self.STATE_PLAYING;
            self:menuTriggered();
            transition.resume();
          end
        );
      end
    end

  end -- End menuResumeTouchHandler().
  scene.menuResumeTouchHandler = menuResumeTouchHandler;
  scene.parent.menuResumeTouchHandler = menuResumeTouchHandler;


  ---
  -- Handler for touch events on the menu's Exit option.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local menuExitTouchHandler = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_PAUSED then
      if inEvent.phase == "began" then
        inEvent.target.fill.effect = "filter.monotone";
        inEvent.target.fill.effect.r = 1;
        display.getCurrentStage():setFocus(inEvent.target);
      elseif inEvent.phase == "ended" then
        inEvent.target.fill.effect = nil;
        display.getCurrentStage():setFocus(nil);
        audio.play(uiTap);
        composer.gotoScene("practiceSelection.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
      end
    end

  end -- End menuExitTouchHandler().
  scene.menuExitTouchHandler = menuExitTouchHandler;
  scene.parent.menuExitTouchHandler = menuExitTouchHandler;


  ---
  -- Handler for touch events on the finished dialog's Exit option.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local finishedExitTouchHandler = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_FINISHED then
      if inEvent.phase == "began" then
        inEvent.target.fill.effect = "filter.monotone";
        inEvent.target.fill.effect.r = 1;
      elseif inEvent.phase == "ended" then
        inEvent.target.fill.effect = nil;
        composer.gotoScene("practiceSelection.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
      end
    end

  end -- End finishedExitTouchHandler().
  scene.finishedExitTouchHandler = finishedExitTouchHandler;
  scene.parent.finishedExitTouchHandler = finishedExitTouchHandler;


  ---
  -- Handler for touch events on the finished dialog's Continue option.  This only happens if the user is
  -- playing a match round.
  --
  -- @param inScene Reference to the game's scene object.
  -- @param inEvent The event object.
  --
  local finishedContinueTouchHandler = function(inScene, inEvent)

    local self = inScene;

    if self.gameState == self.STATE_FINISHED then
      if inEvent.phase == "began" then
        inEvent.target.fill.effect = "filter.monotone";
        inEvent.target.fill.effect.r = 1;
      elseif inEvent.phase == "ended" then
        inEvent.target.fill.effect = nil;
        -- If there's more games to play, go to the next game, otherwise go to the matchRoundComplete scene.
        if matchRoundGameIndex < currentMatch.numGamesPerRound then
          matchRoundGameIndex = matchRoundGameIndex + 1;
          composer.gotoScene(
            "miniGames." .. gameList[matchRoundGames[matchRoundGameIndex]].internalName .. ".main",
            SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME
          );
        else
          composer.gotoScene("matchRoundComplete.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
        end
      end
    end

  end -- End finishedContinueTouchHandler().
  scene.finishedContinueTouchHandler = finishedContinueTouchHandler;
  scene.parent.finishedContinueTouchHandler = finishedContinueTouchHandler;


  --- ==================================================================================================================
  --  ==================================================================================================================
  --  Game Utility Functions
  --  ==================================================================================================================
  --  ==================================================================================================================


  ---
  -- Function to show a transient expanding message.
  --
  -- @param inScene    Reference to the game's scene object.
  -- @param inMsg      The message to show.
  -- @param inCallback Reference to a function to call when the message completes its animation sequence.
  --
  local showMessage = function(inScene, inMsg, inCallback)

    --utils:log("gameCore", "showMessage(): inMsg = " .. inMsg);
    -- Create message text.

    local msgText = textCandy.CreateText({
      parentGroup = self.view, fontName = "fontTransientMsg", x = display.contentCenterX, y = 300, text = inMsg
    });
    msgText.x = display.contentCenterX;
    msgText.y = display.contentCenterY;
    msgText.alpha = 1;
    msgText.xScale = .1;
    msgText.yScale = .1;
    msgText.callback = inCallback;

    -- Start the animation.
    transition.to(msgText,
      { time = 750, alpha = 0, xScale = 10.0, yScale = 10.0,
        onComplete = function(inTarget)
          if inTarget.callback ~= nil then
            inTarget.callback();
          end
          textCandy.DeleteText(inTarget);
          inTarget = nil;
        end
      }
    );

  end -- End showMessage().
  scene.showMessage = showMessage;
  scene.parent.showMessage = showMessage;


  ---
  -- Function to update the current score of this mini-game.  This takes care of capping the score at 9999 and
  -- ensuring it's never negative.
  --
  -- @param inScene        Reference to the game's scene object.
  -- @param inChangeAmount The amount the score changed.  Can be a positive or negative value.
  --
  local updateScore = function(inScene, inChangeAmount)

    --utils:log("gameCore", "updateScore(): inChangeAmount = " .. inChangeAmount);

    local self = inScene;

    self.score = self.score + inChangeAmount;

    -- Clamp values at 0 and 9999.  Mini-games must be designed for it to be impossible to ever get a score over 9999!
    if self.score < 0 then
      self.score = 0;
    end
    if self.score > 9999 then
      self.score = 9999;
    end

    -- Construct final text and update, ensuring it's always 4 digits.
    local s = "";
    if self.score < 1000 then
      s = s .. "0";
    end
    if self.score < 100 then
      s = s .. "00";
    end
    if self.score < 10 then
      s = s .. "0";
    end
    s = s .. self.score;
    self.resMan:getTextCandy("scoreText"):setText(s);

  end -- End updateScore().
  scene.updateScore = updateScore;
  scene.parent.updateScore = updateScore;


  ---
  -- Function to obscure a DisplayGroup.  This uses an effect on all children in the group over a period of time.
  --
  -- @param inGroup The group to obscure.
  -- @param inTime  The amount of time in milliseconds the obscure should take.
  --
  local obscureGroup = function(inGroup, inTime)

    for i = inGroup.numChildren, 1, -1 do
      local object = inGroup[i];
      object.fill.effect = "filter.dissolve";
      transition.to(object.fill.effect, {
        time = inTime,
        threshold = 0,
        onComplete = function(inObj)
          inGroup.isVisible = false;
        end
      });
    end

  end -- End obscureGroup().
  scene.obscureGroup = obscureGroup;
  scene.parent.obscureGroup = obscureGroup;


  ---
  -- Function to unObscure a DisplayGroup. This transitions from the effect set in obscureGroup() to make the
  -- group properly visible after a given period of time.
  --
  -- @param inGroup    The group to obscure.
  -- @param inTime     The amount of time in milliseconds the obscure should take.
  -- @param inCallback Function to call onComplete (optional).
  --
  local unObscureGroup = function(inGroup, inTime, inCallback)

    for i = inGroup.numChildren, 1, -1 do
      local object = inGroup[i];
      inGroup.isVisible = true;
      transition.to(object.fill.effect, {
        time = inTime,
        threshold = 1,
        onComplete = function(inObj)
          for i = inGroup.numChildren, 1, -1 do
            inGroup[i].fill.effect = nil;
            if inCallback ~= nil then
              inCallback();
            end
          end
        end
      });
    end

  end -- End unObscureGroup().
  scene.unObscureGroup = unObscureGroup;
  scene.parent.unObscureGroup = unObscureGroup;


  ---
  -- Given to points, determines which direction a swipe gesture was in.  This is used by games that use a direcitonal
  -- swipe input scheme.
  --
  -- @param  inScene      Reference to the game's scene object.
  -- @param  inStartPoint An object with two attributes, x and y, which is the point at which the gesture started.
  -- @param  inEndPoint   An object with two attributes, x and y, which is the point at which the gesture ended.
  -- @return              One of the SWIPE_UP, SWIPE_DOWN, SWIPE_LEFT or SWIPE_RIGHT constants.
  --
  local determineSwipeDirection = function(inScene, inStartPoint, inEndPoint)

    local self = inScene;

    local minSwipeDistance = 100;

    if math.abs(inEndPoint.x - inStartPoint.x) > math.abs(inEndPoint.y - inStartPoint.y) then
      if inStartPoint.x > inEndPoint.x then
        if (inStartPoint.x - inEndPoint.x) > minSwipeDistance then
          return self.SWIPE_LEFT;
        end
      else
        if (inEndPoint.x - inStartPoint.x) > minSwipeDistance then
          return self.SWIPE_RIGHT;
        end
      end
    else
      if inStartPoint.y > inEndPoint.y then
        if (inStartPoint.y - inEndPoint.y) > minSwipeDistance then
          return self.SWIPE_UP;
        end
      else
        if (inEndPoint.y - inStartPoint.y) > minSwipeDistance then
          return self.SWIPE_DOWN;
        end
      end
    end

  end -- End determineSwipeDirection().
  scene.determineSwipeDirection = determineSwipeDirection;
  scene.parent.determineSwipeDirection = determineSwipeDirection;


  -- Scene is completely constructed, send it back.
  return scene;


end -- End newMiniGameScene().


return miniGameBase;
