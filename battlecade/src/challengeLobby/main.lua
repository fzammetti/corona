--utils:log("challengeLobby", "Loaded");

local challengePopup = require("challengeLobby.challengePopup");

local scene = composer.newScene();

scene.resMan = nil;

-- The list of matches this player is involved in.
scene.matchList = { };

scene.textNoMatches = nil;

-- TableView that lists matches and how tall each row is.
scene.matchListTableView = nil;
scene.listRowHeight = 260;

-- Functions for animating the tiles that beed attention.
scene.grow = function(inSelf, inRow)
  transition.to(inRow, {
    xScale = 0.03, yScale = 0.03, x = -12, y = -12, delta = true, time = 250,
    onComplete = function(inObject)
      scene:shrink(inObject);
    end
  });
end
scene.shrink = function(inSelf, inRow)
  transition.to(inRow, {
    xScale = -0.03, yScale = -0.03, x = 12, y = 12, delta = true, time = 250,
    onComplete = function(inObject)
      scene:grow(inObject);
    end
  });
end

-- Refresh to the automatic list refresh timer.
scene.refreshTimer = nil;

-- Flag to tell us whether a request is in flight for refreshing the match list.
scene.isRefreshRequestInFlight = false;

-- Flag to tell us if a touch event has begun but not concluded.
scene.isTouchEventHappening = false;

-- How often (in milliseconds) we'll automatically refresh the match list.
scene.refreshInterval = 30000;

