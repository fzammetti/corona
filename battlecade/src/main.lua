-- *********************************************************************************************************************
-- *********************************************************************************************************************
-- ********** GLOBAL VARIABLES.                                                                               **********
-- *********************************************************************************************************************
-- *********************************************************************************************************************


-- Turn on debugging mode. Enables some extra logging (to file) and features.  SHOULD BE FALSE FOR FINAL BUILD!!
debugMode = false;

-- Transition effect and time used for all scene transitions.
SCENE_TRANSITION_EFFECT = "zoomOutInFade";
SCENE_TRANSITION_TIME = 250;

-- Game state.  This is stored to a file.
gameState = { username = nil, password = nil };

-- The current match the player is involved in, if any.
currentMatch = nil;

-- Flag: Is the player currently playing through a round of match games?
isPlayingMatchRound = false;

-- The list of games the player is currently playing through if isPlayingMatchRound is true.
matchRoundGames = { };

-- Index into matchRoundGames as the player plays through a round.
matchRoundGameIndex = 1;

-- The total score for the current match round being played.  The final scor for each mini-game gets added to this
-- after each game is complete.
matchRoundScore = nil;

-- Native font to use for newText() calls.
globalNativeFont = "nativeFont.ttf";

-- List of mini-games and necessary data that describes each.
gameList = {
  { caption = "Antigravitator", internalName = "antigravitator", matchID = "an" },
  { caption = "Bubble Trouble", internalName = "bubbleTrouble", matchID = "bb" },
  { caption = "Cavern Crasher", internalName = "cavernCrasher", matchID = "cv" },
  { caption = "Colorblinded", internalName = "colorblinded", matchID = "co" },
  { caption = "Copycat", internalName = "copycat", matchID = "cc" },
  { caption = "Cosmic Squirrel", internalName = "cosmicSquirrel", matchID = "cs" },
  { caption = "Deathtrap", internalName = "deathtrap", matchID = "dt" },
  { caption = "Defender", internalName = "defender", matchID = "de" },
  { caption = "Eliminator", internalName = "eliminator", matchID = "el" },
  { caption = "Far Out Fowl", internalName = "farOutFowl", matchID = "fo" },
  { caption = "Glutton", internalName = "glutton", matchID = "gl" },
  { caption = "Hustler", internalName = "hustler", matchID = "hu" },
  { caption = "In Memoria", internalName = "inMemoria", matchID = "in" },
  { caption = "Mathematica", internalName = "mathematica", matchID = "ma" },
  { caption = "Pokeher", internalName = "pokeher", matchID = "po" },
  { caption = "Refluxive", internalName = "refluxive", matchID = "re" },
  { caption = "The Bogaz Derby", internalName = "theBogazDerby", matchID = "tb" },
  { caption = "The Escape", internalName = "theEscape", matchID = "te" },
  { caption = "The Redeye Order", internalName = "theRedeyeOrder", matchID = "tr" },
  { caption = "Virus", internalName = "virus", matchID = "vi" }
};


-- *********************************************************************************************************************
-- *********************************************************************************************************************
-- ********** GLOBAL REQUIRES.                                                                                **********
-- *********************************************************************************************************************
-- *********************************************************************************************************************


composer = require("composer");
json = require("json");
widget = require("widget");
textCandy = require("text_candy");
utils = require("utils");
globalFunctions = require("globalFunctions");
serverDelegate = require("serverDelegate");
dialog = require("dialog");


-- *********************************************************************************************************************
-- *********************************************************************************************************************
-- ********** INITIAL LOGGING.                                                                                **********
-- *********************************************************************************************************************
-- *********************************************************************************************************************


