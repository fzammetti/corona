-- Locations of static elements.
local particleMeterX = (display.contentWidth - 400) / 2 - 50;
local particleMeterY = -3;
local pauseButtonX = display.contentWidth - 36;
local pauseButtonY = 2;
local powerupsButtonX = 2;
local powerupsButtonY = 2;


-- Reset at the start of each level
particlesDone = 0;


-- ============================================================================
-- Initializes the app.  Do any one-time setup here that should only
-- happen once when the app starts up.
-- ============================================================================
function initializeGame()

  utils:log("gameCore", "initializeGame()");

  -- Create diverter SpriteSheets, SpriteSets and animation sequences.
  diverterResources.sheets = {
    downLeft = sprite.newSpriteSheet("game_diverter_downLeft.png", 42, 42),
    downRight =
      sprite.newSpriteSheet("game_diverter_downRight.png", 42, 42),
    horizontal =
      sprite.newSpriteSheet("game_diverter_horizontal.png", 42, 42),
    upLeft = sprite.newSpriteSheet("game_diverter_upLeft.png", 42, 42),
    upRight = sprite.newSpriteSheet("game_diverter_upRight.png", 42, 42),
    vertical = sprite.newSpriteSheet("game_diverter_vertical.png", 42, 42),
    cross = sprite.newSpriteSheet("game_diverter_cross.png", 42, 42)
  };
  diverterResources.sets = {
    downLeft =
      sprite.newSpriteSet(diverterResources.sheets.downLeft, 1, 1),
    downRight =
      sprite.newSpriteSet(diverterResources.sheets.downRight, 1, 1),
    horizontal =
      sprite.newSpriteSet(diverterResources.sheets.horizontal, 1, 1),
    upLeft = sprite.newSpriteSet(diverterResources.sheets.upLeft, 1, 1),
    upRight = sprite.newSpriteSet(diverterResources.sheets.upRight, 1, 1),
    vertical =
      sprite.newSpriteSet(diverterResources.sheets.vertical, 1, 1),
    cross = sprite.newSpriteSet(diverterResources.sheets.cross, 1, 1)
  };
  sprite.add(diverterResources.sets.downLeft, "default", 1, 1, 100);
  sprite.add(diverterResources.sets.downRight, "default", 1, 1, 100);
  sprite.add(diverterResources.sets.horizontal, "default", 1, 1, 100);
  sprite.add(diverterResources.sets.upLeft, "default", 1, 1, 100);
  sprite.add(diverterResources.sets.upRight, "default", 1, 1, 100);
  sprite.add(diverterResources.sets.vertical, "default", 1, 1, 100);
  sprite.add(diverterResources.sets.cross, "default", 1, 1, 100);

  -- Create particle SpriteSheets, SpriteSets and animation sequences.
  local pWH = 38;
  particleResources.sheets = {
    red = sprite.newSpriteSheet("game_particle_red.png", pWH, pWH),
    blue = sprite.newSpriteSheet("game_particle_blue.png", pWH, pWH),
    green = sprite.newSpriteSheet("game_particle_green.png", pWH, pWH),
    yellow = sprite.newSpriteSheet("game_particle_yellow.png", pWH, pWH),
    red_anti = sprite.newSpriteSheet("game_particle_red_anti.png", pWH, pWH),
    blue_anti =
      sprite.newSpriteSheet("game_particle_blue_anti.png", pWH, pWH),
    green_anti =
      sprite.newSpriteSheet("game_particle_green_anti.png", pWH, pWH),
    yellow_anti =
      sprite.newSpriteSheet("game_particle_yellow_anti.png", pWH, pWH),
    powerup = sprite.newSpriteSheet("game_particle_powerup.png", pWH, pWH)
  };
  particleResources.sets = {
    red = sprite.newSpriteSet(particleResources.sheets.red, 1, 4),
    blue = sprite.newSpriteSet(particleResources.sheets.blue, 1, 4),
    green = sprite.newSpriteSet(particleResources.sheets.green, 1, 4),
    yellow = sprite.newSpriteSet(particleResources.sheets.yellow, 1, 4),
    red_anti =
      sprite.newSpriteSet(particleResources.sheets.red_anti, 1, 4),
    blue_anti =
      sprite.newSpriteSet(particleResources.sheets.blue_anti, 1, 4),
    green_anti =
      sprite.newSpriteSet(particleResources.sheets.green_anti, 1, 4),
    yellow_anti =
      sprite.newSpriteSet(particleResources.sheets.yellow_anti, 1, 4),
    powerup = sprite.newSpriteSet(particleResources.sheets.powerup, 1, 4)
  };
  sprite.add(particleResources.sets.red, "default", 1, 4, 500);
  sprite.add(particleResources.sets.blue, "default", 1, 4, 500);
  sprite.add(particleResources.sets.green, "default", 1, 4, 500);
  sprite.add(particleResources.sets.yellow, "default", 1, 4, 500);
  sprite.add(particleResources.sets.red_anti, "default", 1, 4, 500);
  sprite.add(particleResources.sets.blue_anti, "default", 1, 4, 500);
  sprite.add(particleResources.sets.green_anti, "default", 1, 4, 500);
  sprite.add(particleResources.sets.yellow_anti, "default", 1, 4, 500);
  sprite.add(particleResources.sets.powerup, "default", 1, 4, 250);

  -- Create generator SpriteSheets, SpriteSets and animation sequences.
  generatorResources.sheet =
    sprite.newSpriteSheet("game_generator.png", 98, 98);
  generatorResources.set =
    sprite.newSpriteSet(generatorResources.sheet, 1, 16);
  sprite.add(generatorResources.set, "default", 1, 8, 500);
  sprite.add(generatorResources.set, "offline", 9, 8, 500);

  -- Create antimatter sink SpriteSheets, SpriteSets and animation sequences.
  antimatterSinkResources.sheet =
    sprite.newSpriteSheet("game_antimatterSink.png", 42, 42);
  antimatterSinkResources.set =
    sprite.newSpriteSet(antimatterSinkResources.sheet, 1, 8);
  sprite.add(antimatterSinkResources.set, "default", 1, 8, 250);

  -- Create particle prison SpriteSheets, SpriteSets and animation sequences.
  particlePrisonResources.sheet =
    sprite.newSpriteSheet("game_particlePrison.png", 42, 42);
  particlePrisonResources.set =
    sprite.newSpriteSet(particlePrisonResources.sheet, 1, 1);
  sprite.add(particlePrisonResources.set, "default", 1, 1, 100);

  -- Create port SpriteSheets, SpriteSets and animation sequences.
  portResources.sheets = {
    red = sprite.newSpriteSheet("game_port_red.png", 70, 70),
    blue = sprite.newSpriteSheet("game_port_blue.png", 70, 70),
    green = sprite.newSpriteSheet("game_port_green.png", 70, 70),
    yellow = sprite.newSpriteSheet("game_port_yellow.png", 70, 70)
  };
  portResources.sets = {
    red = sprite.newSpriteSet(portResources.sheets.red, 1, 3),
    blue = sprite.newSpriteSet(portResources.sheets.blue, 1, 3),
    green = sprite.newSpriteSet(portResources.sheets.green, 1, 3),
    yellow = sprite.newSpriteSet(portResources.sheets.yellow, 1, 3)
  };
  sprite.add(portResources.sets.red, "damaged0", 1, 1, 100);
  sprite.add(portResources.sets.red, "damaged1", 2, 1, 100);
  sprite.add(portResources.sets.red, "damaged2", 3, 1, 100);
  sprite.add(portResources.sets.blue, "damaged0", 1, 1, 100);
  sprite.add(portResources.sets.blue, "damaged1", 2, 1, 100);
  sprite.add(portResources.sets.blue, "damaged2", 3, 1, 100);
  sprite.add(portResources.sets.green, "damaged0", 1, 1, 100);
  sprite.add(portResources.sets.green, "damaged1", 2, 1, 100);
  sprite.add(portResources.sets.green, "damaged2", 3, 1, 100);
  sprite.add(portResources.sets.yellow, "damaged0", 1, 1, 100);
  sprite.add(portResources.sets.yellow, "damaged1", 2, 1, 100);
  sprite.add(portResources.sets.yellow, "damaged2", 3, 1, 100);

  -- Powerup button.
  powerupsButton = { sheet = nil, set = nil, sprite = nil };
  powerupsButton.sheet = sprite.newSpriteSheet("game_powerupButton.png", 128, 32);
  powerupsButton.set = sprite.newSpriteSet(powerupsButton.sheet, 1, 7);
  sprite.add(powerupsButton.set, "default", 1, 1, 500);
  sprite.add(powerupsButton.set, "available", 2, 6, 250);

  -- Sound effects.
  sfx.backgroundHum = audio.loadSound("sfxBackgroundHum.wav");
  sfx.bigExplosion = audio.loadSound("sfxBigExplosion.wav");
  sfx.diverterExplosion = audio.loadSound("sfxDiverterExplosion.wav");
  sfx.enteringGoodPort = audio.loadSound("sfxEnteringGoodPort.wav");
  sfx.levelCompleted = audio.loadSound("sfxLevelCompleted.wav");
  sfx.levelFailed = audio.loadSound("sfxLevelFailed.wav");
  sfx.portExplosion = audio.loadSound("sfxPortExplosion.wav");
  sfx.diverterChanged = audio.loadSound("sfxDiverterChanged.wav");
  sfx.antimatterIntoSink = audio.loadSound("sfxAntimatterIntoSink.wav");
  sfx.particleEmerging = audio.loadSound("sfxParticleEmerging.wav");
  sfx.powerupIntoPrison = audio.loadSound("sfxPowerupIntoPrison.wav");
  sfx.powerupUsed = audio.loadSound("sfxPowerupUsed.wav");