-- The frown graphic.
scene.frown = nil;


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

  --utils:log("challengeLobby", "create()");

  self.resMan = utils:newResourceManager();

  if gameState.username ~= nil then
    self.resMan:newTextCandy("textGreeting", {
      parentGroup = self.view, fontName = "fontInstructions", x = display.contentCenterX, y = 370,
      text = "Welcome back, " .. utils:trim(gameState.username) .. "!"
    });
  end

  local frown = self.resMan:newImage("frown",
    self.view, "challengeLobby/frown.png", display.contentCenterX, display.contentCenterY - 100
  );
  frown.isVisible = false;
  frown.alpha = 0.25;

  local btnChallenge = self.resMan:newSprite("btnChallenge", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnChallengeSomeone"), count = 1, time = 9999 }
  });
  btnChallenge.x = display.contentCenterX;
  btnChallenge.y = 1460;

  local btnBack = self.resMan:newSprite("btnBack", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnBack"), count = 1, time = 9999 }
  });
  btnBack.x = display.contentCenterX;
  btnBack.y = display.contentHeight - 100;

  -- Construct TableView to list matches.
  local listTextYOffset = 34;
  local matchListTableView = self.resMan:newTableView("matchListTableView", {
    noLines = true, hideBackground = true, backgroundColor = { 0.9, 0.9, 0.9, 0.1 },
    x = display.contentCenterX, y = display.contentCenterY - 60,
    width = 1040, height = 900,
    onRowRender = function(inEvent)
      local row = inEvent.row;
      local index = row.index;
      -- Background image.
      local bg = display.newSprite(row, uiImageSheet, {
        { name = "default", start = uiSheetInfo:getFrameIndex("matchRow"), count = 1, time = 9999 }
      });
      bg.anchorX = 0;
      bg.anchorY = 0;
      bg.x = 20;
      -- Status title text.
      local statusText = display.newText(row, row.params.caption, 50, 42, globalNativeFont, 36);
      statusText.anchorX = 0;
      statusText.anchorY = 0;
      statusText:setFillColor(255, 255, 255);
      -- Rounds text.
      local roundsCaption = display.newText(row, "Rounds", 70, 110, globalNativeFont, 24);
      roundsCaption.anchorX = 0;
      roundsCaption.anchorY = 0;
      roundsCaption:setFillColor(0, 0, 0);
      local roundsNumber = display.newText(row, row.params.numRounds, 98, 136, globalNativeFont, 64);
      roundsNumber.anchorX = 0;
      roundsNumber.anchorY = 0;
      roundsNumber:setFillColor(0, 0, 0);
      -- Games per round text.
      local gamesPerRoundCaption = display.newText(row, "Games Per Round", 200, 110, globalNativeFont, 24);
      gamesPerRoundCaption.anchorX = 0;
      gamesPerRoundCaption.anchorY = 0;
      gamesPerRoundCaption:setFillColor(0, 0, 0);
      local gamesPerRoundNumber =
        display.newText(row, row.params.numGamesPerRound, 290, 136, globalNativeFont, 64);
      gamesPerRoundNumber.anchorX = 0;
      gamesPerRoundNumber.anchorY = 0;
      gamesPerRoundNumber:setFillColor(0, 0, 0);
      -- Current round text.
      local currentRoundCaption = display.newText(row, "Current Round", 446, 110, globalNativeFont, 24);
      currentRoundCaption.anchorX = 0;
      currentRoundCaption.anchorY = 0;
      currentRoundCaption:setFillColor(0, 0, 0);
      local currentRoundNumber = display.newText(row, row.params.currentRound, 514, 136, globalNativeFont, 64);
      currentRoundNumber.anchorX = 0;
      currentRoundNumber.anchorY = 0;
      currentRoundNumber:setFillColor(0, 0, 0);
      if row.params.outcome == "i" or row.params.oucome == "o" or row.params.outcome == "t" then
        currentRoundCaption.isVisible = false;
        currentRoundNumber.isVisible = false;
      end
      -- Scores text.
      local scoresStartX = 780;
      local yourScore = row.params.finalInitiatorScore;
      local theirScore = row.params.finalOpponentScore;
      -- Since these two variables will be nil until the match ends, we have to give them a value to avoid errors.
      if yourScore == nil then
        yourScore = "-";
      end
      if theirScore == nil then
        theirScore = "-";
      end
      -- Now, be sure we display "your" score and "their" score correctly according to who was the initiator.
      -- The above code assumes the current user was, but if they were the opponent then swap the scores.
      if row.params.opponent == gameState.username then
        yourScore, theirScore = theirScore, yourScore;
      end
      local yourScoreCaption = display.newText(row, "Your Final Score:", scoresStartX, 138, globalNativeFont, 24);
      yourScoreCaption:setFillColor(0, 0, 0);
      local yourScoreNumber = display.newText(row, yourScore, scoresStartX + 150, 140, globalNativeFont, 24);
      yourScoreNumber:setFillColor(0, 0, 0);
      local theirScoreCaption =
        display.newText(row, "Their Final Score:", scoresStartX, 175, globalNativeFont, 24);
      theirScoreCaption:setFillColor(0, 0, 0);
      local theirScoreNumber = display.newText(row, theirScore, scoresStartX + 150, 177, globalNativeFont, 24);
      theirScoreNumber:setFillColor(0, 0, 0);
      if row.params.shouldPulse == true then
        scene:grow(row);
      end
      -- All done.
      return true;
    end,
    onRowTouch = function(inEvent)
      if inEvent.phase == "press" then
        self.isTouchEventHappening = true;
      elseif inEvent.phase == "release" then
        self.isTouchEventHappening = false;
        if challengePopup.showing == false then
          self:matchSelectedHandler(inEvent.target.params);
        end
      end
    end
  });
  self.view:insert(matchListTableView);

  local textNoMatches = self.resMan:newTextCandy("textNoMatches", {
    parentGroup = self.view, fontName = "fontInstructions",
    x = display.contentCenterX, y = display.contentCenterY - 100, originY = "TOP",
    text = "You are not currently involved in any matches.||||Why not challenge a friend?",
    wrapWidth = display.contentWidth - 300, originX = "CENTER", originY = "CENTER",
    textFlow = "CENTER"
  });
  textNoMatches.isVisible = false;

  challengePopup:create(self);

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  if inEvent.phase == "did" then

    --utils:log("challengeLobby", "show(): did");

    if textTitle.isVisible == false then
      textTitle.isVisible = true;
      textTitle:startAnimation();
    end

    -- Attach listeners to TextCandy objects.
    self.resMan:getSprite("btnChallenge"):addEventListener("touch",
      function(inEvent)
        self:btnChallengeTouchHandler(inEvent);
        return true;
      end
    );
    self.resMan:getSprite("btnBack"):addEventListener("touch",
      function(inEvent)
        self:btnBackTouchHandler(inEvent);
        return true;
      end
    );

    challengePopup:show()

    -- Attach listener for enterFrame event.
    Runtime:addEventListener("enterFrame", self);

    -- Get list of matches from server and show in list widget.
    self.isRefreshRequestInFlight = true;
    serverDelegate:getMatchStatus(
      function(inList)
        if inList == nil then
          composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
        else
          self:populateList(inList);
          self.refreshTimer = timer.performWithDelay(self.refreshInterval, self.refreshList, 0);
          self.isRefreshRequestInFlight = false;
        end
      end
    );

  end

  textTitle.isVisible = true;

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  if inEvent.phase == "did" then

    --utils:log("challengeLobby", "hide(): did");

    if self.refreshTimer ~= nil then
      timer.cancel(self.refreshTimer);
    end

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

  --utils:log("challengeLobby", "destroy()");

  challengePopup:destroy();

  self.resMan:destroyAll();
  self.resMan = nil;

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
-- Handler for touch events on the Challenge item.
--
-- @param inEvent The event object.
--
function scene:btnChallengeTouchHandler(inEvent)

  if inEvent.phase == "began" then

    self.isTouchEventHappening = true;
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);

  elseif (inEvent.phase == "ended" or inEvent.phase == "cancelled") and challengePopup.showing == false then

    challengePopup.showing = true;
    self.isTouchEventHappening = false;
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);

    -- Fade screen out and fade challenge popup in.
    transition.to(self.view, { alpha = 0, duration = 500 });
    local cp = self.resMan:getDisplayGroup("cpChallengePopup");
    cp.y = -(display.contentHeight * 2);
    cp.isVisible = true;
    transition.to(cp, { time = 500, y = display.contentCenterY - 1000, transition = easing.inOutBounce,
      onComplete = function()
        self.resMan:getTextField("cpTFUsername").isVisible = true;
      end
    });

  end

