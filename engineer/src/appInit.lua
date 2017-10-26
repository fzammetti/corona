utils:log("appInit", "Entry");

easingX = require("lib_easingX")
json = require("json");
particleCandy = require("lib_particle_candy");
sprite = require("sprite");
storyboard = require("storyboard");
textCandy = require("lib_text_candy");
widgetCandy = require("lib_widget_candy")

require("confirmPopup");
require("drawBoard");
require("gameCore");
require("levelConclusions");
require("particleEffects");
require("particleFunctions");
require("pauseMenu");
require("powerupsMenu");


-- Need to define this before any levels are imported.
levels = { };
require("level_1");
require("level_2");
require("level_3");
require("level_4");
require("level_5");
require("level_6");
require("level_7");
require("level_8");
require("level_9");
require("level_10");
require("level_11");
require("level_12");
require("level_13");
require("level_14");
require("level_15");
require("level_16");
require("level_17");
require("level_18");
require("level_19");
require("level_20");
require("level_21");
require("level_22");
require("level_23");
require("level_24");
require("level_25");
require("level_26");
require("level_27");
require("level_28");
require("level_29");
require("level_30");


-- Set up Text Candy fonts.
utils:log("appInit", "Initializing TextCandy");
textCandy.EnableDebug(false);
textCandy.AddCharset(
  "fontSpace", "textCandy_fontSpaceBigOrange",
  "textCandy_fontSpaceBigOrange.png",
  "0123456789A{BCDEFGHIJKLMNO{PQRSTU{VWXYZ'*@():,$.!-%+?;#/_", 25
);
textCandy.ScaleCharset("fontSpace", 2);
textCandy.AddCharset(
  "fontMediumSilver", "textCandy_fontSmall4Silver",
  "textCandy_fontSmall4Silver.png",
  "0123456789A{BCDEFGHIJKLMNO{PQRSTU{VWXYZ'*@():,$.!-%+?;#/_", 25
);
textCandy.ScaleCharset("fontMediumSilver", 1.5);
textCandy.AddCharset(
  "fontSmallSilver", "textCandy_fontSmall4Silver",
  "textCandy_fontSmall4Silver.png",
  "0123456789A{BCDEFGHIJKLMNO{PQRSTU{VWXYZ'*@():,$.!-%+?;#/_", 25
);
textCandy.ScaleCharset("fontSmallSilver", .8);
textCandy.AddCharset(
  "fontLED", "textCandy_fontLEDBigOrange", "textCandy_fontLEDBigOrange.png",
  "0123456789A{BCDEFGHIJKLMNO{PQRSTU{VWXYZ'*@():,$.!-%+?;#/_", 25
);
textCandy.ScaleCharset("fontLED", 1);
utils:log("appInit", "TextCandy set up");

-- Set up WidgetCandy theme.
widgetCandy.LoadTheme("widgetCandy_theme2", "themes/widgetCandy_theme2/")


-- Reference to DisplayGroup for developer menu.
devMenuDG = nil;

-- References for music.
titleMusic = nil;
titleMusicChannel = nil;
introMusic = nil;
introMusicChannel = nil;
conclusionMusic = nil;
conclusionMusicChannel = nil;

-- Flag: is a confirm popup currently showing?
confirmPopupShowing = false;

-- X and Y adjustment for drawing everything.
xAdj = 1;
yAdj = 44;

-- Scene transition effect used between storyboard scene changes.
sceneTransitionEffect = "zoomOutInFade";

-- Possible modes the game can be in during actual gameplay.
MODE_PLAYING = 1;
MODE_LEVEL_COMPLETE = 2;
MODE_LEVEL_FAILED = 3;
MODE_PAUSED = 4;
MODE_GAME_FINISHED = 5;
currentMode = nil;

-- Total number of levels.
numLevels = 30;

-- Powerup stuff.
POWERUP_FIXIT = 1;
POWERUP_DEGAUSS = 2;
POWERUP_OFFLINE = 3;
POWERUP_GRAVITY = 4;
powerupTexts = { "Fixit", "Degauss", "Offline", "Gravity" };
powerupsButton = nil;
powerupsMenuShowing = false;
powerupOfflineActive = false;
powerupGravityActive = false;
powerupGravityCounter = 0;