os.execute("cls");
utils:log("main", "******************** Battlecade ********************");
utils:log("main", "> SYSTEM PROPERTIES:");
utils:log("main", "   androidAppPackageName: " .. (system.getInfo("androidAppPackageName") or "N/A"));
utils:log("main", "   androidAppVersionCode: " .. (system.getInfo("androidAppVersionCode") or "N/A"));
utils:log("main", "   androidDisplayApproximateDpi: " .. (system.getInfo("androidDisplayApproximateDpi") or "N/A"));
utils:log("main", "   androidDisplayDensityName: " .. (system.getInfo("androidDisplayDensityName") or "N/A"));
utils:log("main", "   androidDisplayWidthInInches: " .. (system.getInfo("androidDisplayWidthInInches") or "N/A"));
utils:log("main", "   androidDisplayHeightInInches: " .. (system.getInfo("androidDisplayHeightInInches") or "N/A"));
utils:log("main", "   androidDisplayXDpi: " .. (system.getInfo("androidDisplayXDpi") or "N/A"));
utils:log("main", "   androidDisplayYDpi: " .. (system.getInfo("androidDisplayYDpi") or "N/A"));
utils:log("main", "   appName: " .. (system.getInfo("appName") or "N/A"));
utils:log("main", "   appVersionString: " .. (system.getInfo("appVersionString") or "N/A"));
utils:log("main", "   architectureInfo: " .. (system.getInfo("architectureInfo") or "N/A"));
utils:log("main", "   Corona Build: " .. (system.getInfo("build") or "N/A"));
utils:log("main", "   Device ID: " .. (system.getInfo("deviceID") or "N/A"));
utils:log("main", "   Environment: " .. (system.getInfo("environment") or "N/A"));
utils:log("main", "   GL_RENDERER: " .. (system.getInfo("GL_RENDERER") or "N/A"));
utils:log("main", "   GL_SHADING_LANGUAGE_VERSION: " .. (system.getInfo("GL_SHADING_LANGUAGE_VERSION") or "N/A"));
utils:log("main", "   GL_VENDOR: " .. (system.getInfo("GL_VENDOR") or "N/A"));
utils:log("main", "   GL_VERSION: " .. (system.getInfo("GL_VERSION") or "N/A"));
utils:log("main", "   gpuSupportsHighPrecisionFragmentShaders: " ..
  ((system.getInfo("gpuSupportsHighPrecisionFragmentShaders") and "Yes" or "No") or "N/A")
);
utils:log("main", "   iosIdentifierForVendor: " .. (system.getInfo("iosIdentifierForVendor") or "N/A"));
--utils:log("main", "   GL_EXTENSIONS: " .. (system.getInfo("GL_EXTENSIONS") or "N/A"));
utils:log("main", "   maxTextureSize: " .. (system.getInfo("maxTextureSize") or "N/A"));
utils:log("main", "   Model: " .. (system.getInfo("model") or "N/A"));
utils:log("main", "   name: " .. (system.getInfo("name") or "N/A"));
utils:log("main", "   Platform Name: " .. (system.getInfo("platformName") or "N/A"));
utils:log("main", "   Platform Version: " .. (system.getInfo("platformVersion") or "N/A"));
utils:log("main", "   targetAppStore: " .. (system.getInfo("targetAppStore") or "N/A"));
utils:log("main", "   textureMemoryUsed: " .. (system.getInfo("textureMemoryUsed") or "N/A"));
utils:log("main", "> DISPLAY PROPERTIES:");
utils:log("main", "   actualContentWidth/Height: " ..
  (display.actualContentWidth or "") .. "/" .. (display.actualContentHeight or "N/A")
);
utils:log("main", "   contentCenterX/Y: " ..
  (display.contentCenterX or "") .. "/" .. (display.contentCenterY or "N/A")
);
utils:log("main", "   contentWidth/Height: " .. (display.contentWidth .. "/" .. display.contentHeight or "N/A"));
utils:log("main", "   contentScaleX/Y: " .. (display.contentScaleX or "") .. "/" .. (display.contentScaleY or "N/A"));
utils:log("main", "   fps: " .. (display.fps or "N/A"));
utils:log("main", "   imageSuffix: " .. (display.imageSuffix or "N/A"));
utils:log("main", "   pixelWidth/Height: " .. (display.pixelWidth or "") .. "/" .. (display.pixelHeight or "N/A"));
utils:log("main", "   screenOriginX/Y: " .. (display.screenOriginX or "") .. "/" .. (display.screenOriginY or "N/A"));
utils:log("main", "   statusBarHeight: " .. (display.statusBarHeight or "N/A"));
utils:log("main", "   topStatusBarContentHeight: " .. (display.topStatusBarContentHeight or "N/A"));
utils:log("main", "   viewableContentWidth/Height: " ..
  (display.viewableContentWidth or "") .. "/" .. (display.viewableContentHeight or "N/A")
);
--utils:log("main", "Available system fonts", native.getFontNames());
utils:log("main", "**********************************************************************");


-- *********************************************************************************************************************
-- *********************************************************************************************************************
-- ********** EXTERNAL LIBRARY CONFIGURATION.                                                                 **********
-- *********************************************************************************************************************
-- *********************************************************************************************************************


utils:log("main", "Initializing TextCandy...");
textCandy.EnableDebug(false);
textCandy.AddCharsetFromGlyphDesigner("fontTitle", "fontTitle");
textCandy.AddCharsetFromGlyphDesigner("fontCredits", "fontCredits");
textCandy.AddCharsetFromGlyphDesigner("fontInstructions", "fontInstructions");
textCandy.AddCharsetFromGlyphDesigner("fontInstructionsSmaller", "fontInstructions");
textCandy.AddCharsetFromGlyphDesigner("fontPlain", "fontPlain");
textCandy.AddCharsetFromGlyphDesigner("fontTransientMsg", "fontTransientMsg");
textCandy.ScaleCharset("fontTitle", 2.3);
textCandy.ScaleCharset("fontCredits", 1.4);
textCandy.ScaleCharset("fontInstructions", .8);
textCandy.ScaleCharset("fontInstructionsSmaller", .7);
textCandy.ScaleCharset("fontPlain", 1);
textCandy.ScaleCharset("fontTransientMsg", 2);
utils:log("main", "...TextCandy initialization done");


