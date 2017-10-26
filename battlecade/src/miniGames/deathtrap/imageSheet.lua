--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:f395ed2f258c9aa09215cf193bdce25d:51796fbb293cc0c5eb850aca3c0cb35f:51eadd9eb612090d216e3ba3d4272adf$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- background
            x=0,
            y=0,
            width=1080,
            height=1080,

        },
        {
            -- player_dieing_00
            x=1080,
            y=0,
            width=119,
            height=221,

        },
        {
            -- player_dieing_01
            x=1080,
            y=221,
            width=119,
            height=221,

        },
        {
            -- player_jumping
            x=1080,
            y=442,
            width=119,
            height=221,

        },
        {
            -- player_standing
            x=1080,
            y=663,
            width=119,
            height=221,

        },
    },
    
    sheetContentWidth = 1199,
    sheetContentHeight = 1080
}

SheetInfo.frameIndex =
{

    ["background"] = 1,
    ["player_dieing_00"] = 2,
    ["player_dieing_01"] = 3,
    ["player_jumping"] = 4,
    ["player_standing"] = 5,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
