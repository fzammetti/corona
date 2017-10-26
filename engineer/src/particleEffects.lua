-- This file contains any code that makes use of Particle Candy.


-- Start the particle engine updates and turn debug messages off.
particleCandy.StartAutoUpdate();
particleCandy.EnableDebug(false);


-- Every particle effect created, explosions, sparks, etc., gets a unique ID
-- assigned to it.  In order to do this we attach this value to the static
-- portion.  This is done instead of getting current time, since that's a
-- system call and might impact performance, while this should be 100%
-- safe.
local particleID = 1;

-- Define particle types.
particleCandy.CreateParticleType ("ExplosionSmoke", {
  imagePath = "particleCandy_smoke1LightDark.png",
  imageWidth = 64, imageHeight = 64, directionVariation = 360,
  velocityVariation = 50, rotationVariation = 360, rotationChange = 30,
  useEmitterRotation = false, alphaStart = 0.0, fadeInSpeed = 1.5,
  fadeOutSpeed = -0.5, fadeOutDelay = 500, scaleStart = 0.5,
  scaleVariation = 0.5, scaleInSpeed = 1.0, scaleOutSpeed = 0.01,
  scaleOutDelay = 500, emissionShape = 2, emissionRadius = 30,
  killOutsideScreen = false, lifeTime = 3000
});
particleCandy.CreateParticleType ("FireballSlow", {
  imagePath = "particleCandy_fireballMedium.png",
  imageWidth = 64, imageHeight = 64, directionVariation  = 360,
  velocityStart = 50, velocityVariation = 25, velocityChange = -2.0,
  rotationVariation = 360, rotationChange = 20, useEmitterRotation  = false,
  alphaStart = 0.0, alphaVariation = 0.25, fadeInSpeed = 2.0,
  fadeOutSpeed = -0.75, fadeOutDelay = 500, scaleStart = 0.1,
  scaleVariation = 0.20, scaleInSpeed = 2.0, scaleOutSpeed = -0.01,
  scaleOutDelay = 1000, emissionShape = 2, emissionRadius = 5,
  killOutsideScreen = false, blendMode = "add", lifeTime = 2000,
  colorChange = {-25, -50, -75}
});
particleCandy.CreateParticleType("FireballBright", {
  imagePath = "particleCandy_fireballBright.png",
  imageWidth = 64, imageHeight = 64, directionVariation  = 360,
  velocityStart = 75, velocityVariation = 15, velocityChange = -2.0,
  rotationVariation = 360, rotationChange = -20, useEmitterRotation = false,
  alphaStart = 1.0, alphaVariation = 0.25, fadeInSpeed = 2.0,
  fadeOutSpeed = -3.0, fadeOutDelay = 300, scaleStart = 0.1,
  scaleVariation = 0.20, scaleInSpeed = 3.0, scaleOutSpeed = -0.01,
  scaleOutDelay = 500, emissionShape = 2, emissionRadius = 30,
  killOutsideScreen = false, blendMode = "add", lifeTime = 2000,
  colorChange = {-25 ,-50, -75}
});
particleCandy.CreateParticleType("ExplosionSparks", {
  imagePath = "particleCandy_sparkWithTrail.png",
  imageWidth = 8, imageHeight = 32, directionVariation = 360,
  velocityStart = 200, velocityVariation = 150, velocityChange = -2.0,
  rotationVariation = 360, autoOrientation = true, useEmitterRotation = false,
  alphaStart = 0.5, alphaVariation = 0.5, fadeInSpeed = 0,
  fadeOutSpeed = -1.0, fadeOutDelay = 0, scaleStart = 1.5,
  scaleVariation = 0.5, scaleInSpeed = 1.0, scaleOutSpeed = -0.5,
  scaleOutDelay = 0, killOutsideScreen = false, blendMode = "add",
  lifeTime = 2000
});
particleCandy.CreateParticleType("ExplosionFlash", {
  imagePath = "particleCandy_flare.png",
  imageWidth = 128, imageHeight = 128, directionVariation  = 360,
  rotationVariation = 360, rotationChange = 0, useEmitterRotation  = false,
  alphaStart = 1.0, fadeInSpeed = 1.0, fadeOutSpeed = -1.0,
  fadeOutDelay = 0, scaleStart = 2.0, scaleInSpeed = 1.0,
  scaleOutSpeed = -1.0, scaleOutDelay = 0, killOutsideScreen = false,
  blendMode = "add", lifeTime = 1000
});
particleCandy.CreateParticleType("LightSmoke", {
  imagePath = "particleCandy_smokeWhisperyBright.png",
  imageWidth = 64, imageHeight = 64, weight = -0.2,
  directionVariation = 360, velocityVariation = 50, rotationVariation = 360,
  rotationChange = 30, useEmitterRotation = false, alphaStart = 0.0,
  fadeInSpeed = 1.5, fadeOutSpeed = -0.5, fadeOutDelay = 500,
  scaleStart = 0.5, scaleVariation = 0.5, scaleInSpeed = 1.0,
  scaleOutSpeed = 0.01, scaleOutDelay = 500, emissionShape = 2,
  emissionRadius = 30, killOutsideScreen = true, lifeTime = 3000
});
particleCandy.CreateParticleType("ElectricSparks", {
  imagePath = "particleCandy_electricSpark.png",
  imageWidth = 8, imageHeight = 32, weight = 0.8,
  xReference = 4, yReference = 32, velocityStart = 150,
  velocityVariation = 100, directionVariation = 360, autoOrientation = true,
  useEmitterRotation = false, alphaStart = 1.0, fadeOutSpeed = -1.0,
  fadeOutDelay = 250, scaleStart = 0.2, scaleVariation = 0.3,
  scaleChange = -1.0, emissionShape = 0, killOutsideScreen = true,
  blendMode = "add", lifeTime = 1500
});