-- *********************************************************************************************************************
-- *********************************************************************************************************************
-- ********** EXECUTION BEGINS HERE.                                                                          **********
-- *********************************************************************************************************************
-- *********************************************************************************************************************


-- Handle unhandled errors.
Runtime:addEventListener("unhandledError",
  function(inEvent)
    utils:log("GLOBAL", "Unhandled Runtime Error: " .. inEvent.errorMessage);
    utils:log("GLOBAL", "Unhandled Runtime Error Stack Trace: " .. inEvent.stackTrace);
    if debugMode == true then
      utils:alert("An unrecoverable error has occurred.  For details, see the log file from the developer menu.");
      return true;
    end
    -- Return true to handle the exception and continue execution, false to shut down the app.
    return false;
  end
);

-- Hook handling of back button on devices that have one.
Runtime:addEventListener("key",
  function (inEvent)
    local platformName = system.getInfo("platformName");
    if inEvent.phase == "up" and inEvent.keyName == "back" then
      -- Only allow back button to do something on the menu scene (returning true indicates the app is handling
      -- the back button, so we'll do nothing, false lets it do what it normally does).
      if composer.getSceneName("current") == "menu.main" then
        return false;
      else
        return true;
      end
    end
  end
);

-- Initialize random number generator.
math.randomseed(os.time());

-- Hide status bar.
if system.getInfo("environment") ~= "simulator" then
  display.setStatusBar(display.HiddenStatusBar);
end

-- Flip componser into debug mode (make sure to set this to false for real build!) and set to destroy scenes when
-- transitioning to a new one.
composer.isDebug = false;
composer.recycleOnSceneChange = true;

-- Reserve audio channel 1 for ambient sounds.  This is done so that when we adjust the volume of ambients in some
-- games, it doesn't effect the volume of other sounds.
audio.reserveChannels(1);

-- Load global graphic assets.  These are never deleted.
uiSheetInfo = require("ui_imageSheet");
uiImageSheet = graphics.newImageSheet("ui_imageSheet.png", uiSheetInfo:getSheet());
ui2SheetInfo = require("ui2_imageSheet");
ui2ImageSheet = graphics.newImageSheet("ui2_imageSheet.png", ui2SheetInfo:getSheet());
screenshotsSheetInfo = require("miniGames.screenshotsImageSheet");
screenshotsImageSheet = graphics.newImageSheet("miniGames/screenshotsImageSheet.png", screenshotsSheetInfo:getSheet());

-- Load global audio assets.  These are never deleted.
uiTap = audio.loadSound("ui_tap.wav");
uiGameSelected = audio.loadSound("ui_gameSelected.wav");
uiScreenshotCycle = audio.loadSound("ui_screenshotCycle.wav");

-- Read in the background particle system data and decode it, then start the emitter.
local pfp = system.pathForFile("background_particles.json");
local pf = io.open(pfp, "r");
local pfd = pf:read("*a");
pf:close();
backgroundEmitterParams = json.decode(pfd);
backgroundParticleEmitter = display.newEmitter(backgroundEmitterParams);
backgroundParticleEmitter.x = display.contentCenterX;
backgroundParticleEmitter.y = display.contentCenterY;
backgroundParticleEmitter:toBack();

-- Bouncing title text on all non-mini-game screens.
textTitle = textCandy.CreateText({
  fontName = "fontTitle", x = display.contentCenterX - 10, y = 150, text = "BATTLECADE"
});
textTitle:applyAnimation({
  startNow = true, restartOnChange = true, charWise = true, frequency = 250, delay = 0,
  rotationRange = 25, xRange = 20, yRange = 30
});
--textTitle.numTaps = 0;
--textTitle:addEventListener("touch",
--  function(inEvent)
--    if inEvent.phase == "ended" then
--      textTitle.numTaps = textTitle.numTaps + 1;
--      if textTitle.numTaps == 10 then
--        utils:showFPSAndMem();
--      end
--    end
--    return true;
--  end
--);

-- Load the game state, if any.
globalFunctions.loadGameState();

-- Fire off a ping request to the server.
--serverDelegate:ping(
--  function(inData)
--    if inData.msg ~= nil then
--      dialog:show({ text = inData.msg, callback = function(inButtonType) end });
--    end
--  end
--);

-- All set, start the first scene.
utils:log("main", "Initialization complete, launching first scene");
utils:log("main", "**********************************************************************");
if debugMode == false then
  print = function() end
end
--composer.gotoScene("menu.main", { effect = SCENE_TRANSITION_EFFECT, time = SCENE_TRANSITION_TIME });
composer.gotoScene("practiceSelection.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