end -- End btnChallengeHandler().


---
-- Handler for touch events on the Back item.
--
-- @param inEvent The event object.
--
function scene:btnBackTouchHandler(inEvent)

  if inEvent.phase == "began" then

    self.isTouchEventHappening = true;
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);

  elseif (inEvent.phase == "ended" or inEvent.phase == "cancelled") and
    challengePopup.showing == false then

    if self.refreshTimer ~= nil then
      timer.cancel(self.refreshTimer);
    end
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);

  end

end -- End btnBackHandler().


---
-- Called when the user taps on a match in the list.
--
-- @param inMatch The match descriptor object.
--
function scene:matchSelectedHandler(inMatch)

  local isOpponent = false;
  if inMatch.opponent == gameState.username then
    isOpponent = true;
  end

  -- Pending approval.
  if inMatch.status == "p" then

    -- Accept the invitation if the player is the opponent.
    if isOpponent == true then
      serverDelegate:acceptInvitation(
        inMatch.token,
        function(inResult)
          if inResult == true then
            currentMatch = inMatch;
            composer.gotoScene("matchGameSelection.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
          end
        end
      );
    else
      dialog:show({
        text = "I'm sorry but " .. utils:trim(inMatch.opponent) .. " hasn't accepted this challenge yet.",
        callback = function(inButtonType) end
      });
    end

  -- Declined.
  elseif inMatch.status == "d" then

    if isOpponent == true then
      dialog:show({
        text = "I'm sorry but you already declined this challenge.", callback = function(inButtonType) end
      });
    else
      dialog:show({
        text = "I'm sorry but " .. utils:trim(inMatch.opponent) .. " declined this challenge.",
        callback = function(inButtonType) end
      });
    end

  -- Ended.
  elseif inMatch.status == "e" then

    dialog:show({ text = "I'm sorry but this match has already ended.", callback = function(inButtonType) end });

  -- Running.
  elseif inMatch.status == "r" then

    if isOpponent == true and inMatch.currentTurn == "o" then

      -- Need to select new games to play for this round.
      currentMatch = inMatch;
      composer.gotoScene("matchGameSelection.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);

    elseif isOpponent == false and inMatch.currentTurn == "i" then

      -- First, find the index into gameList for each game ID we were told to play in this round.
      currentMatch = inMatch;
      matchRoundGames = { };
      for i = 1, #currentMatch.roundGamesArray, 1 do
        table.insert(matchRoundGames, globalFunctions:findGameIndexByID(currentMatch.roundGamesArray[i]));
      end

      -- Finally, start the round.  At this point, it should work just like from the matchGameSelection scene.
      textTitle:stopAnimation();
      textTitle.isVisible = false;
      matchRoundGamesIndex = 1;
      isPlayingMatchRound = true;
      matchRoundScore = 0;
      composer.gotoScene(
        "miniGames." .. gameList[matchRoundGames[matchRoundGamesIndex]].internalName .. ".main",
        SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME
      );

    else

      -- Any other combination of isOpponent and inMatch.currentTurn means it's not this player's turn.
      dialog:show({ text = "I'm sorry but it isn't your turn yet.", callback = function(inButtonType) end });

    end

  end

end -- End matchSelectedHandler().


--- ==================================================================================================================
--  ==================================================================================================================
--  Utility Functions
--  ==================================================================================================================
--  ==================================================================================================================


---
-- Populates the list of matches returned by the server.

-- @param inList The list as returned by the server and parsed by serverDelegate.
--
function scene:populateList(inList)

  self.matchList = inList;
  for i = 1, #self.matchList, 1 do

    local match = self.matchList[i];
    match.shouldPulse = false;
    --utils:log("challengeLobby", "populateList() match object", match);

    -- Determine the name of the other player and trim/uppercase it.
    local otherPlayerName = match.initiator;
    if match.initiator == gameState.username then
      otherPlayerName = match.opponent;
    end
    local otherPlayerNameForDisplay = string.upper(utils:trim(otherPlayerName));

    -- Determine the status to display, the caption of the match row box.

    -- Pending
    if match.status == "p" then

      if match.initiator == gameState.username then
        match.caption = "Waiting for " .. otherPlayerNameForDisplay .. " to accept this challenge";
      else
        match.shouldPulse = true;
        match.caption = otherPlayerNameForDisplay .. " has challenged you!";
      end

    -- Declined.
    elseif match.status == "d" then

      if match.initiator == gameState.username then
        match.caption = "Sorry, " .. otherPlayerNameForDisplay .. " declined this challenge";
      else
        match.caption = "You declined this challenge from " .. otherPlayerNameForDisplay;
      end

    -- Ended.
    elseif match.status == "e" then

      if (match.outcome == "i" and match.initiator == gameState.username) or
         (match.outcome == "o" and match.opponent == gameState.username) then
        match.caption = "You defeated " .. otherPlayerNameForDisplay .. "!";
      else
        if match.finalInitiatorScore == match.finalOpponentScore then
          match.caption = "Match ended in a tie";
        else
          match.caption = "Sorry, " .. otherPlayerNameForDisplay .. " defeated you";
        end
      end

      -- Running.
    elseif match.status == "r" then

      if (match.currentTurn == "i" and match.initiator == gameState.username) or
          (match.currentTurn == "o" and match.opponent == gameState.username)then
        match.shouldPulse = true;
        match.caption = "It's YOUR turn! (versus " .. otherPlayerNameForDisplay .. ")";
      else
        match.caption = "It's " .. otherPlayerNameForDisplay .. "'s turn";
      end

    end

  end

  -- Populate TableView.
  local tv = self.resMan:getTableView("matchListTableView");
  tv:deleteAllRows();
  for i = 1, #self.matchList do
    tv:insertRow({
      rowHeight = self.listRowHeight,
      rowColor = {
        default = { 0, 0, 0, 0 },
        over = { 255, 0, 0 }
      };
      isCategory = false,
      params = self.matchList[i]
    });
  end
  if #self.matchList == 0 then
    self.resMan:getTextCandy("textNoMatches").isVisible = true;
    self.resMan:getImage("frown").isVisible = true;
  else
    self.resMan:getTextCandy("textNoMatches").isVisible = false;
    self.resMan:getImage("frown").isVisible = false;
  end

end -- End populateList().


---
-- Function called every 20 seconds to automatically refresh the list.  Note that the reference to scene is required to
-- get the proper scope here.  There's probably a better way to do this but it was eluding me, so it is what it is.
--
function scene:refreshList()

  -- Only fire off a request if there isn't already one in flight.
  if scene.isRefreshRequestInFlight == false and scene.isTouchEventHappening == false and
    challengePopup.showing == false then

    scene.isRefreshRequestInFlight = true;
    serverDelegate:getMatchStatus(
      function(inList)
        if inList == nil then
          composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
        else
          scene:populateList(inList);
          scene.isRefreshRequestInFlight = false;
        end
      end
    );

  end

end -- End refreshList().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("challengeLobby", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