-- Object that describes the current level.
currentLevel = {
  dg = nil, -- DisplayGroup for all images deleted when a level starts
  sceneGroup = nil, -- DisplayGroup for the game scene
  emergeCount = nil, -- Counter: when to release a particle
  powerupFrequencyCount = nil, -- Counter: when to release a powerup
  levelDef = nil, -- Level definition structure
  levelData = nil, -- Level tile data (within the level definition structure)
  generators = nil, -- Indexed Collection of generators on current level
  particlePrisons = nil, -- Indexed collection of prisons on current level
  antimatterSinks = nil, -- Indexed collection of sinks on current level
  ports = nil, -- Keyed collection of ports on current level
  diverters = nil, -- Keyed collection of diverters on  current level
  particles = nil, -- Indexed collection of active particles on current level
  -- The following are used to determine how many stats the player earns
  numPortExplosions = 0, -- # of times a port gets damaged
  numDiverterExplosions = 0, -- # of times a particle explodes in a diverter
  numAntimatterExplosions = 0, -- # of times a particle & antiparticle collide
  numParticlesInSink = 0, -- # of times a regular particle goes into a sink
  numParticlesInPrison = 0 -- # of times a particle goes into a prison
};

-- The diverter sprite sheets and sets.
diverterResources = { sheets = nil, sets = nil };

-- The particle sprite sheets and sets (active particles reference these).
particleResources = {
  sheets = nil, sets = nil,
  MOVING_UP = 1, MOVING_DOWN = 2, MOVING_LEFT = 3, MOVING_RIGHT = 4,
  PHASE_FORMING = 1, PHASE_EMERGING = 2, PHASE_MOVING = 3,
  PHASE_DIVERTER = 4
};

-- The generator sprite sheet and set.
generatorResources = { sheet = nil, set = nil };

-- The antimatter sink sprite sheet and set.
antimatterSinkResources = { sheet = nil, set = nil };

-- The particle prison sprite sheet and set.
particlePrisonResources = { sheet = nil, set = nil };

-- The port sprite sheets and sets.
portResources = { sheets = nil, sets = nil };

-- The particle meter.
particleMeter = nil;

-- Resources for the pause menu.
pause = {
  group = nil,
  button = nil,
  fadeRect = nil
};

-- Reference to active powerup countdown text.
powerupsCountdownText = nil;

-- Game state.  Anything that should be persisted when the game is saved needs
-- to go here.  Anything transient can go under the game object directly.
gameState = {
  -- NOT reset at the start of each level
  currentLevel = 1,
  introDone = false,
  conclusionDone = false,
  -- Flags to tell which levels are locked
  levelLocks = {
    false, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true
  },
  levelStars = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  powerups = { false, false, false, false } -- Positional, see constants above
};

-- Sound effects used in the game.
sfx = {
  -- These are loaded at the start and never disposed of.
  menuBeep = audio.loadSound("sfxMenuBeep.wav"),
  levelSelection = audio.loadSound("sfxLevelSelection.wav"),
  -- These are loaded and are disposed of during gameplay.
  bigExplosion = nil,
  bigExplosionChannel = nil,
  diverterExplosion = nil,
  diverterExplosionChannel = nil,
  backgroundHum = nil,
  backgroundHumChannel = nil,
  enteringGoodPort = nil,
  enteringGoodPortChannel = nil,
  levelCompleted = nil,
  levelCompletedChannel = nil,
  portExplosion = nil,
  portExplosionChannel = nil,
  diverterChanged = nil,
  diverterChangedChannel = nil,
  levelFailed = nil,
  levelFailedChannel = nil,
  antimatterIntoSink = nil,
  antimatterIntoSinkChannel = nil,
  particleEmerging = nil,
  particleEmergingChannel = nil,
  powerupIntoPrison = nil,
  powerupIntoPrisonChannel = nil,
  powerupUsed = nil,
  powerupUsedChannel = nil
};


-- Do game initialization tasks (load images, etc).
utils:xpcall("appInit.lua:Calling initializeGame()", initializeGame);


-- ****************************************************************************
-- Execution begins here.
-- ****************************************************************************


-- Start tracking info.
utils:showFPSAndMem();

-- Get rid of our loading message.
loadingText:removeSelf();
loadingText = nil;

-- Start the title scene.
utils:log("appInit", "Going to titleScene");
storyboard.gotoScene("titleScene", sceneTransitionEffect, 500 );
