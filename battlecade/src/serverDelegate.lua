-- The serverDelegate object.
local serverDelegate = { };


-- The URL of the server service endpoint.
serverDelegate.serviceEndpoint = "XXX";

-- The HTTP method to use for all service calls.
serverDelegate.httpMethod = "POST";

-- The API version we're currently at.
serverDelegate.apiVersion = "1";

-- Scrim components.
serverDelegate.scrimBackground = nil;
serverDelegate.scrimSpinner = nil;

-- Generic message to show when the server can't be reached or any unknown error occurs making a request.
serverDelegate.unknownErrorMessage = "I'm sorry but an error occurred contacting the server. Please try again.";

-- Is a request being retried?
serverDelegate.isRetrying = false;

-- How many times we've tried the current request.
serverDelegate.retryCount = nil;

-- The time to wait before the next retry.
serverDelegate.retryDelay = 0;

-- The arguments passed to the method for the in-flight request.  This is only used for retryable requests (which
-- is currently only the updateStatus request).
serverDelegate.requestArgs = { };


---
-- Checks to see if an incoming response is valid, that is, isn't an error and is well-formed.
--
-- @param inCaller The name of the function calling this one.
-- @param inEvent The event object passed to the network.request() callback.
--
function serverDelegate:commonHandler(inCaller, inEvent, inCallback)

  --utils:log("serverDelegate." .. inCaller .. "() response = ", inEvent.response);

  serverDelegate:hideScrim();

  local isError = false;

  -- Make sure we actually got a response of some sort.
  if inEvent == nil or inEvent.isError == true or inEvent.status ~=200 or inEvent.response == nil or
    inEvent.response == "" then
    isError = true;
  end
  -- Make sure our prefix code is there.
  local prefixCode = string.sub(inEvent.response, 1, 2);
  if prefixCode ~= "Bc" then
    isError = true;
  end
  -- Make sure we got a response body.
  local response = string.sub(inEvent.response, 3);
  if response == nil then
    isError = true;
  end
  -- If we got any sort of error, handle that.
  if isError == true then
    inCallback(nil);
    dialog:show({ text = serverDelegate.unknownErrorMessage, callback = function(inButtonType) end });
    response = nil;
  end
  -- No error, just return the response body minus the prefix code.
  return response;

end -- End commonHandler().


---
-- Calls the server to get high-level metadata about the game.
--
-- @param inCallback Function to call when response comes back.  Will be passed any message to be displayed.
--
function serverDelegate:ping(inCallback)

  --utils:log("serverDelegate", "ping()");

  network.request(serverDelegate.serviceEndpoint, serverDelegate.httpMethod,
    function(inEvent)
      -- Make sure we actually got a response of some sort.
      if inEvent ~= nil and inEvent.isError == false and inEvent.status == 200 and inEvent.response ~= nil and
        inEvent.response ~= "" then
        -- Make sure our prefix code is there.
        if string.len(inEvent.response) >= 2 then
          local prefixCode = string.sub(inEvent.response, 1, 2);
          if prefixCode == "Bc" then
            local ver;
            if string.len(inEvent.response) >= 4 then
              ver = string.sub(inEvent.response, 3, 4);
            end
            local msg;
            if string.len(inEvent.response) > 4 then
              msg = string.sub(inEvent.response, 5);
            end
            inCallback({ ver = ver, msg = msg });
          end
        end
      end
    end,
    { body = serverDelegate.apiVersion .. "p" ..
      "                                        "
    }
  );

end -- End ping().