end -- End initializeGame().


-- ============================================================================
-- Creates the "global" display objects, those at the top, when the gameScene
-- is created.
-- ============================================================================
function createGlobalDisplayObjects()

  utils:log("gameCore", "createGlobalDisplayObjects()");

  -- Particle meter.
  particleMeter = widgetCandy.NewProgBar({
    x = particleMeterX, y = particleMeterY, width = 592, name = "energyMeter",
    theme = "widgetCandy_theme2", value = 0, border = { },
    textFormatter = function(value)
      return "";
    end
  });
  particleMeter.isVisible = false;

  -- Pause menu: Button.
  pause.button = display.newImage("pauseMenu_triggerButton.png", true);
  pause.button:setReferencePoint(display.TopLeftReferencePoint);
  pause.button.x = pauseButtonX;
  pause.button.y = pauseButtonY;
  pause.button.targetID = "pause_trigger";
  pause.button:addEventListener("touch", gameTouch);
  pause.button.isVisible = false;

  -- Powerup button.
  powerupsButton.sprite = sprite.newSprite(powerupsButton.set, true);
  powerupsButton.sprite.targetID = "powerups_trigger";
  powerupsButton.sprite:setReferencePoint(display.TopLeftReferencePoint);
  powerupsButton.sprite.x = powerupsButtonX;
  powerupsButton.sprite.y = powerupsButtonY;
  powerupsButton.sprite:prepare("default");
  powerupsButton.sprite:play();
  powerupsButton.sprite:addEventListener("touch", gameTouch);
  powerupsButton.sprite.isVisible = false;

