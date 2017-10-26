-- Amount of frames a particle waits before emerging from a generator.
particleEmergeDelay = 60;


-- ============================================================================
-- Updates any active particles (i.e., moves them).
-- ============================================================================
function updateParticles()

  local mathRandom = math.random;
  local mathABS = math.abs;
  local particleSpeed = currentLevel.levelDef.particleSpeed;
  local levelData = currentLevel.levelData;
  local particles = currentLevel.particles;
  local diverters = currentLevel.diverters;

  -- Bump up powerup count so eventually a powerup can emerge.
  currentLevel.powerupFrequencyCount =
  currentLevel.powerupFrequencyCount + 1;

  -- Destroy any particles marked for destruction last time through.
 	local i = #particles;
 	if i > 0 then
    local stillMore = true;
    while stillMore == true do
      if particles[i].destroyMe == true then
        particles[i]:removeSelf();
        table.remove(particles, i);
      end
      i = i - 1;
      if i == 0 then
        stillMore = false;
      end
    end
  end

  -- See if its time to add a new particle.
  currentLevel.emergeCount = currentLevel.emergeCount + 1;
  if currentLevel.emergeCount >=
    currentLevel.levelDef.timeBetweenParticleCreation and
    #particles < currentLevel.levelDef.maxParticles then
    currentLevel.emergeCount = 0;
    utils:xpcall("particleFunctions.lua:Calling createParticle", createParticle);
  end

  -- Now update all active particles.
  for i = 1, #particles, 1 do

    local particle = particles[i];

    -- If gravity powerup is active then we skip frames to move.
    local moveParticleNow = true;
    if powerupGravityActive == true then
      powerupGravityCounter = powerupGravityCounter + 1;
      if powerupGravityCounter >= 5 then
        powerupGravityCounter = 0;
      else
        moveParticleNow = false;
      end
    end

    -- ------------------------------------------------------------------------
    -- -------------------------------- Moving --------------------------------
    -- ------------------------------------------------------------------------
    if particle.phase == particleResources.PHASE_MOVING then

      if moveParticleNow == true then

        -- Flag if we've moved to a new tile.  We'll use this later.
        local movedToNewTile = false;
        particle.gridMoveCount = particle.gridMoveCount + particleSpeed;
        if particle.gridMoveCount == 14 then
          particle.gridMoveCount = 0;
          movedToNewTile = true;
        end

        -- Move in the appropriate direction.
        if particle.direction == particleResources.MOVING_UP then
          particle:translate(0, -particleSpeed);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridY = particle.gridY - 1;
          end
        elseif particle.direction == particleResources.MOVING_DOWN then
          particle:translate(0, particleSpeed);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridY = particle.gridY + 1;
          end
        elseif particle.direction == particleResources.MOVING_LEFT then
          particle:translate(-particleSpeed, 0);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridX = particle.gridX - 1;
          end
        elseif particle.direction == particleResources.MOVING_RIGHT then
          particle:translate(particleSpeed, 0);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridX = particle.gridX + 1;
          end
        end

        -- If we've to a new tile then we need to determine what to do based
        -- on what it is (or what's around it).
        if movedToNewTile == true then

          -- Check for objects larger than one tile, as long as we don't
          -- cross a screen boundary doing so
          if particle.gridY - 1 > 0 and particle.gridX - 1 > 0 then

            local tileType1 = levelData[particle.gridY - 1][particle.gridX - 1];

            -- ********** DIVERTER CONTACT? **********
            -- If there's a tile one up and left of us, see if it's a diverter,
            -- particle prison or antimatter sink.
            if particle.gridX > 1 and particle.gridY > 1 and
              tileType1 == "D" then
              particle.gridMoveCount = 0;
              particle.phaseCount = 0;
              particle.phase = particleResources.PHASE_DIVERTER;
              return;
            end

            -- ********** PARTICLE PRISON CONTACT? **********
            -- If there's a tile one up and left of us, see if it's a diverter,
            -- particle prison or antimatter sink.
            if particle.gridX > 1 and particle.gridY > 1 and
              tileType1 == "N" then
              --utils:log("updateParticles", "Entered particle prison");
              sfx.powerupIntoPrisonChannel =
                audio.play(sfx.powerupIntoPrison);
              if particle.particleType == "powerup" then
                local powerupType = mathRandom(1, 4);
                gameState.powerups[powerupType] = true;
                showMessage(powerupTexts[powerupType]);
                -- Flash powerups button since we know there's at least one
                -- powerup available now.
                powerupsButton.sprite:prepare("available");
                powerupsButton.sprite:play();
              else
                -- Not a powerup, counts against stars.
                currentLevel.numParticlesInPrison =
                  currentLevel.numParticlesInPrison + 1;
              end
              -- Mark particle for destruction either way.
              particle.destroyMe = true;
            end

            -- ********** ANTIMATTER SINK CONTACT? **********
            -- If there's a tile one up and left of us, see if it's a diverter,
            -- particle prison or antimatter sink.
            if particle.gridX > 1 and particle.gridY > 1 and
              tileType1 == "I" then
              --utils:log("updateParticles", "Entered antimatter sink");
              sfx.antimatterIntoSinkChannel =
                audio.play(sfx.antimatterIntoSink);
              -- If the particle is NOT antimatter then count against stars.
              if particle.isAntiparticle == false then
                currentLevel.numParticlesInSink =
                  currentLevel.numParticlesInSink + 1;
              end
              -- Mark particle for destruction.
              particle.destroyMe = true;
            end

            -- ********** PORT CONTACT? **********
            -- If there's a tile two up and left of us, see if it's a port.
            if particle.gridX > 2 and particle.gridY > 2 then
              local tileType2 =
                levelData[particle.gridY - 2][particle.gridX - 2];
              if tileType2 == "R" or tileType2 == "G" or tileType2 == "Y" or
                tileType2 == "B" then
                -- Determine whether to bump the energy bar up or damage port.
                if particle.isAntiparticle == false and (
                  (tileType2 == "R" and particle.particleType == "red") or
                  (tileType2 == "G" and particle.particleType == "green") or
                  (tileType2 == "Y" and particle.particleType == "yellow") or
                  (tileType2 == "B" and particle.particleType == "blue")
                ) then
                  --utils:log("updateParticles", "Entered correct port");
                  if utils:xpcall(
                    "gameCore.lua:Calling updateMeter()", updateMeter
                  ) == true then
                    return;
                  else
                    -- Only play this sound if the level didn't just end.
                    sfx.enteringGoodPortChannel =
                      audio.play(sfx.enteringGoodPort);
                  end
                else
                  -- Wrong port.
                  --utils:log("updateParticles", "Entered incorrect port");
                  showPortExplosion(particle.x, particle.y);
                  local port = currentLevel.ports[
                    "port_" .. (particle.gridX - 2) .. "_" ..
                    (particle.gridY - 2)
                  ];
                  port.damage = port.damage + 1;
                  if port.damage == 3 then
                    --utils:log("updateParticles", "Port damaged too much");
                    utils:xpcall(
                      "particleFunctions.lua:Calling levelFailed()", levelFailed
                    );
                    -- Still destroy particle in case dev flags are set to not
                    -- fail levels, this way the particle goes away.
                    particle.destroyMe = true;
                    return;
                  else
                    -- Port isn't damaged beyond repair, just change image.
                    port:prepare("damaged" .. port.damage);
                    port:play();
                    sfx.portExplosionChannel =
                      audio.play(sfx.portExplosion);
                  end
                end
                -- Mark particle for destruction in any case.
                particle.destroyMe = true;
              end
            end

            -- ********** GENERATOR CONTACT? **********
            -- If there's a tile three up and left of us, see if it's
            -- a generator.
            if particle.gridX > 3 and particle.gridY > 3 then
              if levelData[particle.gridY - 3][particle.gridX - 3] ==
                "E" then
                -- If the offline powerup is active then we just destroy the
                -- particle, otherwise the game ends.
                if powerupOfflineActive == true then
                  particle.destroyMe = true;
                else
                  --utils:log("updateParticles", "Entered generator");
                  showGeneratorExplosion(particle.x, particle.y);
                  utils:xpcall(
                    "particleFunctions.lua:Calling levelFailed()", levelFailed
                  );
                  -- Still destroy particle in case dev flags are set to not
                  -- fail levels, this way the particle goes away.
                  particle.destroyMe = true;
                  return;
                end
              end
            end

          end -- End check for objects larger than 1 tile.

          -- Now see if we need to change direction.  Note that only track tile
          -- types that could cause a direction change need to be looked at
          -- here.
          local tileType = levelData[particle.gridY][particle.gridX];

          -- Upper-left corner
          if tileType == "Q" then
            if particle.direction == particleResources.MOVING_UP then
              particle.direction = particleResources.MOVING_RIGHT;
            elseif particle.direction == particleResources.MOVING_LEFT then
              particle.direction =  particleResources.MOVING_DOWN;
            end

          -- Upper-right corner
          elseif tileType == "W" then
            if particle.direction == particleResources.MOVING_UP then
              particle.direction = particleResources.MOVING_LEFT;
            elseif particle.direction ==
              particleResources.MOVING_RIGHT then
              particle.direction = particleResources.MOVING_DOWN;
            end

          -- Lower-left corner.
          elseif tileType == "A" then
            if particle.direction == particleResources.MOVING_DOWN then
              particle.direction = particleResources.MOVING_RIGHT;
            elseif particle.direction ==
               particleResources.MOVING_LEFT then
              particle.direction = particleResources.MOVING_UP;
            end

          -- Lower-right corner
          elseif tileType == "S" then
            if particle.direction == particleResources.MOVING_DOWN then
              particle.direction = particleResources.MOVING_LEFT;
            elseif particle.direction ==
              particleResources.MOVING_RIGHT then
              particle.direction = particleResources.MOVING_UP;
            end

          -- Left t-joint.
          elseif tileType == "K" then
            -- If moving right then change to either up or down.
            if particle.direction == particleResources.MOVING_RIGHT then
              particle.direction = mathRandom(1, 2);
            end

          -- Right t-joint.
          elseif tileType == "L" then
            -- If moving left then change to either up or down.
            if particle.direction == particleResources.MOVING_LEFT then
              particle.direction = mathRandom(1, 2);
            end

          -- Up t-joint.
          elseif tileType == "O" then
            -- If moving down then change to either left or right.
            if particle.direction == particleResources.MOVING_DOWN then
              particle.direction = mathRandom(3, 4);
            end

          -- Down t-joint.
          elseif tileType == "P" then
            -- If moving up then change to either left or right.
            if particle.direction == particleResources.MOVING_UP then
              particle.direction = mathRandom(3, 4);
            end

          end -- End tile type branching.

        end -- End check of movedToNewTile.

      end -- End check of moveParticleNow.

    -- ------------------------------------------------------------------------
    -- ------------------------------- Emerging -------------------------------
    -- ------------------------------------------------------------------------
    elseif particle.phase == particleResources.PHASE_EMERGING then

      if moveParticleNow == true then

        -- Flag if we've moved to a new tile.  We'll use this later.
        particle.gridMoveCount =
          particle.gridMoveCount + particleSpeed;
        local movedToNewTile = false;
        if particle.gridMoveCount == 14 then
          particle.gridMoveCount = 0;
          movedToNewTile = true;
        end

        -- Move one pixel in the appropriate direction.
        if particle.direction == particleResources.MOVING_UP then
          particle:translate(0, -particleSpeed);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridY = particle.gridY - 1;
          end
        elseif particle.direction == particleResources.MOVING_DOWN then
          particle:translate(0, particleSpeed);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridY = particle.gridY + 1;
          end
        elseif particle.direction == particleResources.MOVING_LEFT then
          particle:translate(-particleSpeed, 0);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridX = particle.gridX - 1;
          end
        elseif particle.direction == particleResources.MOVING_RIGHT then
          particle:translate(particleSpeed, 0);
          -- Update if moved to new tile.
          if movedToNewTile == true then
            particle.gridX = particle.gridX + 1;
          end
        end

        -- See if its time to switch phases (when we've moved three tiles).
        particle.phaseCount = particle.phaseCount + 1;
        if particle.phaseCount == 28 then
          particle.gridMoveCount = 0;
          particle.phaseCount = 0;
          particle.phase = particleResources.PHASE_MOVING;
        end

      end

    -- ------------------------------------------------------------------------
    -- ------------------------------- Forming --------------------------------
    -- ------------------------------------------------------------------------
    elseif particle.phase == particleResources.PHASE_FORMING then

      -- When forming we just need to wait before moving on to the next phase.
      particle.phaseCount = particle.phaseCount + 1;
      if particle.phaseCount == particleEmergeDelay then
        -- Done forming, emerge.
        particle.xScale = 1.0;
        particle.yScale = 1.0;
        particle.gridMoveCount = 0;
        particle.phaseCount = 0;
        particle.phase = particleResources.PHASE_EMERGING;
      else
        -- Still forming, bounce the scale.
        if particle.scaleChangeDir == 1 then
          particle.xScaleValue = particle.xScaleValue + 0.3;
          particle.yScaleValue = particle.yScaleValue + 0.3;
          if particle.scaleCount == 10 then
            particle.scaleChangeDir = 2;
            particle.scaleCount = 0;
          end
        else
          particle.xScaleValue = particle.xScaleValue - 0.3;
          particle.yScaleValue = particle.yScaleValue - 0.3;
          if particle.scaleCount == 10 then
            particle.scaleChangeDir = 1;
            particle.scaleCount = 0;
          end
        end
        particle.scaleCount = particle.scaleCount + 1;
        particle.xScale = particle.xScaleValue;
        particle.yScale = particle.yScaleValue;
      end

    -- ------------------------------------------------------------------------
    -- ----------------------------- In a diverter ----------------------------
    -- ------------------------------------------------------------------------
    elseif particle.phase == particleResources.PHASE_DIVERTER then

      -- Get a reference to the diverter we're on.
      local diverter = diverters[
        "diverter_" .. (particle.gridX - 1) .. "_" .. (particle.gridY - 1)
      ];

      -- First we have to delay a little while before deciding which way to
      -- go so the player has at least SOME chance.
      particle.phaseCount = particle.phaseCount + 1;
      if particle.phaseCount >= 30 then

        -- Cross.
        if diverter.diverterState == "cross" then
          -- The particle simply keeps moving.
          particle.gridMoveCount = 0;
          particle.phaseCount = 0;
          particle.phase = particleResources.PHASE_MOVING;

        -- Vertical.
        elseif diverter.diverterState == "vertical" then
          if particle.direction == particleResources.MOVING_UP or
            particle.direction == particleResources.MOVING_DOWN then
            -- No need to change direction, just change phase back to moving.
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          else
            --utils:log("updateParticles", "Invalid diverter state 1");
            showDiverterExplosion(particle.x, particle.y);
            -- Mark particle for destruction.
            particle.destroyMe = true;
          end

        -- Horizontal.
        elseif diverter.diverterState == "horizontal" then
          if particle.direction == particleResources.MOVING_LEFT or
            particle.direction == particleResources.MOVING_RIGHT then
            -- No need to change direction, just change phase back to moving.
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          else
            --utils:log("updateParticles", "Invalid diverter state 2");
            showDiverterExplosion(particle.x, particle.y);
            -- Mark particle for destruction.
            particle.destroyMe = true;
          end

        -- Down left.
        elseif diverter.diverterState == "downLeft" then
          if particle.direction == particleResources.MOVING_RIGHT then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_DOWN;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          elseif particle.direction == particleResources.MOVING_UP then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_LEFT;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          else
            --utils:log("updateParticles", "Invalid diverter state 3");
            showDiverterExplosion(particle.x, particle.y);
            -- Mark particle for destruction.
            particle.destroyMe = true;
          end

        -- Down right.
        elseif diverter.diverterState == "downRight" then
          if particle.direction == particleResources.MOVING_LEFT then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_DOWN;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          elseif particle.direction == particleResources.MOVING_UP then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_RIGHT;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          else
            --utils:log("updateParticles", "Invalid diverter state 4");
            showDiverterExplosion(particle.x, particle.y);
            -- Mark particle for destruction.
            particle.destroyMe = true;
          end

        -- Up left.
        elseif diverter.diverterState == "upLeft" then
          if particle.direction == particleResources.MOVING_RIGHT then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_UP;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          elseif particle.direction == particleResources.MOVING_DOWN then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_LEFT;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          else
            --utils:log("updateParticles", "Invalid diverter state 5");
            showDiverterExplosion(particle.x, particle.y);
            -- Mark particle for destruction.
            particle.destroyMe = true;
          end

        -- Up right.
        elseif diverter.diverterState == "upRight" then
          if particle.direction == particleResources.MOVING_LEFT then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_UP;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          elseif particle.direction == particleResources.MOVING_DOWN then
            -- Change direction and change phase back to moving.
            particle.direction = particleResources.MOVING_RIGHT;
            particle.gridMoveCount = 0;
            particle.phaseCount = 0;
            particle.phase = particleResources.PHASE_MOVING;
          else
            --utils:log("updateParticles", "Invalid diverter state 6");
            showDiverterExplosion(particle.x, particle.y);
            -- Mark particle for destruction.
            particle.destroyMe = true;
          end

        end -- End diverter state branching.

      end -- End phaseCount check.

    end -- End phase branching.

  end -- End iteration over particles.

  -- One last task: for any anti-particles, see if they're now located at
  -- the same location as a corresponding regular particle.  If they both
  -- aren't being destroyed then explosion.
  for i = 1, #particles, 1 do
    local particle1 = particles[i];
    if particle1.isAntiparticle == true and particle1.destroyMe == false then
      for j = 1, #particles, 1 do
        local particle2 = particles[j];
        if
          i ~= j and
          particle2.isAntiparticle == false and
          particle2.destroyMe == false and
          mathABS(particle1.x - particle2.x) <= 2 and
          mathABS(particle1.y - particle2.y) <= 2 and
          particle1.particleType == particle2.particleType then
          --utils:log("updateParticles", "Particle-Antiparticle collision");
          particle1.destroyMe = true;
          particle2.destroyMe = true;
          showAntimatterExplosion(particle1.x, particle1.y);
        end
      end
    end
  end

end -- End updateParticles().


-- ------------------------------------------------------------------------
-- Creates a new particle.
-- ------------------------------------------------------------------------
function createParticle()

  utils:log("createParticle", "createParticle()");

  if powerupOfflineActive == true then
    return;
  end

  local mathRandom = math.random;

  -- Figure out what type of particle it is, taking into account what type
  -- of ports there are on this level.
  local numPorts = 0;
  local portTypes = { };
  -- Figure out how many ports there are and get an array of their types.
  for i, v in pairs(currentLevel.ports) do
    numPorts = numPorts + 1;
    portTypes[numPorts] = v.type;
  end
  --utils:log("createParticle", "createParticle(): numPorts = " .. numPorts);
  local randHigh = numPorts;
  -- If a powerup is eligible to emerge, add one to the random generator
  -- high value to account for it.
  if currentLevel.powerupFrequencyCount >=
    currentLevel.levelDef.powerupFrequency and
    currentLevel.levelDef.powerupFrequency ~= 0 then
    --utils:log("createParticle", "createParticle(): Powerup is eligible");
    randHigh = numPorts + 1;
  end
  --utils:log("createParticle", "createParticle(): randHigh = " .. randHigh);
  local particleType = mathRandom(1, randHigh);
  --utils:log("createParticle", "createParticle(): particleType = " .. particleType);
  -- If the number chosen is higher than the number of ports then this particle
  -- is a powerup, and we need to see if one should emerge or not.
  if particleType > numPorts then
    --utils:log("createParticle", "createParticle(): Powerup selected");
    currentLevel.powerupFrequencyCount = 0;
    if mathRandom(1, 100) >=
      currentLevel.levelDef.powerupProbability then
      --utils:log("createParticle", "createParticle(): Particle is powerup");
      -- Yep, we beat probability, it's a powerup.
      particleType = "powerup"
    else
      -- Nope, not a powerup, so default to the first port type, since we
      -- know there's always at least one port so this is a safe shortcut.
      particleType = portTypes[1];
    end
  else
    particleType = portTypes[particleType];
  end

  -- Pick a generator to emerge from.
  local generatorIndex = mathRandom(1, #currentLevel.generators);
  --utils:log("createParticle", "createParticle(): generatorIndex = " .. generatorIndex);

  -- Figure out the grid coordinates (i.e., middle of the generator).
  local gridX = currentLevel.generators[generatorIndex].gridX + 3;
  local gridY = currentLevel.generators[generatorIndex].gridY + 3;
  --utils:log("createParticle", "createParticle(): gridX = " .. gridX);
  --utils:log("createParticle", "createParticle(): gridY = " .. gridY);

  -- Now decide what direction the particle moves in.  To do this we pick a
  -- direction and then check to see if there is a path out of the generator in
  -- that direction, and we keep trying until we get a valid value.
  local pickAgain = true;
  local direction;
  while pickAgain == true do
     direction = mathRandom(1, 4);
     --utils:log("createParticle", "createParticle(): direction = " .. direction);
     -- Now check the tile in that direction.  Not that as a level design
     -- criteria, a path can only come out of a generator centered on  a
     -- given side.
     if direction == particleResources.MOVING_UP and
       currentLevel.levelData[gridY - 4][gridX] == "V" then
       pickAgain = false;
     elseif direction == particleResources.MOVING_DOWN and
       currentLevel.levelData[gridY + 4][gridX] == "V" then
       pickAgain = false;
     elseif direction == particleResources.MOVING_LEFT and
       currentLevel.levelData[gridY][gridX - 4] == "H" then
       pickAgain = false;
     elseif direction == particleResources.MOVING_RIGHT and
       currentLevel.levelData[gridY][gridX + 4] == "H" then
       pickAgain = false;
     end
     if pickAgain == true then
       --utils:log("createParticle", "createParticle(): Picking again");
     end
  end

  -- Determine if its an antiparticle
  local isAnti = false;
  local antiExtension = "";
  if particleType ~= "powerup" then
    if mathRandom(1, 100) >
      currentLevel.levelDef.antimatterProbability then
      --utils:log("createParticle", "createParticle(): It's an antiparticle");
      isAnti = true;
      antiExtension = "_anti";
    end
  end

  --utils:log("createParticle", particleType .. antiExtension .. " emerging");

  -- Create the particle, set properties and add to collection.
  local particle = sprite.newSprite(
    particleResources.sets[particleType .. antiExtension], true
  );
  particle.targetID = "particle_" .. os.time();
  particle.xScaleValue = 1;
  particle.yScaleValue = 1;
  particle.scaleChangeDir = 1;
  particle.scaleCount = 0;
  particle.particleType = particleType;
  particle.phase = particleResources.PHASE_FORMING;
  particle.phaseCount = 0;
  particle.isAntiparticle = isAnti;
  particle.gridMoveCount = 0;
  particle.destroyMe = false;
  particle.direction = direction;
  particle.gridX = gridX;
  particle.gridY = gridY;
  particle.particleType = particleType;
  particle.x = ((gridX * 14) + xAdj) - 7; -- 7 = half of a tile
  particle.y = ((gridY * 14) + yAdj) - 7; -- 7 = half of a tile
  particle:prepare("default");
  particle:play();
  particle:toFront();
  table.insert(currentLevel.particles, particle);
  currentLevel.dg:insert(particle);

  -- Make sure powerup menu is in front if it's showing.
  if powerupsMenuShowing then
    utils:xpcall(
      "particleFunctions.lua:Calling powerupsMenuToFront()", powerupsMenuToFront
    );
  end

  sfx.particleEmergingChannel = audio.play(sfx.particleEmerging);

end -- End createParticle().
