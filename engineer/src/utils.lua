-- FPS & info bar objects.
underlay = nil;
displayInfo = nil;


-- The utils object.
local utils = {

  -- Are we running in the simulator?
  isSimulator = false,

  -- Are we running on an iOS device?
  isIOS = false,

  -- Are we running on an Android device?
  isAndroid = false,

  -- Are we running on a Windows desktop?
  isWin = false,

  -- Are we running on a Mac OS X desktop?
  isMac = false,

  -- Reference to the open log file.
  logFile = nil

};


-- Set various flags in utils object.
if string.lower(system.getInfo("environment")) == "simulator" then
  utils.isSimulator = true;
end
if string.lower(system.getInfo("platformName")) == "iphone os" then
  utils.isIOS = true;
end
if string.lower(system.getInfo("platformName")) == "android" then
  utils.isAndroid = true;
end
if string.lower(system.getInfo("platformName")) == "win" then
  utils.isWin = true;
end
if string.lower(system.getInfo("platformName")) == "mac os x" then
  utils.isMac = true;
end


-- ============================================================================
-- Simple common logging function.  Note that this uses json.encode(), which
-- sometimes won't properly encode user data.
--
-- @param inFilename The name of the calling lua file.  Required.
-- @param inMessage  Text message to display.  Required.
-- @param inObject   An optional object to log.  If not nil then json.encode()
--                   is used to convert to a string.
-- ============================================================================
function utils:log(inFilename, inMessage, inObject)

  -- If inObject is nil then we'll print a blank string, but otherwise we'll
  -- encode it and prefix it with a separator.
  if inObject == nil then
    inObject = " ";
  else
    inObject = " - " .. json.encode(inObject);
  end

  -- Construct and print it.
  local logMessage = inFilename .. " - " .. inMessage .. inObject;
  print(logMessage);

  -- Write to log file, if enabled.
  if logToFile == true then
    if utils.logFile == nil then
      local path = system.pathForFile("log.txt", system.DocumentsDirectory);
      utils.logFile = io.open(path, "w");
      if utils.logFile == nil then
        utils.logFile = io.open(path, "w");
      end
    end
    utils.logFile:write(logMessage .. "\n");
  end

end -- End log().


-- ============================================================================
-- Closes the log file, if it was opened.
-- ============================================================================
function utils:closeLogFile()

  if utils.logFile ~= nil then
    io.close(utils.logFile);
  end

end -- End closeLogFile().


-- ============================================================================
-- Splits a string.
--
-- @param  inS The string to split.
-- @param  inD The delimiter to split on.
-- @return A table (an array essentially) of the resultant string.
-- ============================================================================
function utils:split(inS, inD)

  local t = {};
  local rx = "[^" .. inD .. "]+";
  for w in string.gmatch(inS, rx) do
    t[#t + 1] = w;
  end
  return t;

end -- End split().


-- ============================================================================
-- Dumps the complete contents of a table to the console.
--
-- @param inT The table to dump.
-- ============================================================================
function utils:dump(inT)

  local print_r_cache = {};

  local function sub_print_r(inT, indent)

    if (print_r_cache[tostring(inT)]) then
      print(indent.."*" .. tostring(inT));
    else
      print_r_cache[tostring(inT)] = true;
      if (type(inT) == "table") then
        for pos, val in pairs(inT) do
          if (type(val) == "table") then
            print(indent .. "[" .. pos .. "] => " .. tostring(inT) .. " {");
            sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8));
            print(indent .. string.rep(" ", string.len(pos) + 6) .. "}");
          elseif (type(val) == "string") then
            print(indent .. "[" .. pos .. '] => "' .. val .. '"');
          else
            print(indent .. "[" .. pos .. "] => " .. tostring(val));
          end
        end
      else
        print(indent .. tostring(inT));
      end
    end
  end

  if (type(inT) == "table") then
      print(tostring(inT) .. " {");
    sub_print_r(inT, "  ");
    print("}");
  else
    sub_print_r(inT, "  ");
  end

  print();

end -- End dump().


