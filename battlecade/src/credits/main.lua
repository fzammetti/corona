--utils:log("credits", "Loaded");


local scene = composer.newScene();

scene.resMan = nil;

scene.creditText = {
  "Battlecade||Version 1.0||A game by Etherient",
  "Conception, design,|programming,|graphics, audio,|server development,|sacrificing of goats|to the gods of|project completion,|etcetera||Frank W. Zammetti",
  "In addition to|graphics resources|obtained from|Wikimedia Commons,|the following|graphics were also|used to make|this game:",
  "'Kenney Game|Assets Vol. 1&2'|Kenney Vleugels|www.kenney.nl||'Free Game GUI'|pzUH|opengameart.org/|content/free-game-gui",
  "'Vector art anime|facial expressions'|Julius|opengameart.org/|users/julius",
  "'Colorful Poker|Card Back'|jeffshee||'Monsters 2D'|Pack No 2.|Alucard||opengameart.org",
  "'Meteor Glitch'|Tiny Speck||'GUI Buttons|Vol.1'|looneybits and pzUH||opengameart.org",
  "'cartoon ui'|buttons type 2|Game Developer|Studio||opengameart.org",
  "'K&G Arcade|Resources'|Anthony Volpe|Crackhead Creations|planetvolpe.com|planetvolpe.com/|crackhead",
  "The following audio resources obtained|from freesound.org were used to make|this game:",
  "'comic bite 1'|ggctuk||'cutie laugh'|Reitanna||'ouch'|girlhurl",
  "'sound_jump'|odeean||'Splat!'|Flasher21||'JM_NOIZ_Laser 01'|Julien Matthey",
  "'TaDa!'|jimhancock||'Carica05'|melarancida||'Clock Tick'|agadamba",
  "'Harp Strum'|adriann||'Explosion'|Nbs Dark||'Drip1'|Neotone",
  "'CLAP'|erkanozan||'carrotnom'|1987||'buzzer'|guitarguy1985",
  "'Cartoon_boing'|vrodge||'soft grunt'|Reitanna||'Footstep 01'|VKProduktion",
  "'Pop sound'|deraj||'Ship atmosphere'|jobro||'Electricity00'|jeremysykes",
  "'A Note'|guitarmaster||'C Note'|guitarmaster||'D Note'|guitarmaster",
  "'E Note'|guitarmaster||'F Note'|guitarmaster||'G Note'|guitarmaster",
  "'Collision Reverb'|qubodup||'toycarhorn'|AMPUL||'short buzzer'|kwahmah_02",
  "(C)2016 Etherient|and|Frank W. Zammetti||All Rights Reserved||Thank you and enjoy!",
};
scene.creditTextIndex = nil;


--- ====================================================================================================================
--  ====================================================================================================================
--  Scene lifecycle Event Handlers
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  --utils:log("credits", "create()");

  local group = self.view;

  self.resMan = utils:newResourceManager();

  -- Back button.
  local btnBack = self.resMan:newSprite("btnBack", self.view, uiImageSheet, {
    { name = "default", start = uiSheetInfo:getFrameIndex("btnBack"), count = 1, time = 9999 }
  });
  btnBack.x = display.contentCenterX;
  btnBack.y = display.contentHeight - 100;

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  if inEvent.phase == "did" then

    --utils:log("credits", "show(): did");

    if textTitle.isVisible == false then
      textTitle.isVisible = true;
      textTitle:startAnimation();
    end

    -- Event listener for back button.
    self.resMan:getSprite("btnBack"):addEventListener("touch",
      function(inEvent)
        self:btnBackTouchHandler(inEvent);
        return true;
      end
    );

    self.creditTextIndex = 1;

    -- First text item.
    local currentText = self.resMan:newTextCandy("currentText", {
      fontName = "fontCredits", text = self.creditText[self.creditTextIndex],
      x = display.contentWidth / 2, y = display.contentHeight / 2,
      originX = "CENTER", originY = "CENTER", textFlow = "CENTER",
      wrapWidth = 1060, showOrigin = false
    });
    self.view:insert(currentText);

    -- Animate it in and begin the process of flipping to more text.
    scene:animateText();

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  if inEvent.phase == "did" then

    --utils:log("credits", "hide(): did");

  end

end -- End hide().


---
-- Handler for the destroy event.
--
-- @param inEvent The event object.
--
function scene:destroy(inEvent)

  --utils:log("credits", "destroy()");

  self.resMan:destroyAll();

end -- End destroy().


--- ====================================================================================================================
--  ====================================================================================================================
--  EnterFrame
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the enterFrame event.
--
-- @param inEvent The event object.
--
function scene:enterFrame(inEvent)
end -- End enterFrame().


--- ====================================================================================================================
--  ====================================================================================================================
--  Touch Handlers
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for touch events on the Back item.
--
-- @param inEvent The event object.
--
function scene:btnBackTouchHandler(inEvent)

  if inEvent.phase == "began" then
    inEvent.target.fill.effect = "filter.monotone";
    inEvent.target.fill.effect.r = 1;
    display.getCurrentStage():setFocus(inEvent.target);
  elseif inEvent.phase == "ended" or inEvent.phase == "cancelled" then
    inEvent.target.fill.effect = nil;
    display.getCurrentStage():setFocus(nil);
    audio.play(uiTap);
    self.resMan:getTextCandy("currentText"):removeInOutTransition();
    composer.gotoScene("menu.main", SCENE_TRANSITION_EFFECT, SCENE_TRANSITION_TIME);
  end

end -- End btnBackHandler().


--- ==================================================================================================================
--  ==================================================================================================================
--  Utility Functions
--  ==================================================================================================================
--  ==================================================================================================================


function scene:animateText()

  --utils:log("credits", "animateText()");

  self.resMan:getTextCandy("currentText"):applyInOutTransition({
    hideCharsBefore = true, hideCharsAfter = true, startNow = true,
    loop = false, autoRemoveText = false, restartOnChange = true,
    restoreOnComplete = false,
    inDelay = 0, inCharDelay = 40, inMode = "LEFT_RIGHT",
    AnimateFrom = {
      xScale = -4.0, yScale = 4.0, x = -display.contentWidth, time = 1000,
      transition = easing.outQuad
    },
    outDelay = 3000, outCharDelay = 40, outMode = "LEFT_RIGHT",
    AnimateTo = {
      xScale = -4.0, yScale = 4.0, x = display.contentWidth, time = 1000,
      transition = easing.inQuad
    },
    CompleteListener = function()
      self.creditTextIndex = self.creditTextIndex + 1;
      if self.creditTextIndex > #self.creditText then
        self.creditTextIndex = 1;
      end
      self.resMan:getTextCandy("currentText"):setText(self.creditText[self.creditTextIndex]);
    end
  });

end -- End animateText().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


--utils:log("credits", "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