end -- End createGlobalDisplayObjects().


-- ============================================================================
-- Starts a new game.
-- ============================================================================
function newGame()

  utils:log("gameCore", "newGame()");

  -- Reset game state to defaults.
  particlesDone = nil;
  gameState.currentLevel = 1;
  gameState.introDone = false;
  gameState.conclusionDone = false;
  for i = 1, numLevels, 1 do
    gameState.levelLocks[i] = true;
    gameState.levelStars[i] = 0;
  end
  gameState.levelLocks[1] = false;
  gameState.levelStars[1] = 0;
  gameState.powerups = { false, false, false, false };

  -- Persist the state to overwrite any in-progress game.
  utils:xpcall("gameCore.lua:Calling saveState()", saveState);

end -- End newGame().


-- ============================================================================
-- Starts a new level as defined by gameState.currentLevel.  This draws
-- the level and does other setup that should happen at the start of
-- each new level.
-- ============================================================================
function startLevel()

  utils:log("gameCore", "startLevel()");

  -- Reset powerups.
  powerupsMenuShowing = false;
  powerupOfflineActive = false;
  powerupGravityActive = false;

  -- Clear out all resources for the previous level, if any (DisplayObjects).
  if currentLevel.dg ~= nil then
    currentLevel.dg:removeSelf();
    currentLevel.dg = nil;
  end
  currentLevel.dg = display.newGroup();

  -- Get references to the level descriptor object.
  local levelDef = levels[gameState.currentLevel];
  currentLevel.levelDef = levelDef;
  currentLevel.levelData = levelDef.data;

  -- New collections in currentLevel.
  currentLevel.diverters = { };
  currentLevel.generators = { };
  currentLevel.particlePrisons = { };
  currentLevel.antimatterSinks = { };
  currentLevel.particles = { };
  currentLevel.ports = { };

  -- Star deduction variables.
  currentLevel.numPortExplosions = 0;
  currentLevel.numDiverterExplosions = 0;
  currentLevel.numAntimatterExplosions = 0;
  currentLevel.numParticlesInSink = 0;
  currentLevel.numParticlesInPrison = 0;

  -- Any other level setup tasks (variables in currentLevel).
  currentLevel.emergeCount = 0;
  currentLevel.powerupFrequencyCount = 0;

  -- Reset anything in game state that needs to be reset.
  particlesDone = -1; -- Gets incremented to 0 by updateMeter().

  -- Make global items visible.
  pause.button.isVisible = true;
  powerupsButton.sprite.isVisible = true;
  particleMeter.isVisible = true;

  -- Draw the board (diverters, generators, particle prisons, track, ports).
  drawBoard(levelDef);

  -- Flash powerups button if any powerups are available.
  if gameState.powerups[POWERUP_FIXIT] == true or
    gameState.powerups[POWERUP_DEGAUSS] == true or
    gameState.powerups[POWERUP_OFFLINE] == true or
    gameState.powerups[POWERUP_GRAVITY] == true then
    powerupsButton.sprite:prepare("available");
    powerupsButton.sprite:play();
  end

  -- Create the particle meter.
  utils:xpcall("gameCore.lua:Calling updateMeter()", updateMeter);
  particleMeter.isVisible = false;

  currentLevel.dg:insert(pause.button);
  currentLevel.dg:insert(powerupsButton.sprite);
  currentLevel.sceneGroup:insert(currentLevel.dg);

  -- Finally, switch to playing mode.
  currentMode = MODE_PLAYING;