-- ============================================================================
-- Shows frame rate and memory usage.  Call once at application startup.
-- ============================================================================
function utils:showFPSAndMem()

  local prevTime = 0;
  local curTime = 0;
  local dt = 0;
  local fps = 60;
  local mem = 0;
  local frameCount = 0;
  local avg = 0;
  local slowest = 1000;
   underlay = display.newRect(
    0, display.contentHeight - 30, display.contentWidth, 34
  );
  utils:attachDevMenu(underlay);
  underlay:setReferencePoint(display.TopLeftReferencePoint);
  underlay:setFillColor(0, 0, 0, 128);
   displayInfo = display.newText(
    "FPS: ??, Avg: ?, Slowest: ?, Mem: ????mb", 0, 0, native.systemFontBold, 20
  );
  displayInfo.x = display.contentWidth / 2;
  displayInfo.y = display.contentHeight - 14;
  local function updateText()
    curTime = system.getTimer();
    dt = curTime - prevTime;
    prevTime = curTime;
    fps = math.floor(1000 / dt);
    mem = system.getInfo("textureMemoryUsed") / 1000000;
    if fps > 60 then
      fps = 60
    end
    frameCount = frameCount + 1;
    if frameCount > 150 then
      avg = avg + fps;
      if fps < slowest then
        slowest = fps;
      end
    end
    local a = math.round(avg / (frameCount - 150));
    a = math.floor(a * math.pow(10, 0) + 0.5) / math.pow(10, 0);
    collectgarbage()
    local sysMem = collectgarbage("count") * 0.001;
    sysMem = math.floor(sysMem * 1000) * 0.001;
    displayInfo.text = "FPS: " .. fps .. ", Avg: " .. a ..
      ", Slowest: " .. slowest ..
      ", T-Mem: " .. string.sub(mem, 1, string.len(mem) - 4) .. "mb" ..
      ", S-Mem: " .. sysMem .. "mb";
    underlay:toFront()
    displayInfo:toFront()
  end
  underlay.isVisible = false;
  displayInfo.isVisible = false;
  Runtime:addEventListener("enterFrame", updateText)

end -- End showFPSAndMem().


-- ============================================================================
-- Attaches the developer menu to the FPS underlay graphic.
--
-- @param inUnderlay The underlay DisplayObject.
-- ============================================================================
function utils:attachDevMenu(inUnderlay)

  inUnderlay:addEventListener("touch",
    function(inEvent)
      if inEvent.phase == "began" then

        if devMenuDG ~= nil then
          devMenuDG:removeSelf();
          devMenuDG = nil;
          return;
        end

        devMenuDG = display.newGroup();
        local y = 10;
        local yIncrement = 75;
        local t;

        -- Create underlay graphic.
        local u = display.newRect(
          0, 0, display.contentWidth, display.contentHeight
        );
        u:setReferencePoint(display.TopLeftReferencePoint);
        u:setFillColor(0, 0, 0, 200);
        devMenuDG:insert(u);

        -- Option: Activate All Powerups.
        t = display.newText("Activate All Powerups", 0, y, nil, 48);
        t.x = display.contentWidth / 2;
        t:setFillColor(255, 255, 255);
        t:addEventListener("touch",
          function(inEvent)
            if inEvent.phase == "began" then
              gameState.powerups[POWERUP_FIXIT] = true;
              gameState.powerups[POWERUP_DEGAUSS] = true;
              gameState.powerups[POWERUP_GRAVITY] = true;
              gameState.powerups[POWERUP_OFFLINE] = true;
              powerupsButton.sprite:prepare("available");
              powerupsButton.sprite:play();
              -- Clean up.
              devMenuDG:removeSelf();
              devMenuDG = nil;
            end
          end
        );
        devMenuDG:insert(t);

        -- Option: Unlock All Levels.
        y = y + yIncrement;
        t = display.newText(
          "Unlock All Levels (".. tostring(allLevelsUnlocked) .. ")",
          0, y, nil, 48
        );
        t.x = display.contentWidth / 2;
        t:setFillColor(255, 255, 255);
        t:addEventListener("touch",
          function(inEvent)
            if inEvent.phase == "began" then
              allLevelsUnlocked = true;
              for i = 1, numLevels, 1 do
                gameState.levelLocks[i] = false;
              end
              -- Clean up.
              devMenuDG:removeSelf();
              devMenuDG = nil;
            end
          end
        );
        devMenuDG:insert(t);

        devMenuDG:toFront();

      end
    end
  );

