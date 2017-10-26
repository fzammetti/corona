local dg = nil;
local fixitSheet;
local degaussSheet;
local offlineSheet;
local gravitySheet;
local fixitText;
local degaussText;
local offlineText;
local gravityText;
local degaussParticles = { };


-- ============================================================================
-- Process a powerups menu event on a pause menu element.
--
-- @param inTargetID The targetID of the touched diverter.
-- @param inParts    The split up targetID.
-- ============================================================================
function processPowerupsTouch(inTargetID, inParts)

  --utils:log("gameCore", "processPowerupsTouch()");

  -- Show the powerups menu if it isn't showing already.
  if inTargetID == "powerups_trigger" then
    if powerupsMenuShowing == true then
      -- Already showing, so destroy it.
      audio.play(sfx.menuBeep);
      utils:xpcall(
        "powerupsMenu.lua:Calling destroyPowerupsMenu()", destroyPowerupsMenu
      );
    -- Only show if one of the two "active" powerups isn't currently active
    elseif powerupsMenuShowing == false and
      powerupOfflineActive == false and
      powerupGravityActive == false then
      utils:xpcall(
        "powerupsMenu.lua:Calling showPowerupsMenu()", showPowerupsMenu
      );
    end

  -- Handle touches on the powerup icons.
  elseif inTargetID == "powerups_fixit" then
    utils:xpcall("powerupsMenu.lua:Calling useFixit()", useFixit);
  elseif inTargetID == "powerups_degauss" then
    utils:xpcall("powerupsMenu.lua:Calling useDegauss()", useDegauss);
  elseif inTargetID == "powerups_offline" then
    utils:xpcall("powerupsMenu.lua:Calling useOffline()", useOffline);
  elseif inTargetID == "powerups_gravity" then
    utils:xpcall("powerupsMenu.lua:Calling useGravity()", useGravity);
  end

end -- End processPowerupsTouch().


-- ============================================================================
-- Sets up and shows the powerups menu.
-- ============================================================================
function showPowerupsMenu()

  utils:log("gameCore", "showPowerupsMenu()");

  -- Flip flag to indicate menu is showing.
  powerupsMenuShowing = true;

  -- DisplayGroup for all visual elements.
  dg = display.newGroup();

  -- Faded rectangle behind powerups.
  local fadeRect =
    display.newRoundedRect(20, 120, display.contentWidth - 40, 220, 30);
  fadeRect:setReferencePoint(display.TopLeftReferencePoint);
  fadeRect:setFillColor(0, 0, 0);
  fadeRect.alpha = 0.5;
  dg:insert(fadeRect);

  -- Sprites for powerups.
  local x = 95
  local y = 200;
  local separation = 200;
  fixitSheet = sprite.newSpriteSheet("game_powerupFixit.png", 128, 128);
  local fixitSet = sprite.newSpriteSet(fixitSheet, 1, 4);
  sprite.add(fixitSet, "default", 1, 1, 100);
  sprite.add(fixitSet, "unavailable", 2, 3, 250);
  local fixitSprite = sprite.newSprite(fixitSet, true);
  fixitSprite.x = x;
  fixitSprite.y = y;
  fixitSprite.targetID = "powerups_fixit";
  dg:insert(fixitSprite);
  degaussSheet = sprite.newSpriteSheet("game_powerupDegauss.png", 128, 128);
  local degaussSet = sprite.newSpriteSet(degaussSheet, 1, 4);
  sprite.add(degaussSet, "default", 1, 1, 100);
  sprite.add(degaussSet, "unavailable", 2, 3, 250);
  local degaussSprite = sprite.newSprite(degaussSet, true);
  degaussSprite.x = x + separation;
  degaussSprite.y = y;
  degaussSprite.targetID = "powerups_degauss";
  dg:insert(degaussSprite);
  offlineSheet = sprite.newSpriteSheet("game_powerupOffline.png", 128, 128);
  local offlineSet = sprite.newSpriteSet(offlineSheet, 1, 4);
  sprite.add(offlineSet, "default", 1, 1, 100);
  sprite.add(offlineSet, "unavailable", 2, 3, 250);
  local offlineSprite = sprite.newSprite(offlineSet, true);
  offlineSprite.x = x + (separation * 2);
  offlineSprite.y = y;
  offlineSprite.targetID = "powerups_offline";
  dg:insert(offlineSprite);
  gravitySheet = sprite.newSpriteSheet("game_powerupGravity.png", 128, 128);
  local gravitySet = sprite.newSpriteSet(gravitySheet, 1, 4);
  sprite.add(gravitySet, "default", 1, 1, 100);
  sprite.add(gravitySet, "unavailable", 2, 3, 250);
  local gravitySprite = sprite.newSprite(gravitySet, true);
  gravitySprite.x = x + (separation * 3);
  gravitySprite.y = y;
  gravitySprite.targetID = "powerups_gravity";
  dg:insert(gravitySprite);

  -- Text for powerups.
  fixitText = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = fixitSprite.x, y = fixitSprite.y + 100,
    text = "FIXIT", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false
  });
  dg:insert(fixitText);
  degaussText = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = degaussSprite.x, y = degaussSprite.y + 100,
    text = "DEGAUSS", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false
  });
  dg:insert(degaussText);
  offlineText = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = offlineSprite.x, y = offlineSprite.y + 100,
    text = "OFFLINE", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false
  });
  dg:insert(offlineText);
  gravityText = textCandy.CreateText({
    fontName = "fontSmallSilver",
    x = gravitySprite.x, y = gravitySprite.y + 100,
    text = "GRAVITY", originX = "center", originY = "center",
    textFlow = "center", charSpacing = 0, lineSpacing = 0,
    showOrigin = false
  });
  dg:insert(gravityText);

  -- Attach event handler to powerups that the user has or switch to the
  -- unavailable sprite version if applicable.
  if gameState.powerups[POWERUP_FIXIT] == true then
    fixitSprite:addEventListener("touch", gameTouch);
    fixitSprite:prepare("default");
    fixitSprite:play();
  else
    fixitSprite:prepare("unavailable");
    fixitSprite:play();
  end
  if gameState.powerups[POWERUP_DEGAUSS] == true then
    degaussSprite:addEventListener("touch", gameTouch);
    degaussSprite:prepare("default");
    degaussSprite:play();
  else
    degaussSprite:prepare("unavailable");
    degaussSprite:play();
  end
  if gameState.powerups[POWERUP_OFFLINE] == true then
    offlineSprite:addEventListener("touch", gameTouch);
    offlineSprite:prepare("default");
    offlineSprite:play();
  else
    offlineSprite:prepare("unavailable");
    offlineSprite:play();
  end
  if gameState.powerups[POWERUP_GRAVITY] == true then
    gravitySprite:addEventListener("touch", gameTouch);
    gravitySprite:prepare("default");
    gravitySprite:play();
  else
    gravitySprite:prepare("unavailable");
    gravitySprite:play();
  end

  -- Fade menu in.
  dg.alpha = 0;
  transition.to(dg, { time = 100, alpha = 1 });
  audio.play(sfx.menuBeep);

