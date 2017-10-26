--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c2f709666e7e08b0f0c2d64a6149f3a5:46ce037bacb2190f51e163a6195e7b29:51eadd9eb612090d216e3ba3d4272adf$
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
            -- ball
            x=279,
            y=0,
            width=150,
            height=150,

        },
        {
            -- cup
            x=0,
            y=0,
            width=279,
            height=400,

        },
    },
    
    sheetContentWidth = 429,
    sheetContentHeight = 400
}

SheetInfo.frameIndex =
{

    ["ball"] = 1,
    ["cup"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
