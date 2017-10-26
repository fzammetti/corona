--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ab90ee36fe622f85f3e4ad5858e90197:3a275a55127451103e12155eddc56e21:51eadd9eb612090d216e3ba3d4272adf$
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
            -- body
            x=0,
            y=0,
            width=54,
            height=54,

        },
        {
            -- food
            x=54,
            y=0,
            width=54,
            height=54,

        },
        {
            -- head
            x=108,
            y=0,
            width=54,
            height=54,

        },
    },
    
    sheetContentWidth = 162,
    sheetContentHeight = 54
}

SheetInfo.frameIndex =
{

    ["body"] = 1,
    ["food"] = 2,
    ["head"] = 3,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