end -- End showPowerupsMenu().


-- ============================================================================
-- Use a Fixit powerup.
-- ============================================================================
function useFixit()

  utils:log("powerupsMenu", "useFixit()");

  -- Powerup used up.
  gameState.powerups[POWERUP_FIXIT] = false;

  for i, v in pairs(currentLevel.ports) do
    -- Shrink port down to nothing.
    v.originalX = v.x;
    v.originalY = v.y;
    transition.to(v,
      { time = 250, xScale = .01, yScale = .01,
        x = v.x + (v.width / 2),
        y = v.y + (v.height / 2),
        onComplete = function(inTarget)
          -- Expand port out to normal size.
          transition.to(v,
            { time = 250, xScale = 1, yScale = 1,
              x = v.x - (v.width / 2),
              y = v.y - (v.height / 2),
              onComplete = function(inTarget)
                -- Clear damage on all ports.
                for i, v in pairs(currentLevel.ports) do
                  v.x = v.originalX;
                  v.y = v.originalY;
                  if v.damage > 0 then
                    v.damage = 0;
                    v:prepare("damaged0");
                    v:play();
                  end
                end
              end
            }
          );
        end
      }
    );
  end

  -- Destroy powerups menu.
  utils:xpcall(
    "powerupsMenu.lua:Calling destroyPowerupsMenu()", destroyPowerupsMenu
  );

  sfx.powerupUsedChannel = audio.play(sfx.powerupUsed);

end -- End useFixit().


-- ============================================================================
-- Use a Degauss powerup.
-- ============================================================================
function useDegauss()

  utils:log("powerupsMenu", "useDegauss()");

  -- Powerup used up.
  gameState.powerups[POWERUP_DEGAUSS] = false;

  -- Clear all active particles.
  local particles = currentLevel.particles;
  for i = 1, #particles, 1 do
    local particle = particles[i];
    showDegaussSparks(particle.x, particle.y);
    particle.destroyMe = true;
  end

  -- Destroy powerups menu.
  utils:xpcall(
    "powerupsMenu.lua:Calling destroyPowerupsMenu()", destroyPowerupsMenu
  );

  sfx.powerupUsedChannel = audio.play(sfx.powerupUsed);

end -- End useDegauss().