end -- End attachDevMenu().


-- ============================================================================
-- Finds the distance between two points.
--
-- @param  inA The first point (an object with properties x and y).
-- @param  inB The second point (an object with properties x and y).
-- @return     The distance.
-- ============================================================================
function utils:distanceBetween(inA, ibB)

  local w = inB.x - inA.x;
  local h = inB.y - inA.y;
  return math.sqrt((w * w) + (h * h));

end -- End distanceBetween().


-- ============================================================================
-- Finds what percentage a given number is of another number.  For exmaple,
-- if inTotal is 200 and inPart is 90 then this returns 45, which means
-- 90 is 45% of 200.
--
-- @param  inTotal The total number (200 in the example).
-- @param  inPart  The partial number (45 in the example).
-- @return         The percentage inPart is of inTotal (45 in the example).
-- ============================================================================
function utils:percentageOf(inTotal, inPart)

  return (inPart / inTotal) * 100;

end -- End percentageOf().


-- ============================================================================
-- Determines if two lines intersect, and if so, where.
--
-- @param  a Endpoint of line 1 as a point object (properties x and y).
-- @param  b Endpoint of line 1 as a point object (properties x and y).
-- @param  c Endpoint of line 2 as a point object (properties x and y).
-- @param  d Endpoint of line 2 as a point object (properties x and y).
-- @return   false if the lines don't intersect, or true and the point at
--           which they do if they do.
-- ============================================================================
function utils:doLinesIntersect(a, b, c, d)

  local L1 = { X1 = inA.x, Y1 = inA.y, X2 = inB.x, Y2 = inB.y };
  local L2 = { X1 = inC.x, Y1 = inC.y, X2 = inD.x, Y2 = inD.y };

  local d = ( L2.Y2 - L2.Y1 ) * ( L1.X2 - L1.X1 ) -
    ( L2.X2 - L2.X1 ) * ( L1.Y2 - L1.Y1 );

  if (d == 0) then
    return false;
  end

  local n_a = ( L2.X2 - L2.X1 ) * ( L1.Y1 - L2.Y1 ) -
    ( L2.Y2 - L2.Y1 ) * ( L1.X1 - L2.X1 );
  local n_b = ( L1.X2 - L1.X1 ) * ( L1.Y1 - L2.Y1 ) -
    ( L1.Y2 - L1.Y1 ) * ( L1.X1 - L2.X1 );

  local ua = n_a / d;
  local ub = n_b / d;

  if (ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1) then
    local x = L1.X1 + ( ua * ( L1.X2 - L1.X1 ) );
    local y = L1.Y1 + ( ua * ( L1.Y2 - L1.Y1 ) );
    return true, {x = x, y = y};
  end

  return false;

end -- End doLinesIntersect().


-- ============================================================================
-- Copies the keys and values from one table into another.  This properly
-- handled deep-copying of nested tables as well.
--
-- @param  inFromTable The table to copy from.
-- @param  inToTable   The table to copy into.
-- @return             inToTable with the keys and values from inFromTable
--                     in it.
-- ============================================================================
function utils:copyTable(inFromTable, inToTable)

  function _extend(fT, tT)

    for k,v in pairs( fT ) do
      if type(fT[k]) == "table" and type(tT[k]) == "table" then
        tT[k] = _extend(fT[k], tT[k]);
      elseif type(fT[k]) == "table" then
        tT[k] = _extend(fT[k], {});
      else
        tT[k] = v;
      end
    end
    return tT;
  end

  return _extend( fromTable, toTable )

end -- End copyTable().