-- ============================================================================
-- Shows an explosion at a given location when a particle enters an
-- incorrect diverter.
--
-- @param inX X location of the center of the explosion.
-- @param inY Y location of the center of the explosion.
-- ============================================================================
function showDiverterExplosion(inX, inY)

  utils:log("gameCore", "showDiverterExplosion()");

  currentLevel.numDiverterExplosions = currentLevel.numDiverterExplosions + 1;

  local emitterID = "pEmitter_" .. particleID;
  particleID = particleID + 1;

  particleCandy.CreateEmitter(
    emitterID, inX, inY, 0, false, false, true
  );
  currentLevel.dg:insert(particleCandy.GetEmitter(emitterID))

  particleCandy.AttachParticleType(emitterID, "ExplosionFlash", 50, 100, 0);

  particleCandy.StartEmitter(emitterID);
  sfx.diverterExplosionChannel = audio.play(sfx.diverterExplosion);

end -- End showDiverterExplosion().


-- ============================================================================
-- Shows an explosion at a given location when a particle hits an antiparticle.
--
-- @param inX X location of the center of the explosion.
-- @param inY Y location of the center of the explosion.
-- ============================================================================
function showAntimatterExplosion(inX, inY)

  utils:log("gameCore", "showAntimatterExplosion()");

  currentLevel.numAntimatterExplosions = currentLevel.numAntimatterExplosions + 1;

  local emitterID = "pEmitter_" .. particleID;
  particleID = particleID + 1;

  particleCandy.CreateEmitter(
    emitterID, inX, inY, 0, false, false, true
  );

  particleCandy.AttachParticleType(emitterID, "FireballBright", 30, 400, 0);
  particleCandy.AttachParticleType(emitterID, "ExplosionSparks", 100, 100, 100);
  particleCandy.AttachParticleType(emitterID, "ExplosionFlash", 50, 100, 0);

  particleCandy.StartEmitter(emitterID);

  -- Reuse the explosion sound for ports.
  sfx.portExplosionChannel = audio.play(sfx.portExplosion);

end -- End showAntimatterExplosion().


-- ============================================================================
-- Shows an explosion at a given location for a port.  Slightly bigger and
-- takes longer than the one for showExplosion(), which is intended for
-- diverter explosions.
--
-- @param inX X location of the center of the explosion.
-- @param inY Y location of the center of the explosion.
-- ============================================================================
function showPortExplosion(inX, inY)

  utils:log("gameCore", "showPortExplosion()");

  currentLevel.numPortExplosions = currentLevel.numPortExplosions + 1;

  local emitterID = "pEmitter_" .. particleID;
  particleID = particleID + 1;

  particleCandy.CreateEmitter(
    emitterID, inX, inY, 0, false, false, true
  );

  particleCandy.AttachParticleType(emitterID, "FireballBright", 30, 400, 0);
  particleCandy.AttachParticleType(emitterID, "ExplosionSparks", 100, 100, 100);
  particleCandy.AttachParticleType(emitterID, "ExplosionFlash", 50, 100, 0);

  particleCandy.StartEmitter(emitterID);

end -- End showPortExplosion().


-- ============================================================================
-- Shows an explosion at a given location when a particle enters a generator.
-- This should be even bigger still than the port explosion.
--
-- @param inX X location of the center of the explosion.
-- @param inY Y location of the center of the explosion.
-- ============================================================================
function showGeneratorExplosion(inX, inY)

  utils:log("gameCore", "showGeneratorExplosion()");

  local emitterID = "pEmitter_" .. particleID;
  particleID = particleID + 1;

  particleCandy.CreateEmitter(
    emitterID, inX, inY, 0, false, false, true
  );

  particleCandy.AttachParticleType(emitterID, "ExplosionSmoke", 20, 500, 750);
  particleCandy.AttachParticleType(emitterID, "FireballSlow", 30, 400, 0);
  particleCandy.AttachParticleType(emitterID, "FireballBright", 30, 400, 0);
  particleCandy.AttachParticleType(emitterID, "ExplosionSparks", 100, 100, 100);
  particleCandy.AttachParticleType(emitterID, "ExplosionFlash", 50, 100, 0);

  particleCandy.StartEmitter(emitterID);
  sfx.bigExplosionChannel = audio.play(sfx.bigExplosion);

end -- End showGeneratorExplosion().


-- ============================================================================
-- Shows a shower of sparks at a given location.
--
-- @param inX X location of the center of the sparks.
-- @param inY Y location of the center of the sparks.
-- ============================================================================
function showDegaussSparks(inX, inY)

  utils:log("gameCore", "degaussSparks()");

  local emitterID = "pEmitter_" .. particleID;
  particleID = particleID + 1;

  particleCandy.CreateEmitter(
    emitterID, inX, inY, 0, false, false, true
  );

  particleCandy.AttachParticleType(emitterID, "LightSmoke", 10, 1500, 0);
  particleCandy.AttachParticleType(emitterID, "ElectricSparks", 40, 1500, 0);
  particleCandy.AttachParticleType(emitterID, "ExplosionFlash",  5, 1500, 0);

  particleCandy.StartEmitter(emitterID);

end -- End showDegaussSparks().