end -- End startLevel().


-- ============================================================================
-- Process the next frame.
--
-- @param inEvent Event object.
-- ============================================================================
function enterFrame(inEvent)

  -- Game is being played.
  if currentMode == MODE_PLAYING then

    utils:xpcall("gameCore.lua:Calling updateParticles()", updateParticles);

  -- Level has been successfully completed, need to animate the text.
  elseif currentMode == MODE_LEVEL_COMPLETE then

    utils:xpcall(
      "gameCore.lua:Calling updateLevelCompleteAnimation()",
      updateLevelCompleteAnimation
    );

  end

end -- End enterFrame().


-- ============================================================================
-- Handle touch events.
--
-- @param inEvent Event object.
-- ============================================================================
function gameTouch(inEvent)

  --utils:log("gameCoreEvents", "gameTouch()");

  if confirmPopupShowing == true then
    return true;
  end

  -- Get the ID of the element tapped and break if into its component parts.
  -- Element 1 is always the type, element 2 is extended information as
  -- appropriate for the type.
  local id = inEvent.target.targetID;
  local parts = utils:split(id, "_");

  -- Handle touch events for when the game is being played.
  if currentMode == MODE_PLAYING and inEvent.phase == "began" then

    -- Diverter.  Active as long as powerups menu isn't showing.
    if parts[1] == "diverter" and
      powerupsMenuShowing == false then
      processDiverterTouch(id, parts);

    -- Powerups button.
    elseif parts[1] == "powerups" then
      processPowerupsTouch(id, parts);

    -- Pause button.
    elseif id == "pause_trigger" and
      powerupsMenuShowing == false and powerupOfflineActive == false and
      powerupGravityActive == false then
      audio.play(sfx.menuBeep);
      utils:xpcall("pauseMenu.lua:Calling showPauseMenu()", showPauseMenu);

    end

  end

  return true;

end -- End gameTouch().


-- ============================================================================
-- Update the particle meter.  Called every time a particle enters the
-- correct port.  This also takes care of changing the mode to the level
-- advance mode when the current level is complete.
--
-- @return Returns true if the level is complete, false if not.
-- ============================================================================
function updateMeter()

  --utils:log("gameCore", "updateMeter()");

  -- Bump up number of particles done.
  particlesDone = particlesDone + 1;

  -- Update widget value.
  particleMeter:set("value",
    (1 / currentLevel.levelDef.particlesToComplete) * particlesDone
  );

  -- See if its time to complete the level.
  if particlesDone == currentLevel.levelDef.particlesToComplete then
    utils:log("gameCore", "Level completed successfully");
    utils:xpcall("gameCore.lua:Calling levelComplete()", levelComplete);
    return true;
  end

  return false;

