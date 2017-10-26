utils = require("utils");


-- Flags for development purposes.
allLevelsUnlocked = false; -- True to unlock all levels always.
logToFile = false; -- Should log messages go to a file as well as console?

-- XYYZ: X = month (Jan-Dec = A-L), YY=day, Z=build # for that day
buildVersion = "G251";


-- Fix for Kindle Fire menu bar.  Basically it scales the stage to 20 pixels
-- smaller than the screen size, which accounts for the 20-pixel tall
-- menu bar on the Kindle, then shifts the stage up those 20 pixels (and
-- also left/right accordingly since in letterbox mode it'll be stretched
-- equally in all directions).  This only happens for Kindle Fire, but it
-- should fix the cutting off at the bottom at the cost of a little bit of
-- extra black space on the sides.
if (system.getInfo("model") == "Kindle Fire") then
  local deviceScreen = {
    left = display.screenOriginX, top = display.screenOriginY,
    right = display.contentWidth - display.screenOriginX,
    bottom = display.contentHeight - display.screenOriginY
  }
  local kFireScale = 580 / 600;
  local stage = display.getCurrentStage();
  local stageShift = 10 * display.contentScaleY;
  local screenWidth = deviceScreen.right - deviceScreen.left;
  local xShift = ((screenWidth / kFireScale) - screenWidth) / 2;
  stage:setReferencePoint(display.CenterReferencePoint);
  stage:scale(kFireScale, kFireScale);
  stage.yOrigin = stage.yOrigin - stageShift;
  stage.yReference = stage.yReference + stageShift;
  deviceScreen.left = deviceScreen.left - xShift;
  deviceScreen.right = deviceScreen.right + xShift;
end


-- Turn off status bar.
display.setStatusBar(display.HiddenStatusBar);


-- Initial startup info.
os.execute("cls");
utils:log("main", "ENGINEER STARTING...");
utils:log("main", "Environment: " .. system.getInfo("environment"));
utils:log("main", "Model: " .. system.getInfo("model"));
utils:log("main", "Device ID: " .. system.getInfo("deviceID"));
utils:log("main", "Platform Name: " .. system.getInfo("platformName"));
utils:log("main", "Platform Version: " .. system.getInfo("version"));
utils:log("main", "Corona Version: " .. system.getInfo("version"));
utils:log("main", "Corona Build: " .. system.getInfo("build"));
utils:log("main", "contentWidth: " .. display.contentWidth);
utils:log("main", "contentHeight: " .. display.contentHeight);


-- Seed random number generator.
math.randomseed(os.time());


-- Show a loading message.
local pleaseWaitMessages = {
  "Cool your jets, gettin' ready to rock",
  "Be patient, magic is happening here",
  "Have a Coke and a smile and wait a sec",
  "Chill out, code pixies are working hard",
  "Give it a bit, setting up is hard work",
  "Fun is being prepped, chill for a few",
  "Relax, grab a snack, this won't take long",
  "Things will be ready for you shortly",
  "Be at peace while we ready game-foo",
  "All your fun are belong to us, very soon",
  "Transcoding parametric data, or something",
  "Hold on, cogitating relativistic patterns",
  "If this was an XBox you'd be playing now",
  "Retrieving code from alternate dimension",
  "Whipping bits and bytes into shape for you",
  "Please, I beg of you good human, wait",
  "No LOLCats were harmed making this game",
  "Darth Vader is Luke's dad (SPOILER ALERT!)",
  "My kingdom for a game that loads faster!",
  "Is congress the opposite of progress?",
  "Chill, relax, wait a minute, almost there",
  "Game loading in progress for sure now",
  "Wait a sec, SOMETHING is happening here",
  "Just once I'd like a game that loads fast",
  "Time is a predator, it's stalking you",
  "Count down from 10 to 1 if you would",
  "Gettin' ready to launch ya'll",
  "My god, it's full of stars!",
  "I'm Batman! No, sorry, just a load screen",
  "What's that in the distance? It's a game!",
  "Ponder this: 42. That is all.",
  "I promise, we're almost ready for you",
  "Gameworld being built, it takes time",
  "A new program is arriving on the grid",
  "Humor makes up for loading speed, right?!",
  "Please wait. Umm, so, how have you been?",
  "Please wait, fighting Gollum for the ring",
  "Your device is working hard, wait for it"
};
local pwNumber = math.random(1, #pleaseWaitMessages);
--utils:log("main", "pwNumber = " .. pwNumber);
loadingText = display.newText(
  "..." .. pleaseWaitMessages[pwNumber] .. "...",
  0, 0, native.systemFont, 36);
loadingText.x = display.contentWidth / 2;
loadingText.y = display.contentHeight / 2;


-- After a short delay (to ensure the text makes it to the screen) we start
-- initializing the application.  Including appInit is all it takes!
timer.performWithDelay(250,
  function()
    require("appInit");
  end
);
