local json = require("json");


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


---
-- Show a NATIVE alert dialog, with a single Ok button.
--
-- @param inTitle The title of the alert box.
-- @param inText  The text to show.
--
function utils:alert(inTitle, inText)

  native.showAlert(inTitle, inText, { "Ok" });

end -- End alert().


---
-- Simple common logging function.  Note that this uses json.encode(), which sometimes won't properly encode user data.
-- Also note that if you want to log to a file you need to define a global named debugMode and set it to true.
--
-- @param inFilename The name of the calling lua file.  Required.
-- @param inMessage  Text message to display.  Required.
-- @param inObject   An optional object to log.  If not nil then json.encode() is used to convert to a string.
--
function utils:log(inFilename, inMessage, inObject)

  -- If inObject is nil then we'll print a blank string, but otherwise we'll encode it and prefix it with a separator.
  if inObject == nil then
    inObject = " ";
  else
    inObject = " - " .. json.encode(inObject);
  end

  -- Construct and print it.
  local logMessage = inFilename .. " - " .. inMessage .. inObject;
  print(logMessage);

  -- Write to log file, if enabled.
  if debugMode == true then
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


---
-- Closes the log file, if it was opened.  You generally should call this when the app shuts down if you were
-- logging to a file.
--
function utils:closeLogFile()

  if utils.logFile ~= nil then
    io.close(utils.logFile);
  end

end -- End closeLogFile().


---
-- Splits a string.
--
-- @param  inS The string to split.
-- @param  inD The delimiter to split on.
-- @return A table (an array essentially) of the resultant string.
--
function utils:split(inS, inD)

  local t = {};
  local rx = "[^" .. inD .. "]+";
  for w in string.gmatch(inS, rx) do
    t[#t + 1] = w;
  end
  return t;

end -- End split().


---
-- Dumps the complete contents of a table to the console.
--
-- @param inT The table to dump.
--
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


---
-- Shows frame rate and memory usage.  Call once at application startup.
--
function utils:showFPSAndMem()

  local prevTime = 0;
  local curTime = 0;
  local dt = 0;
  local fps = 60;
  local mem = 0;
  local frameCount = 0;
  local avg = 0;
  local slowest = 1000;
   underlay = display.newRect(display.contentCenterX, display.contentHeight - 20, display.contentWidth, 38);
  utils:attachDevMenu(underlay);
  underlay:setFillColor(255, 0, 0, 128);
  displayInfo = display.newText("FPS: ??, Avg: ?, Slowest: ?, Mem: ????mb", 0, 0, globalNativeFont, 30);
  displayInfo.x = display.contentCenterX;
  displayInfo.y = display.contentHeight - 20;
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
    displayInfo.text = "FPS: " .. fps .. ", Avg: " .. a .. ", Slowest: " .. slowest ..
      ", T-Mem: " .. string.sub(mem, 1, string.len(mem) - 4) .. "mb" .. ", S-Mem: " .. sysMem .. "mb";
    underlay:toFront()
    displayInfo:toFront()
  end
  underlay.isVisible = true;
  displayInfo.isVisible = true;
  Runtime:addEventListener("enterFrame", updateText)

end -- End showFPSAndMem().


---
-- Attaches the developer menu to the FPS underlay graphic.
--
-- @param inUnderlay The underlay DisplayObject.
--
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
        devMenuDG:toFront();

        local y = 200;
        local yIncrement = 200;
        local t;

        -- Create underlay graphic.
        local u = display.newRect(
          devMenuDG, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight
        );
        u:setFillColor(0, 0, 0, 200);
        u:addEventListener("touch",
          function(inEvent)
            return true;
          end
        );

        -- Option: View Log File.
        local t1 = display.newText(devMenuDG, "View Log File", 0, y, globalNativeFont, 48);
        t1.x = display.contentCenterX;
        t1:setTextColor(255, 255, 255);
        t1:addEventListener("touch",
          function(inEvent)
            if inEvent.phase == "ended" then
              utils:closeLogFile();
              local webView = native.newWebView(
                display.contentCenterX, display.contentCenterY,
                display.contentWidth - 100, display.contentHeight - 100
              );
              webView:request("log.txt", system.DocumentsDirectory);
            end
            return true;
          end
        );

        -- Option: View Log File.
        y = y + yIncrement;
        local t2 = display.newText(devMenuDG, "Trigger Unhandled Error", 0, y, globalNativeFont, 48);
        t2.x = display.contentCenterX;
        t2:setTextColor(255, 255, 255);
        t2:addEventListener("touch",
          function(inEvent)
            if inEvent.phase == "ended" then
              display:IDoNotExist();
            end
            return true;
          end
        );

      end
    end
  );

