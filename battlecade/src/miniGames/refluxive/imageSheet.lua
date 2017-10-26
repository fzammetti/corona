--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:d833aa572faaf89b7a2c32008b6199c0:175ddf34b7043fb629e19a554f892254:51eadd9eb612090d216e3ba3d4272adf$
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
            -- bouncy
            x=0,
            y=90,
            width=162,
            height=162,

        },
        {
            -- paddle
            x=0,
            y=0,
            width=216,
            height=90,

        },
    },
    
    sheetContentWidth = 216,
    sheetContentHeight = 252
}

SheetInfo.frameIndex =
{

    ["bouncy"] = 1,
    ["paddle"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
