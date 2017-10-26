-- ------------------------------------------------------------------------
-- Draws the current level's board.
-- ------------------------------------------------------------------------
function drawBoard(inLevelDef)

  utils:log("drawBoard", "drawBoard()");

  local mathRandom = math.random;

  local background =
    display.newImage("game_background_" .. inLevelDef.background .. ".png", true);
  background:setReferencePoint(display.TopLeftReferencePoint);
  background.x = 0;
  background.y = yAdj - 2;
  currentLevel.dg:insert(background);

  -- Draw tiles.
  for y = 1, 31, 1 do
    for x = 1, 57, 1 do
      -- Calculate pixel location for the tile.
      local pX = (14 * (x - 1)) + xAdj;
      local pY = (14 * (y - 1)) + yAdj;
      -- Get the code for the tile to draw.
      local tile = inLevelDef.data[y][x];
      -- GENERATOR.
      if tile == "_" or tile == "*" then
        -- Empty tile, do nothing.
      elseif tile == "E" then
        local generator = sprite.newSprite(generatorResources.set, true);
        generator:setReferencePoint(display.TopLeftReferencePoint);
        generator.gridX = x;
        generator.gridY= y;
        generator.x = pX;
        generator.y = pY;
        generator:prepare("default");
        generator:play();
        table.insert(currentLevel.generators, generator);
        currentLevel.dg:insert(generator);
      -- DIVERTER.
      elseif tile == "D" then
        local s = mathRandom(1, 6);
        if s == 1 then
          s = "downLeft"
        elseif s == 2 then
          s = "downRight"
        elseif s == 3 then
          s = "horizontal"
        elseif s == 4 then
          s = "upLeft"
        elseif s == 5 then
          s = "upRight"
        elseif s == 6 then
          s = "vertical"
        end
        createDiverter({ state = s, gridX = x, gridY = y });
      -- PORT.
      elseif tile == "R" or tile == "B" or tile == "G" or tile == "Y" then
        local portTypes = { R = "red", G = "green", B = "blue", Y = "yellow" };
        local port = sprite.newSprite(portResources.sets[portTypes[tile]], true);
        port:setReferencePoint(display.TopLeftReferencePoint);
        port.damage = 0;
        port.type = portTypes[tile];
        port.x = pX;
        port.y = pY;
        port:prepare("damaged0");
        port:play();
        currentLevel.ports["port_" .. x .. "_" .. y] = port;
        currentLevel.dg:insert(port);
      -- ANTIMATTER SINK.
      elseif tile == "I" then
        local antimatterSink =
          sprite.newSprite(antimatterSinkResources.set, true);
        antimatterSink:setReferencePoint(display.TopLeftReferencePoint);
        antimatterSink.x = pX;
        antimatterSink.y = pY;
        antimatterSink.gridX = x;
        antimatterSink.gridY = y;
        antimatterSink:prepare("default");
        antimatterSink:play();
        table.insert(currentLevel.antimatterSinks, antimatterSink);
        currentLevel.dg:insert(antimatterSink);
      -- PARTICLE PRISON.
      elseif tile == "N" then
        local particlePrison =
          sprite.newSprite(particlePrisonResources.set, true);
        particlePrison:setReferencePoint(display.TopLeftReferencePoint);
        particlePrison.x = pX;
        particlePrison.y = pY;
        particlePrison.gridX = x;
        particlePrison.gridY = y;
        particlePrison:prepare("default");
        particlePrison:play();
        table.insert(currentLevel.particlePrisons, particlePrison);
        currentLevel.dg:insert(particlePrison);
      -- TRACK.
      else
        local trackTypes = {
          V = "vertical", H = "horizontal",
          Q = "upper_left", W = "upper_right",
          A = "lower_left", S = "lower_right",
          O = "tjoint_up", P = "tjoint_down",
          K = "tjoint_left", L = "tjoint_right",
          C = "cross"
        };
        local track =
          display.newImage("game_track_" .. trackTypes[tile] .. ".png", true);
        track:setReferencePoint(display.TopLeftReferencePoint);
        track.x = pX;
        track.y = pY;
        currentLevel.dg:insert(track);
      end
    end
  end

end -- End drawBoard().


-- ------------------------------------------------------------------------
-- Create a new diverter.
--
-- @param inConfig Config object with the following attributes:
--                 state ...... The state of the diverter.
--                 gridX ...... X grid location of the diverter.
--                 gridY ...... Y grid location of the diverter.
-- ------------------------------------------------------------------------
function createDiverter(inConfig)

  --utils:log("drawBoard", "createDiverter()");

  -- Get pixel coordinates from the grid coordinates.
  local pX = (14 * (inConfig.gridX - 1)) + xAdj;
  local pY = (14 * (inConfig.gridY - 1)) + yAdj;

  local id = "diverter_" .. inConfig.gridX .. "_" .. inConfig.gridY;
  local diverter =
    sprite.newSprite(diverterResources.sets[inConfig.state], true);
  diverter:setReferencePoint(display.TopLeftReferencePoint);
  diverter.targetID = id;
  diverter.diverterState = inConfig.state;
  diverter.x = pX;
  diverter.y = pY;
  diverter:addEventListener("touch", gameTouch);
  currentLevel.diverters[id] = diverter;
  currentLevel.dg:insert(diverter);

  -- Finally, bring any active particles forward so the new diverter
  -- doesn't obscure them.
  for i = 1, #currentLevel.particles, 1 do
    currentLevel.particles[i]:toFront();
  end

end -- End createDiverter().