---
-- Calls the server to register a user.  If successful then scene is transitioned to the challenge lobby.
--
-- @param inUsername The username to register.
-- @param inPassword The password to retister.
-- @param inCallback Function to call when response comes back.  Will be passed one of "registered",
--                   "alreadyRegistered" or "loggedIn" if successful, nil if not.
--
function serverDelegate:registerUser(inUsername, inPassword, inCallback)

  --utils:log("serverDelegate", "registerUser()");
  --utils:log("serverDelegate", "registerUser() inUsername: ", inUsername);
  --utils:log("serverDelegate", "registerUser() inPassword: ", inPassword);

  serverDelegate:showScrim();

  -- Pad out the username and password for the purposes of the server request.
  serverDelegate.username = string.format("%-10s", inUsername);
  serverDelegate.password = string.format("%-10s", inPassword);

  network.request(serverDelegate.serviceEndpoint, serverDelegate.httpMethod,
    function(inEvent)
      local response = serverDelegate:commonHandler("registerUser", inEvent, inCallback);
      if response ~= nil then
        -- Username not already taken, user registered.
        if response == "0" then
          -- All good!  Update and write out game state.
          gameState.username = serverDelegate.username;
          gameState.password = serverDelegate.password;
          globalFunctions.saveGameState();
          inCallback("registered");
        -- Username already taken and password was NOT correct.
        elseif response == "1" then
          inCallback("alreadyRegistered");
        -- Username already taken and password WAS correct (existing user logging in).
        elseif response == "2" then
          -- All good!  Update and write out game state.
          gameState.username = serverDelegate.username;
          gameState.password = serverDelegate.password;
          globalFunctions.saveGameState();
          inCallback("loggedIn");
        else
          -- Got some unexpected response, treat it the same as an error above (in theory, none of these should ever
          -- happen, so this is the right way to handle it).
          inCallback(nil);
          dialog:show({ text = serverDelegate.unknownErrorMessage, callback = function(inButtonType) end });
        end
      end
    end,
    { body = serverDelegate.apiVersion .. "r" ..
      "                    " .. serverDelegate.username .. serverDelegate.password
    }
  );

end -- End registerUser().


---
-- Calls the server to get a list of matches the player is involved with.  If successful, the list of matches is
-- parsed into an array of objects and is then passed to the supplied callback.
--
-- @param inCallback The function to call when the response comes back and is parsed into an array of objects.
--                   Will be passed an updated match list if request is successful, nil if not.
--
function serverDelegate:getMatchStatus(inCallback)

  --utils:log("serverDelegate", "getMatchStatus()");

  serverDelegate:showScrim();

  network.request(serverDelegate.serviceEndpoint, serverDelegate.httpMethod,
    function(inEvent)
      local response = serverDelegate:commonHandler("getMatchStatus", inEvent, inCallback);
      if response ~= nil then
        -- Special case: when there's no matches, we'll get a single tilde from the server, and we need to pass an
        -- empty table to the callback.
        if response == "~" then
          inCallback({});
        else
          local matchList = serverDelegate:parseMatchList(response);
          inCallback(matchList);
        end
      end
    end,
    { body = serverDelegate.apiVersion .. "g" ..
      gameState.username .. gameState.password
    }
  );

end -- End getMatchStatus().


---
-- Calls the server to send a challenge invitation.  If successful, a follow-up call is made to get a refreshed list
-- of matches the player is involved with and then that list of matches is parsed into an array of objects and is then
-- passed to the supplied callback.
--
-- @param inOpponentUsername The username of the opponent being challenged.
-- @param inNumberOfRounds   How many rounds of gameplay the challenger selected.
-- Wparam inGamesPerRound    How many games per round the challenger selected.
-- @param inCallback         The function to call when the response comes back and is parsed into an array of objects.
--                           Will be passed an updated match list if successful, nil if not.
--
function serverDelegate:sendInvitation(inOpponentUsername, inNumberOfRounds, inGamesPerRound, inCallback)

  --utils:log("serverDelegate", "sendInvitation()");

  serverDelegate:showScrim();

  -- Pad out the opponent username for the purposes of the server request.
  local opponentUsername = string.format("%-10s", inOpponentUsername);

  network.request(serverDelegate.serviceEndpoint, serverDelegate.httpMethod,
    function(inEvent)
      local response = serverDelegate:commonHandler("sendInvitation", inEvent, inCallback);
      if response ~= nil then
        if response == "1" then
          inCallback("unknownUser");
        else
          local matchList = serverDelegate:parseMatchList(response);
          inCallback(matchList);
        end
      end
    end,
    { body = serverDelegate.apiVersion .. "s" ..
      gameState.username .. gameState.password .. opponentUsername .. inNumberOfRounds .. inGamesPerRound
    }
  );