-- ============================================================================
-- "Clamps" a value to a given range.
--
-- @param  inVal The value to clamp.
-- @param  inMin The minimum value of the range.
-- @param  inMax The maximim value of the range.
-- @return       inVal if it's within the range, inMin if inVal is below the
--               range, inMax if inVal is above the range.
-- ============================================================================
function utils:clamp(inVal, inMin, inMax)

  if inVal < inMin then
    return inMin;
  elseif inVal > inMax then
    return inMax;
  else
    return inVal;
  end

end -- End clamp().


-- ============================================================================
-- Returns a new table with the values from the given table.  For example:
--
-- names = { first = "Bob", second = "Joe", "Doe" };
-- TableUtils.values(names);
-- returns: { "Bob", "Joe", "Doe" }
--
-- @param  inTable The table.
-- @return         New table with the values from inTable.
-- ============================================================================
function utils:getTableValues(inTable)

  local array = {};
  for k, v in pairs(inTable) do
    table.insert(array, v);
  end
  return array;

end -- End getTableValues().


-- ============================================================================
-- Returns a new table with the keys from the given table.  For example:
--
-- names = { first = "Bob", second = "Joe", "Doe" };
-- TableUtils.values(names);
-- returns: { "first", "second", "Doe" }
--
-- @param  inTable The table.
-- @return         New table with the keys from inTable.
-- ============================================================================
function utils:getTableKeys(inTable)

  local array = {};
  for k,v in pairs(inTable) do
    table.insert(array, k);
  end
  return array;

end -- End getTableKeys().


-- ============================================================================
-- Checks if the given table is empty.
--
-- @param  inTable The table.
-- @return         True if the table is empty, false if not.
-- ============================================================================
function utils:isTableEmpty(inTable)

  return #inTable == 0;

end -- End isTableEmpty().


-- ============================================================================
-- Horizontally mirror a display object.
--
-- @param inObject The DisplayObject to mirror.
-- ============================================================================
function utils:mirrorDisplayObject(inObject)

  inObject:scale(-1, 1);

end -- End mirrorDisplayObject().


-- ============================================================================
-- Vertically flips a display object.
--
-- @param inObject The DisplayObject to flip.
-- ============================================================================
function utils:flipDisplayObject(inObject)

  inObject:scale(1, -1);

end -- End flipDisplayObject().


-- ============================================================================
-- Constructs an audio filename appropriate for the current platform.  This
-- takes care of switching between .ogg and .m4a files for Android and iOS
-- devices respectively.  For a Windows desktop we use the .ogg version and
-- for a Mac OS X desktop we use the .m4a version.
--
-- @param inAudioName The name of the audio file to play without extension.
-- ============================================================================
function utils:getAudioFilename(inAudioName)

  if utils.isIOS == true then
    return inAudioName .. ".m4a";
  elseif utils.isAndroid == true then
    return inAudioName .. ".ogg";
  elseif utils.isWin == true then
    return inAudioName .. ".ogg";
  elseif utils.isMac == true then
    return inAudioName .. ".m4a";
  else
    -- Should never happen, but just in case, at least we send SOMETHING back.
    return inAudioName .. ".ogg";
  end

end -- End getAudioFilename().


-- ============================================================================
-- Performs a pcall but abstracts out handling of errors.  NOTE: THIS CANNOT
-- BE USED TO CALL A FUNCTION THAT ACCEPTS ARGUMENTS!
--
-- @param inDesc     A description of the call being attempted.
-- @param inFunction The function to call.
-- ============================================================================
function utils:xpcall(inDesc, inFunction)

  local status, ret = pcall(inFunction);
  if status == true then
    return ret;
  else
    utils:log("** ERROR: " .. inDesc, ret);
    if utils.logFile == nil then
      local path = system.pathForFile("log.txt", system.DocumentsDirectory);
      utils.logFile = io.open(path, "w");
      if utils.logFile == nil then
        utils.logFile = io.open(path, "w");
      end
    end
    utils.logFile:write(inDesc .. "\n" .. ret .. "\n");
  end

end -- End xpcall().


-- ****************************************************************************
-- All done defining utils, return it.
-- ****************************************************************************
return utils;