-- ============================================================================
-- Use a Offline powerup.
-- ============================================================================
function useOffline()

  utils:log("powerupsMenu", "useOffline()");

  -- Powerup used up.
  gameState.powerups[POWERUP_OFFLINE] = false;

  -- Set flag to indicate a powerup is active.
  powerupOfflineActive = true;

  -- Freeze all generators.
  for i = 1, #currentLevel.generators, 1 do
    local generator = currentLevel.generators[i];
    generator:prepare("offline");
    generator:play();
  end

  -- Create countdown text.
  powerupsCountdownText = display.newText("5", 0, 0, nil, 40);
  powerupsCountdownText.countdownValue = 6; -- One more than needed.
  powerupsCountdownText:setFillColor(0, 0, 255);
  powerupsCountdownText.x = display.contentWidth / 2;
  powerupsCountdownText.y = (display.contentHeight / 2);
  powerupsCountdownText.alpha = 1;
  powerupsCountdownText.xScale = 1.0;
  powerupsCountdownText.yScale = 1.0;

  -- Define the onComplete callback function for the transition.
  powerupsCountdownText.onCompleteFunction = function(inTarget)
    inTarget.countdownValue = inTarget.countdownValue - 1;
    if inTarget.countdownValue == 0 then
      if powerupsCountdownText ~= nil then
        inTarget:removeSelf();
        powerupsCountdownText = nil;
        powerupOfflineActive = false;
        -- Unfreeze all generators.
        for i = 1, #currentLevel.generators, 1 do
          local generator = currentLevel.generators[i];
          generator:prepare("default");
          generator:play();
        end
      end
    else
      inTarget.text = inTarget.countdownValue;
      inTarget.alpha = 1;
      inTarget.xScale = 1.0;
      inTarget.yScale = 1.0;
      transition.to(inTarget,
        { time = 1000, alpha = 0, xScale = 30.0, yScale = 30.0,
          onComplete = inTarget.onCompleteFunction
        }
      );
    end
  end;

  -- Kick off the transition by calling the callback manually.
  powerupsCountdownText.onCompleteFunction(powerupsCountdownText);

  -- Destroy powerups menu.
  utils:xpcall(
    "powerupsMenu.lua:Calling destroyPowerupsMenu()", destroyPowerupsMenu
  );

  sfx.powerupUsedChannel = audio.play(sfx.powerupUsed);

end -- End useOffline();


-- ============================================================================
-- Use a Gravity powerup.
-- ============================================================================
function useGravity()

  utils:log("powerupsMenu", "useGravity()");

  -- Powerup used up.
  gameState.powerups[POWERUP_GRAVITY] = false;

  -- Set flag to indicate a powerup is active.
  powerupGravityActive = true;
  powerupGravityCounter = 0;

  -- Create countdown text.
  local countdownText = display.newText("5", 0, 0, nil, 40);
  countdownText.countdownValue = 6; -- One more than needed by design.
  countdownText:setFillColor(0, 0, 255);
  countdownText.x = display.contentWidth / 2;
  countdownText.y = (display.contentHeight / 2);
  countdownText.alpha = 1;
  countdownText.xScale = 1.0;
  countdownText.yScale = 1.0;

  -- Define the onComplete callback function for the transition.
  countdownText.onCompleteFunction = function(inTarget)
    inTarget.countdownValue = inTarget.countdownValue - 1;
    if inTarget.countdownValue == 0 then
      inTarget:removeSelf();
      powerupsCountdownText = nil;
      powerupGravityActive = false;
    else
      inTarget.text = inTarget.countdownValue;
      inTarget.alpha = 1;
      inTarget.xScale = 1.0;
      inTarget.yScale = 1.0;
      transition.to(inTarget,
        { time = 1000, alpha = 0, xScale = 30.0, yScale = 30.0,
          onComplete = inTarget.onCompleteFunction
        }
      );
    end
  end;

  -- Kick off the transition by calling the callback manually.
  countdownText.onCompleteFunction(countdownText);

  -- Destroy powerups menu.
  utils:xpcall(
    "powerupsMenu.lua:Calling destroyPowerupsMenu()", destroyPowerupsMenu
  );

  sfx.powerupUsedChannel = audio.play(sfx.powerupUsed);

end -- End useGravity().


-- ============================================================================
-- Destroys the powerups menu.
-- ============================================================================
function destroyPowerupsMenu()

  utils:log("gameCore", "destroyPowerupsMenu()");

  -- Fade menu out.
  transition.to(dg, { time = 100, alpha = 0,
    onComplete = function(inTarget)
      textCandy.DeleteText(offlineText);
      textCandy.DeleteText(gravityText);
      textCandy.DeleteText(fixitText);
      textCandy.DeleteText(degaussText);
      offlineText = nil;
      gravityText = nil;
      fixitText = nil;
      DegaussText = nil;
      fixitSheet:dispose();
      degaussSheet:dispose();
      offlineSheet:dispose();
      gravitySheet:dispose();
      fixitSheet = nil;
      degaussSheet = nil;
      offlineSheet = nil;
      gravitySheet = nil;
      inTarget:removeSelf();
      inTarget = nil;
      powerupsMenuShowing = false;
    end
  });

  -- See if there's no longer any available powerups and change animation on
  -- button if so.
  if gameState.powerups[POWERUP_DEGAUSS] == false and
    gameState.powerups[POWERUP_FIXIT] == false and
    gameState.powerups[POWERUP_GRAVITY] == false and
    gameState.powerups[POWERUP_OFFLINE] == false then
    powerupsButton.sprite:prepare("default");
    powerupsButton.sprite:play();
  end

end -- End destroyPowerupsMenu().


-- ============================================================================
-- Send the powerups DisplayGroup to front (called when a particle is
-- created and the powerups menu is showing. Note that this is global
-- because it's needed in other files that wouldn't have access to it here.
-- ============================================================================
function powerupsMenuToFront()

  utils:log("powerupsMenu", "powerupsMenuToFront()");

  dg:toFront();

end -- End powerupsMenuToFront().