end -- End sendInvitation().


---
-- Calls the server to accept a match invitation.
--
-- @param inMatchToken The token for the match to accept the invitaiton for.
-- @param inCallback   Function to call when the repsonse comes back.  Will be passed true if the request was
--                     successful, nil if not.
--
function serverDelegate:acceptInvitation(inMatchToken, inCallback)

  --utils:log("serverDelegate", "acceptInvitation()");
  --utils:log("serverDelegate", "acceptInvitation() inMatchToken: ", inMatchToken);

  serverDelegate:showScrim();

  network.request(serverDelegate.serviceEndpoint, serverDelegate.httpMethod,
    function(inEvent)
      local response = serverDelegate:commonHandler("acceptInvitation", inEvent, inCallback);
      if response ~= nil then
        if response == "0" then
          inCallback(true);
        else
          -- Got some unexpected response, treat it the same as an error above (in theory, none of these should ever
          -- happen, so this is the right way to handle it).
          inCallback(nil);
          dialog:show({ text = serverDelegate.unknownErrorMessage, callback = function(inButtonType) end });
        end
      end
    end,
    { body = serverDelegate.apiVersion .. "a" ..
      gameState.username .. gameState.password .. inMatchToken .. "a"
    }
  );

end -- End acceptInvitation().


---
-- Calls the server to update the status of a match.  This is called after the player completes a round of play.
--
-- @param inCallback The function to call when the server response comes back.  Will be passed one of "0", "i", "o" or
--                   "t" if succesful, nil if not.
--
function serverDelegate:updateMatchStatus(inCallback)

  --utils:log("updateMatchStatus", "updateMatchStatus()");

  serverDelegate:showScrim();

  if serverDelegate.isRetrying == true then
    -- We're retrying, so we'll need the arguments originally passed to this function.
    inCallback = serverDelegate.requestArgs.inCallback;
  else
    -- Record any arguments passed to this function in case we need them during retry.
    serverDelegate.requestArgs.inCallback = inCallback;
  end

  -- Get round score and list of game IDs and pad out appropriately for this message.
  local roundScore = matchRoundScore;
  roundScore = string.format("%-4s", tostring(roundScore));
  local gameIDs = "";
  for i = 1, #matchRoundGames, 1 do
    gameIDs = gameIDs .. gameList[matchRoundGames[i]].matchID;
  end
  gameIDs = string.format("%-10s", gameIDs);

  network.request(serverDelegate.serviceEndpoint, serverDelegate.httpMethod,
    function(inEvent)
      -- If we get any error code back we'll handle this as a retryable request.
      if inEvent.status ~= 200 then
        serverDelegate.isRetrying = true;
        serverDelegate.retryCount = serverDelegate.retryCount + 1;
        serverDelegate.retryDelay = serverDelegate.retryDelay + 3;
        -- If we haven't maxed out retry attempt yet then do another.
        if serverDelegate.retryCount < 4 then
          timer.performWithDelay(serverDelegate.retryDelay * 1000, serverDelegate.getMatchStatus, 1);
          return;
        end
      end
      -- Ensure subsequent calls to this function don't go into retry logic immediately.
      serverDelegate.isRetrying = false;
      serverDelegate.retryCount = 0;
      serverDelegate.retryDelay = 0;
      local response = serverDelegate:commonHandler("updateMatchStatus", inEvent, inCallback);
      if response ~= nil then
        if response == "0" or response == "i" or response == "o" or response == "t" then
          inCallback(response);
        else
          -- Got some unexpected response, treat it the same as an error above (in theory, none of these should ever
          -- happen, so this is the right way to handle it).
          inCallback(nil);
          dialog:show({ text = serverDelegate.unknownErrorMessage, callback = function(inButtonType) end });
        end
      end
    end,
    { body = serverDelegate.apiVersion .. "u" ..
      gameState.username .. gameState.password .. currentMatch.token .. roundScore .. gameIDs
    }
  );

end -- End updateMatchStatus().


