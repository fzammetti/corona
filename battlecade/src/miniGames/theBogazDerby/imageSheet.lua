--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:865a40d88463230d1c35631a5ef16ec8:36260a86a7999fe05602ff4efdf8e828:51eadd9eb612090d216e3ba3d4272adf$
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
            -- enemy
            x=0,
            y=0,
            width=270,
            height=405,

        },
        {
            -- player
            x=270,
            y=0,
            width=270,
            height=405,

        },
    },
    
    sheetContentWidth = 540,
    sheetContentHeight = 405
}

SheetInfo.frameIndex =
{

    ["enemy"] = 1,
    ["player"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