end -- End attachDevMenu().


---
-- Finds the distance between two points.
--
-- @param  inA The first point (an object with properties x and y).
-- @param  inB The second point (an object with properties x and y).
-- @return     The distance.
--
function utils:distanceBetween(inA, inB)

  local w = inB.x - inA.x;
  local h = inB.y - inA.y;
  return math.sqrt((w * w) + (h * h));

end -- End distanceBetween().


---
-- Finds what percentage a given number is of another number.  For exmaple, if inTotal is 200 and inPart is 90 then this
-- returns 45, which means 90 is 45% of 200.
--
-- @param  inTotal The total number (200 in the example).
-- @param  inPart  The partial number (45 in the example).
-- @return         The percentage inPart is of inTotal (45 in the example).
--
function utils:percentageOf(inTotal, inPart)

  return (inPart / inTotal) * 100;

end -- End percentageOf().


---
-- Determines if two lines intersect, and if so, where.
--
-- @param  inA Endpoint of line 1 as a point object (properties x and y).
-- @param  inB Endpoint of line 1 as a point object (properties x and y).
-- @param  inC Endpoint of line 2 as a point object (properties x and y).
-- @param  inD Endpoint of line 2 as a point object (properties x and y).
-- @return     false if the lines don't intersect, or true and the point at which they do if they do.
--
function utils:doLinesIntersect(inA, inB, inC, inD)

  local L1 = { X1 = inA.x, Y1 = inA.y, X2 = inB.x, Y2 = inB.y };
  local L2 = { X1 = inC.x, Y1 = inC.y, X2 = inD.x, Y2 = inD.y };

  local d = (L2.Y2 - L2.Y1) * (L1.X2 - L1.X1) - (L2.X2 - L2.X1) * (L1.Y2 - L1.Y1);

  if d == 0 then
    return false;
  end

  local n_a = (L2.X2 - L2.X1) * (L1.Y1 - L2.Y1) - (L2.Y2 - L2.Y1) * (L1.X1 - L2.X1);
  local n_b = (L1.X2 - L1.X1) * (L1.Y1 - L2.Y1) - (L1.Y2 - L1.Y1) * (L1.X1 - L2.X1);

  local ua = n_a / d;
  local ub = n_b / d;

  if ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1 then
    local x = L1.X1 + (ua * ( L1.X2 - L1.X1 ));
    local y = L1.Y1 + (ua * ( L1.Y2 - L1.Y1 ));
    return true, { x = x, y = y };
  end

  return false;

end -- End doLinesIntersect().


---
-- Copies the keys and values from one table into another.  This properly handled deep-copying of nested tables as well.
--
-- @param  inFromTable The table to copy from.
-- @param  inToTable   The table to copy into.
-- @return             inToTable with the keys and values from inFromTable in it.
--
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

  return _extend(fromTable, toTable);

end -- End copyTable().


---
-- "Clamps" a value to a given range.
--
-- @param  inVal The value to clamp.
-- @param  inMin The minimum value of the range.
-- @param  inMax The maximim value of the range.
-- @return       inVal if it's within the range, inMin if inVal is below the range, inMax if inVal is above the range.
--
function utils:clamp(inVal, inMin, inMax)

  if inVal < inMin then
    return inMin;
  elseif inVal > inMax then
    return inMax;
  else
    return inVal;
  end

end -- End clamp().


---
-- Returns a new table with the values from the given table.  For example:
--
-- names = { first = "Bob", second = "Joe", "Doe" };
-- TableUtils.values(names);
-- returns: { "Bob", "Joe", "Doe" }
--
-- @param  inTable The table.
-- @return         New table with the values from inTable.
--
function utils:getTableValues(inTable)

  local array = {};
  for k, v in pairs(inTable) do
    table.insert(array, v);
  end
  return array;

end -- End getTableValues().