--- ====================================================================================================================
--  ====================================================================================================================
--  Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Parses a resonse from the server that is a list of matches and returns an array of object suitable for insertion
-- into a list widget.
--
-- @param  inServerResponse The response from the server.
-- @return                  An array of objects, one for each match.
--
function serverDelegate:parseMatchList(inServerResponse)

  local matchList = { };
  local tokens = utils:split(inServerResponse, "~");
  for i = 1, #tokens, 1 do
    local match = { };
    match.token = string.sub(tokens[i], 1, 12);
    match.initiator = string.sub(tokens[i], 13, 22);
    match.opponent = string.sub(tokens[i], 23, 32);
    match.numRounds = tonumber(string.sub(tokens[i], 33, 33));
    match.numGamesPerRound = tonumber(string.sub(tokens[i], 34, 34));
    match.status = string.sub(tokens[i], 35, 35);
    match.currentRound = tonumber(string.sub(tokens[i], 36, 36));
    match.currentTurn = string.sub(tokens[i], 37, 37);
    match.outcome = string.sub(tokens[i], 38, 38);
    match.finalInitiatorScore = tonumber(string.sub(tokens[i], 39, 42));
    match.finalOpponentScore = tonumber(string.sub(tokens[i], 43, 46));
    match.roundGames = string.sub(tokens[i], 47, 61);
    match.roundGamesArray = { };
    local game1 = string.sub(match.roundGames, 1, 2);
    local game2 = string.sub(match.roundGames, 3, 4);
    local game3 = string.sub(match.roundGames, 5, 6);
    local game4 = string.sub(match.roundGames, 7, 8);
    local game5 = string.sub(match.roundGames, 9, 10);
    if game1 ~= "  " then
      table.insert(match.roundGamesArray, game1);
    end
    if game2 ~= "  " then
      table.insert(match.roundGamesArray, game2);
    end
    if game3 ~= "  " then
      table.insert(match.roundGamesArray, game3);
    end
    if game4 ~= "  " then
      table.insert(match.roundGamesArray, game4);
    end
    if game5 ~= "  " then
      table.insert(match.roundGamesArray, game5);
    end
    table.insert(matchList, match);
  end

  return matchList;

end -- End parseMatchList().


---
-- Shows the scrim during server calls.
--
function serverDelegate:showScrim()

  if serverDelegate.isRetrying == false then

    serverDelegate.scrimBackground = display.newRect(
      display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight
    );
    serverDelegate.scrimBackground:setFillColor(0, 0, 0, .75);
    serverDelegate.scrimBackground:toFront();
    serverDelegate.scrimBackground:addEventListener("tap",
      function()
        return true;
      end
    );
    serverDelegate.scrimBackground:addEventListener("touch",
      function()
        return true;
      end
    );
    serverDelegate.scrimSpinner = display.newImage(
      "scrimSpinner.png", display.contentCenterX, display.contentCenterY
    );
    serverDelegate.scrimSpinner:toFront();
    serverDelegate.scrimSpinner.startTransition = function()
      serverDelegate.scrimSpinner.rotationTransition = transition.to(
        serverDelegate.scrimSpinner, {
          delta = true, rotation = 360, delay = 0,
          onComplete = function(inObject)
            inObject:startTransition();
          end
        }
      );
    end
    serverDelegate.scrimBackground:toFront();
    serverDelegate.scrimSpinner:toFront();
    serverDelegate.scrimSpinner.startTransition();

  end

end -- showScrim().


---
-- Hides the scrim during server calls.
--
function serverDelegate:hideScrim()

  serverDelegate.scrimBackground:removeSelf();
  serverDelegate.scrimBackground = nil;
  transition.cancel(serverDelegate.scrimSpinner.rotationTransition);
  serverDelegate.scrimSpinner:removeSelf();
  serverDelegate.scrimSpinner = nil;

  -- Ensure subsequent calls to request functions don't go into retry logic immediately.
  serverDelegate.isRetrying = false;
  serverDelegate.retryCount = 0;
  serverDelegate.retryDelay = 0;

end -- hideScrim().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


return serverDelegate;