end -- End updateMeter().


-- ============================================================================
-- Process a touch event on a diverter.
--
-- @param inTargetID The targetID of the touched diverter.
-- @param inParts    The split up targetID.
-- ============================================================================
function processDiverterTouch(inTargetID, inParts)

  --utils:log("gameCore", "processDiverterTouch()");

  -- Get the reference to the diverter sprite.
  local diverter = currentLevel.diverters[inTargetID];
  -- Figure out the new state based on the old.
  local newState;
  if diverter.diverterState == "downLeft" then
    newState = "upLeft";
  elseif diverter.diverterState == "upLeft" then
    newState = "upRight";
  elseif diverter.diverterState == "upRight" then
    newState = "downRight";
  elseif diverter.diverterState == "downRight" then
    newState = "vertical";
  elseif diverter.diverterState == "vertical" then
    newState = "horizontal";
  elseif diverter.diverterState == "horizontal" then
    newState = "cross";
  elseif diverter.diverterState == "cross" then
    newState = "downLeft";
  end
  -- Remove diverter from the collection of diverter and display.
  diverter:removeSelf();
  diverter = nil;
  currentLevel.diverters[inTargetID] = nil;
  -- Create a new diverter in its place with the correct state.
  createDiverter({state = newState, gridX = inParts[2], gridY = inParts[3]});

  -- Play diverter changed sound.
  sfx.diverterChangedChannel = audio.play(sfx.diverterChanged);

end -- End processDiverterTouch().


-- ============================================================================
-- Shows a transient fading, expanding message.
--
-- @param inMsg The message to display.
-- ============================================================================
function showMessage(inMsg)

  utils:log("gameCore", "showMessage(): inMsg = " .. inMsg);

  -- Create message text.
  local msgText = display.newText(inMsg, 0, 0, nil, 20);
  msgText:setFillColor(0, 0, 255);
  msgText.x = display.contentWidth / 2;
  msgText.y = (display.contentHeight / 2);
  msgText.alpha = 1;
  msgText.xScale = 1.0;
  msgText.yScale = 1.0;

  transition.to(msgText,
    { time = 1000, alpha = 0, xScale = 30.0, yScale = 30.0,
      onComplete = function(inTarget)
        inTarget:removeSelf();
        inTarget = nil;
      end
    }
  );

end -- End showMessage().


-- ============================================================================
-- Persists the gameState object in JSON form.
--
-- @param inGameState The game state object to save.
-- ============================================================================
function saveState()

  utils:log("gameCore", "saveState(): ", gameState);

  local path = system.pathForFile("gameState.json", system.DocumentsDirectory);
  if path ~= nil then
    --utils:log("gameCore", "Path to gameState.json obtained, writing file");
    local fh = io.open(path, "w+");
    fh:write(json.encode(gameState));
    io.close(fh);
  end

end -- End saveState().


-- ============================================================================
-- Loads the gameState object.
--
-- @return True if tne file was found, false if not.
-- ============================================================================
function loadState()

  utils:log("gameCore", "loadState()");

  local path = system.pathForFile("gameState.json", system.DocumentsDirectory);
  if path ~= nil then
    --utils:log("gameCore", "Path to gameState.json obtained");
    local fh = io.open(path, "r");
    if fh == nil then
      --utils:log("gameCore", "gameState.json not found");
      return false;
    else
      --utils:log("gameCore", "gameState.json opened, reading file");
      gameState = json.decode(fh:read("*a"));
      io.close(fh);
      utils:log("gameCore", "loadState(): ", gameState);
      return true;
    end
  end

end -- End loadState().


-- ============================================================================
-- Applies (or removes) an animation to a TextCandy object.  Used for menu
-- items that the user can tap.
--
-- @param inTarget The TexrCandy object.
-- @param inRemove If true any existing animation is removed.
-- ============================================================================
function applyOrRemoveDownAnimation(inTarget, inRemove)

  --utils:log("gameCore", "applyOrRemoveDownAnimation()");

  if inRemove == true then
    inTarget:setColor(255, 255, 255, 255);
  else
    inTarget:setColor(255, 0, 0, 255);
  end

end -- End applyOrRemoveDownAnimation().