---
-- Returns a new table with the keys from the given table.  For example:
--
-- names = { first = "Bob", second = "Joe", "Doe" };
-- TableUtils.values(names);
-- returns: { "first", "second", "Doe" }
--
-- @param  inTable The table.
-- @return         New table with the keys from inTable.
--
function utils:getTableKeys(inTable)

  local array = {};
  for k, v in pairs(inTable) do
    table.insert(array, k);
  end
  return array;

end -- End getTableKeys().


---
-- Checks if the given table is empty.
--
-- @param  inTable The table.
-- @return         True if the table is empty, false if not.
--
function utils:isTableEmpty(inTable)

  return #inTable == 0;

end -- End isTableEmpty().


---
-- Horizontally mirror a display object.
--
-- @param inObject The DisplayObject to mirror.
--
function utils:mirrorDisplayObject(inObject)

  inObject:scale(-1, 1);

end -- End mirrorDisplayObject().


---
-- Vertically flips a display object.
--
-- @param inObject The DisplayObject to flip.
--
function utils:flipDisplayObject(inObject)

  inObject:scale(1, -1);

end -- End flipDisplayObject().


---
-- Constructs an audio filename appropriate for the current platform.  This takes care of switching between .ogg and
-- .m4a files for Android and iOS devices respectively.  For a Windows desktop we use the .ogg version and for a Mac
-- OS X desktop we use the .m4a version (although the better answer is probably to just use .wav files and forget
-- this method exists... but it's here just in case).
--
-- @param inAudioName The name of the audio file to play without extension.
--
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


---
-- Performs a pcall but abstracts out handling of errors.  NOTE: THIS CANNOT BE USED TO CALL A FUNCTION THAT ACCEPTS
-- ARGUMENTS!
--
-- @param inDesc     A description of the call being attempted.
-- @param inFunction The function to call.
--
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


---
-- Uses the native.showAlert() function to show an alert popup.
--
-- @param inMessage The message to show in the popup.
--
function utils:alert(inMessage)

  if inMessage == nil then
    inMessage = "";
  end

  native.showAlert("Debug", inMessage, { "Ok" });

end -- End alert(). */


---
-- Removes nil elements from an array.
--
-- @param  inMessage The message to show in the popup.
-- @return           The array with all nil elements removed.
--
function utils:cleanArray(inArray)

  if #inArray == 0 then
    return { };
  end

  local a = { };
  for _,v in pairs(inArray) do
    a[#a + 1] = v;
  end
  return a;

end -- End cleanArray();


---
-- Splits a string into a table.
--
-- @param inStr The sring to split.
-- @param inSep The separating character.
--
function utils:strSplit(inStr, inSep)

  local tbl = {};

  -- Get first separator.
  local index = string.find(inStr, inSep, 1, true);

  -- Perform separations while there are substrings.
  while (index ~= nil) do
    -- Get string up to the separator.
    local sub = string.sub(inStr, 1, index - 1);
    -- If the string is 1 character or more (could be two adjacent separators).
    if (string.len(sub) > 0) then
      tbl[#tbl + 1] = sub
    end
    -- Get the rest of the string after the separator.
    inStr = string.sub(str, index + 1);
    -- Find the next separator.
    index = string.find(inStr, inSep, 1, true);
  end
  -- Store the last substring.
  if (string.len(inStr) > 0) then
    tbl[#tbl + 1] = inStr;
  end

  return tbl;

end -- End strSplit().


---
-- Replaces placeholders tokens {1}, {2}, etc with args.
-- eg: "hello banana" = strReplace("{1} {2}", "hello", "banana")
--
-- @param inStr The string to replace tokens in.
-- @param ...   Any number of strings to replace the tokens with.
--
function utils:strReplace(inStr, ...)

  local function inner()
    for i = 1, #arg do
      inStr = string.gsub(inStr, "{"..i.."}", arg[i] or "");
    end
    return str;
  end
  local status, result = pcall(inner);
  if (status) then
    return result;
  else
    utils:log("strReplace fail: ", result, inStr, unpack(arg));
    return nil;
  end

end -- End strReplace().


---
-- Lua equivelent of the JavaScript string indexOf function.
--
-- @param inS       String to search within.
-- @param inPattern String to search for, within the inS parameter.
-- @return          -1 if the pattern is not found within the inS parameter, otherwise the 1-based index of the string.
--
function utils:indexOf(inS, inPattern)

  local index = string.find(inS, inPattern);
  if (index == nil) then
    return -1;
  else
    return index;
  end

end -- End indexOf();


---
-- Trim whitespace from both ends of a string.
--
-- @param  inS The string to trim.
-- @return     The trimmed string.
--
function utils:trim(inS)

  return inS:match'^%s*(.*%S)' or '';

end -- End trim().


---
-- Shuffles the elements in a table.  This shuffles in-place, so no return value.
--
-- @param inTable The table to shuffle.
--
function utils:shuffleTable(inTable)

  local rand = math.random;
  local iterations = #inTable;
  local j;
  for i = iterations, 2, -1 do
    j = rand(i)
    inTable[i], inTable[j] = inTable[j], inTable[i]
  end

end -- End shuffleTable().


---
-- Checks if an array (table really, but you know what I mean!) contains a given value.
--
-- @param inArray The array (Table) to check.
-- @param inValue The value to check for.
--
function utils:doesArrayContainValue(inArray, inValue)

  for idx, val in ipairs(inArray) do
    if val == inValue then
      return true;
    end
  end

  return false;

end -- End doesArrayContainValue().



-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- REWRITE RESOURCEMANAGER GENERICALLY USING THIS: _G[inFunctionName](unpack(arg));
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
---
-- Constructs a ResourceManager, which is a factory for creating resources that need to be cleaned up, things like
-- DisplayGroups, audio files, etc.
--
-- @return A new ResourceManager instance.
--
function utils:newResourceManager()

--  utils:log("ResourceManager", "Creating a new ResourceManager");

  -- Construct the basic ResourceManager instance.
  local rm = {
    displayGroup = { }, sprite = { }, imageSheet = { }, textCandy = { }, tableView = { }, roundedRect = { },
    textField = { }, circle = { }, line = { }, sound = { }, rect = { }, text = { }, image = { }
  };

  -- Internal utility function, this should NOT be called from external code!
  function rm:genericGetter(inID, inCollection)
    local o = self[inCollection][inID];
    if o == nil then
      local msg = inCollection .. " " .. inID .. " does not exist";
--      utils:log("ResourceManager", msg);
    end
    return o;
  end

  -- Internal utility function, this should NOT be called from external code!
  function rm:genericDoesExist(inID, inCollection)
    if self[inCollection][inID] == nil then
      return false;
    else
      local msg = inCollection .. " " .. inID .. " already exists";
--      utils:log("ResourceManager", msg);
      return true;
    end
  end

  -- Creates a new DisplayGroup identified by the provided ID and returns a reference to it.
  -- @param  inID The ID to identify the DisplayGroup by.
  -- @return      A reference to the DisplayGroup, or nil if it already exists.
  function rm:newDisplayGroup(inID)
--    utils:log("ResourceManager", "ResourceManager.newDisplayGroup(" .. inID .. ")");
    if self:genericDoesExist(inID, "displayGroup") == true then
      return nil;
    else
      local dg = display.newGroup();
      self.displayGroup[inID] = dg;
      return dg;
    end
  end
  -- Returns a reference to a previously created DisplayGroup by ID.
  -- @param inID The ID of the DisplayGroup to retrieve.
  -- @return     A reference to the DisplayGroup, or nil if not found.
  function rm:getDisplayGroup(inID)
--    utils:log("ResourceManager", "ResourceManager.getDisplayGroup(" .. inID .. ")");
    return self:genericGetter(inID, "displayGroup");
  end

  -- Creates a new ImageSheet identified by the provided ID and returns a reference to it.
  -- @param inID             The ID to identify the ImageSheet by.
  -- @param inSheetInfoPath  Path to the ImageSheet info file (the value you'd pass to require()).
  -- @param inSheetImagePath Path to the ImageSheet image file (the value you'd pass to newImageSheet()).
  -- @return                 A reference to the ImageSheet and a reference to the ImageSheet info object, in that order,
  --                         or nil if it already exists.
  function rm:newImageSheet(inID, inSheetInfoPath, inSheetImagePath)
--    utils:log(
--      "ResourceManager",
--      "ResourceManager.newImageSheet(" .. inID .. ", " .. inSheetInfoPath .. ", " .. inSheetImagePath .. ")"
--    );
    if self:genericDoesExist(inID, "imageSheet") == true then
      return nil;
    else
      local is = { };
      is.imageSheetInfo = require(inSheetInfoPath);
      is.imageSheet = graphics.newImageSheet(inSheetImagePath, is.imageSheetInfo:getSheet());
      self.imageSheet[inID] = is;
      return is.imageSheet, is.imageSheetInfo;
    end
  end
  -- Returns a reference to a previously created ImageSheet by ID.
  -- @param inID The ID of the ImageSheet to retrieve.
  -- @return     A reference to the ImageSheet, or nil if not found.
  function rm:getImageSheet(inID)
--    utils:log("ResourceManager", "ResourceManager.getImageSheet(" .. inID .. ")");
    local o = self:genericGetter(inID, "imageSheet");
    local retVal;
    if o ~= nil then
      retVal = o.imageSheet;
    end
    return retVal;
  end
  -- Returns a reference to a previously created ImageSheet info object by ID.
  -- @param inID The ID of the ImageSheet info object to retrieve.
  -- @return     A reference to the ImageSheet info object, or nil if not found.
  function rm:getImageSheetInfo(inID)
--    utils:log("ResourceManager", "ResourceManager.getImageSheetInfo(" .. inID .. ")");
    local o = self:genericGetter(inID, "imageSheet");
    local retVal;
    if o ~= nil then
      retVal = o.imageSheetInfo;
    end
    return retVal;
  end

  -- Creates a new Sprite identified by the provided ID and returns a reference to it.
  -- @param inID           The ID to identify the Sprite by.
  -- @param inParentGroup  The parent DisplayGroup of the Sprite.
  -- @param inImageSheet   A reference to a previously-created ImageSheet to build the Sprite from.
  -- @param inSequenceData Sprite sequence data object.
  -- @return               A reference to the Sprite, or nil if it already exists.
  function rm:newSprite(inID, inParentGroup, inImageSheet, inSequenceData)
--    utils:log(
--      "ResourceManager", "ResourceManager.newSprite(" .. inID .. ", inParentGroup, inImageSheet, inSequenceData)"
--    );
    if self:genericDoesExist(inID, "sprite") == true then
      return nil;
    else
      local s = display.newSprite(inParentGroup, inImageSheet, inSequenceData);
      self.sprite[inID] = s;
      return s;
    end
  end
  -- Returns a reference to a previously created Sprite by ID.
  -- @param inID The ID of the Sprite to retrieve.
  -- @return     A reference to the Sprite, or nil if not found.
  function rm:getSprite(inID)
--    utils:log("ResourceManager", "ResourceManager.getSprite(" .. inID .. ")");
    return self:genericGetter(inID, "sprite");
  end
  -- Remove a single specific Sprite by ID.  This should be used VERY sparringly!
  -- @param inID The ID of the Sprite to remove.
  function rm:removeSprite(inID)
--    utils:log("ResourceManager", "ResourceManager.removeSprite(" .. inID .. ")");
    if self.sprite[inID] ~= nil then
      self.sprite[inID]:removeSelf();
      self.sprite[inID] = nil;
    end
  end

  -- Creates a new TextCandy object identified by the provided ID and returns a reference to it.
  -- @param inID         The ID to identify the TextCandy object by.
  -- @param inConfigData TextCandy object configuration.
  -- @return             A reference to the TextCandy object, or nil if it already exists.
  function rm:newTextCandy(inID, inConfigData)
--    utils:log("ResourceManager", "ResourceManager.newTextCandy(" .. inID .. ", inConfigData)");
    if self:genericDoesExist(inID, "textCandy") == true then
      return nil;
    else
      local tco = textCandy.CreateText(inConfigData);
      self.textCandy[inID] = tco;
      return tco;
    end
  end
  -- Returns a reference to a previously created TextCandy object by ID.
  -- @param inID The ID of the TextCandy object to retrieve.
  -- @return     A reference to the TextCandy object, or nil if not found.
  function rm:getTextCandy(inID)
--    utils:log("ResourceManager", "ResourceManager.getTextCandy(" .. inID .. ")");
    return self:genericGetter(inID, "textCandy");
  end

  -- Creates a new TableView identified by the provided ID and returns a reference to it.
  -- @param inID         The ID to identify the TableView by.
  -- @param inConfigData TableView configuration.
  -- @return             A reference to the TableView, or nil if it already exists.
  function rm:newTableView(inID, inConfigData)
--    utils:log("ResourceManager", "ResourceManager.newTableView(" .. inID .. ", inConfigData)");
    if self:genericDoesExist(inID, "tableView") == true then
      return nil;
    else
      local tv = widget.newTableView(inConfigData);
      self.tableView[inID] = tv;
      return tv;
    end
  end
  -- Returns a reference to a previously created TableView by ID.
  -- @param inID The ID of the TableView to retrieve.
  -- @return     A reference to the TableView, or nil if not found.
  function rm:getTableView(inID)
--    utils:log("ResourceManager", "ResourceManager.getTableView(" .. inID .. ")");
    return self:genericGetter(inID, "tableView");
  end

  -- Creates a new RoundedRect identified by the provided ID and returns a reference to it.
  -- @param inID           The ID to identify the RoundedRect by.
  -- @param inGroup        Parent DisplayGroup.
  -- @param inX            X center coordinate.
  -- @param inY            Y center coordinate.
  -- @param inWidth        Width.
  -- @param inHeight       Height.
  -- @param inCornerRadius Corner radius.
  -- @return               A reference to the RoundedRect, or nil if it already exists.
  function rm:newRoundedRect(inID, inGroup, inX, inY, inWidth, inHeight, inCornerRadius)
--    utils:log("ResourceManager",
--      "ResourceManager.newRoundedRect(" .. inID .. ", inGroup, " .. inX .. ", " .. inY .. ", " ..
--      inWidth .. ", " .. inHeight .. ", " .. inCornerRadius .. ")"
--    );
    if self:genericDoesExist(inID, "roundedRect") == true then
      return nil;
    else
      local rr = display.newRoundedRect(inGroup, inX, inY, inWidth, inHeight, inCornerRadius);
      self.roundedRect[inID] = rr;
      return rr;
    end
  end
  -- Returns a reference to a previously created RoundedRect by ID.
  -- @param inID The ID of the RoundedRect to retrieve.
  -- @return     A reference to the RoundedRect, or nil if not found.
  function rm:getRoundedRect(inID)
--    utils:log("ResourceManager", "ResourceManager.getRoundedRect(" .. inID .. ")");
    return self:genericGetter(inID, "roundedRect");
  end

  -- Creates a new TextField identified by the provided ID and returns a reference to it.
  -- @param inID           The ID to identify the TextField by.
  -- @param inCenterX      X center coordinate.
  -- @param inCenterY      Y center coordinate.
  -- @param inWidth        Width.
  -- @param inHeight       Height.
  -- @return               A reference to the TextField, or nil if it already exists.
  function rm:newTextField(inID, inCenterX, inCenterY, inWidth, inHeight)
--    utils:log("ResourceManager",
--      "ResourceManager.newTextField(" .. inID .. ", " .. inCenterX .. ", " .. inCenterY .. ", " ..
--      inWidth .. ", " .. inHeight .. ")"
--    );
    if self:genericDoesExist(inID, "textField") == true then
      return nil;
    else
      local tf = native.newTextField(inCenterX, inCenterY, inWidth, inHeight);
      self.textField[inID] = tf;
      return tf;
    end
  end
  -- Returns a reference to a previously created TextField by ID.
  -- @param inID The ID of the TextField to retrieve.
  -- @return     A reference to the TextField, or nil if not found.
  function rm:getTextField(inID)
--    utils:log("ResourceManager", "ResourceManager.getTextField(" .. inID .. ")");
    return self:genericGetter(inID, "textField");
  end

  -- Creates a new Circle identified by the provided ID and returns a reference to it.
  -- @param inID      The ID to identify the Circle by.
  -- @param inGroup   Parent DisplayGroup.
  -- @param inCenterX X center coordinate.
  -- @param inCenterY Y center coordinate.
  -- @param inRadius  Radius.
  -- @return          A reference to the Circle, or nil if it already exists.
  function rm:newCircle(inID, inGroup, inCenterX, inCenterY, inRadius)
--    utils:log("ResourceManager",
--      "ResourceManager.newCircle(" .. inID .. ", inGroup, " .. inCenterX .. ", " .. inCenterY .. ", " .. inRadius .. ")"
--    );
    if self:genericDoesExist(inID, "circle") == true then
      return nil;
    else
      local c = display.newCircle(inGroup, inCenterX, inCenterY, inRadius);
      self.circle[inID] = c;
      return c;
    end
  end
  -- Returns a reference to a previously created Circle by ID.
  -- @param inID The ID of the Circle to retrieve.
  -- @return     A reference to the Circle, or nil if not found.
  function rm:getCircle(inID)
--    utils:log("ResourceManager", "ResourceManager.getCircle(" .. inID .. ")");
    return self:genericGetter(inID, "circle");
  end

  -- Creates a new Line identified by the provided ID and returns a reference to it.
  -- @param inID    The ID to identify the Line by.
  -- @param inGroup Parent DisplayGroup.
  -- @param inX1    Starting X.
  -- @param inY1    Starting Y.
  -- @param inX2    Ending X.
  -- @param inY2    Ending Y.
  -- @return        A reference to the Line, or nil if it already exists.
  function rm:newLine(inID, inGroup, inX1, inY1, inX2, inY2)
--    utils:log("ResourceManager",
--      "ResourceManager.newLine(" .. inID .. ", inGroup, " .. inX1 .. ", " .. inY1 .. ", " .. inX2 .. ", " .. inY2 .. ")"
--    );
    if self:genericDoesExist(inID, "line") == true then
      return nil;
    else
      local c = display.newLine(inGroup, inX1, inY1, inX2, inY2);
      self.line[inID] = c;
      return c;
    end
  end
  -- Returns a reference to a previously created Line by ID.
  -- @param inID The ID of the Line to retrieve.
  -- @return     A reference to the Line, or nil if not found.
  function rm:getLine(inID)
--    utils:log("ResourceManager", "ResourceManager.getLine(" .. inID .. ")");
    return self:genericGetter(inID, "line");
  end

  -- Creates a new Sound identified by the provided ID and returns a reference to it.
  -- @param inID   The ID to identify the Sound by.
  -- @param inPath The full path to the Sound file to load.
  -- @return       A reference to the Sound, or nil if it already exists.
  function rm:loadSound(inID, inPath)
--    utils:log("ResourceManager", "ResourceManager.loadSound(" .. inID .. ", " .. inPath .. ")");
    if self:genericDoesExist(inID, "sound") == true then
      return nil;
    else
      local s = audio.loadSound(inPath);
      self.sound[inID] = s;
      return s;
    end
  end
  -- Returns a reference to a previously created Sound by ID.
  -- @param inID The ID of the Sound to retrieve.
  -- @return     A reference to the Sound, or nil if not found.
  function rm:getSound(inID)
--    utils:log("ResourceManager", "ResourceManager.getSound(" .. inID .. ")");
    return self:genericGetter(inID, "sound");
  end

  -- Creates a new Rect identified by the provided ID and returns a reference to it.
  -- @param inID     The ID to identify the Rect by.
  -- @param inGroup  Parent DisplayGroup.
  -- @param inX      X center coordinate.
  -- @param inY      Y center coordinate.
  -- @param inWidth  Width.
  -- @param inHeight Height.
  -- @return         A reference to the Rect, or nil if it already exists.
  function rm:newRect(inID, inGroup, inX, inY, inWidth, inHeight)
--    utils:log("ResourceManager",
--      "ResourceManager.newRect(" .. inID .. ", inGroup, " .. inX .. ", " .. inY .. ", " ..
--      inWidth .. ", " .. inHeight .. ")"
--    );
    if self:genericDoesExist(inID, "rect") == true then
      return nil;
    else
      local rr = display.newRect(inGroup, inX, inY, inWidth, inHeight);
      self.rect[inID] = rr;
      return rr;
    end
  end
  -- Returns a reference to a previously created Rect by ID.
  -- @param inID The ID of the Rect to retrieve.
  -- @return     A reference to the Rect, or nil if not found.
  function rm:getRect(inID)
--    utils:log("ResourceManager", "ResourceManager.getRect(" .. inID .. ")");
    return self:genericGetter(inID, "rect");
  end

  -- Creates a new Text object identified by the provided ID and returns a reference to it.
  -- @param inID    The ID to identify the Text object by.
  -- @param inGroup Parent DisplayGroup.
  -- @param inText  Initial text to set.
  -- @param inX     X center coordinate.
  -- @param inY     Y center coordinate.
  -- @param inFont  Font to use.
  -- @param inSize  Font size.
  -- @return        A reference to the Text object, or nil if it already exists.
  function rm:newText(inID, inGroup, inText, inX, inY, inFont, inSize)
--    utils:log("ResourceManager",
--      "ResourceManager.newText(" .. inID .. ", inGroup, '" .. inText .. "', " .. inX .. ", " .. inY .. ", " ..
--      inFont .. ", " .. inSize .. ")"
--    );
    if self:genericDoesExist(inID, "text") == true then
      return nil;
    else
      local t = display.newText(inGroup, inText, inX, inY, inFont, inSize);
      self.text[inID] = t;
      return t;
    end
  end
  -- Returns a reference to a previously created Text object by ID.
  -- @param inID The ID of the Text object to retrieve.
  -- @return     A reference to the Text object, or nil if not found.
  function rm:getText(inID)
--    utils:log("ResourceManager", "ResourceManager.getText(" .. inID .. ")");
    return self:genericGetter(inID, "text");
  end

  -- Creates a new Image identified by the provided ID and returns a reference to it.
  -- @param inID      The ID to identify the Image by.
  -- @param inGroup   Parent DisplayGroup.
  -- @param inPath    The path to the image file.
  -- @param inX       X location of the Image.
  -- @param inY       Y location of the Image.
  -- @return          A reference to the Image, or nil if it already exists.
  function rm:newImage(inID, inGroup, inPath, inX, inY)
    --    utils:log("ResourceManager",
    --      "ResourceManager.newImage(" .. inID .. ", inGroup, " .. inPath .. ")"
    --    );
    if self:genericDoesExist(inID, "image") == true then
      return nil;
    else
      local i = display.newImage(inGroup, inPath, inX, inY);
      self.image[inID] = i;
      return i;
    end
  end
  -- Returns a reference to a previously created Image by ID.
  -- @param inID The ID of the Image to retrieve.
  -- @return     A reference to the Image, or nil if not found.
  function rm:getImage(inID)
    --    utils:log("ResourceManager", "ResourceManager.getImage(" .. inID .. ")");
    return self:genericGetter(inID, "image");
  end

  -- Destroy all registered elements.
  function rm:destroyAll()
--    utils:log("ResourceManager", "ResourceManager.destroyAll()");
    audio.stop();
    -- Function that can generically destroy many types of resources.
    local genericDestroyer = function(inCollection)
      local genericNumDestroyed = 0;
      for idx, val in pairs(self[inCollection]) do
        self[inCollection][idx]:removeSelf();
        self[inCollection][idx] = nil;
        genericNumDestroyed = genericNumDestroyed + 1;
      end
      self[inCollection] = nil;
--      utils:log("ResourceManager", "Destroyed " .. genericNumDestroyed .. " " .. inCollection);
    end
    -- Destroy "generic" resources".
    genericDestroyer("sprite");
    genericDestroyer("tableView");
    genericDestroyer("roundedRect");
    genericDestroyer("textField");
    genericDestroyer("circle");
    genericDestroyer("line");
    genericDestroyer("displayGroup");
    genericDestroyer("rect");
    genericDestroyer("text");
    genericDestroyer("image");
    -- Now destroy anything that the generic destroyer can't handle, beginning with ImageSheets.
    local numDestroyed = 0;
    for idx, val in pairs(self.imageSheet) do
      self.imageSheet[idx].imageSheet = nil;
      self.imageSheet[idx].imageSheetInfo = nil;
      self.imageSheet[idx] = nil;
      numDestroyed = numDestroyed + 1;
    end
    self.imageSheet = nil;
--    utils:log("ResourceManager", "Destroyed " .. numDestroyed .. " imageSheet");
    -- TextCandy.
    numDestroyed = 0;
    for idx, val in pairs(self.textCandy) do
      textCandy.DeleteText(self.textCandy[idx]);
      self.textCandy[idx] = nil;
      numDestroyed = numDestroyed + 1;
    end
    self.textCandy = nil;
--    utils:log("ResourceManager", "Destroyed " .. numDestroyed .. " textCandy");
    -- Sound.
    numDestroyed = 0;
    for idx, val in pairs(self.sound) do
      audio.dispose(self.sound[idx]);
      self.sound[idx] = nil;
      numDestroyed = numDestroyed + 1;
    end
    self.sound = nil;
--    utils:log("ResourceManager", "Destroyed " .. numDestroyed .. " sound");
  end

  -- ResourceManager instance constructed, return it.
  return rm;

end -- End getResourceManager().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


return utils;
