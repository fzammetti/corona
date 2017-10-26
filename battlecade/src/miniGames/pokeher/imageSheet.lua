--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:5a7f1453af56b1cae6d21ab950eb7de0:b13e9509a3411e4bdb818576aaaffbd0:51eadd9eb612090d216e3ba3d4272adf$
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
            -- hit
            x=0,
            y=0,
            width=530,
            height=552,

        },
        {
            -- left
            x=0,
            y=552,
            width=530,
            height=552,

        },
        {
            -- miss
            x=530,
            y=0,
            width=530,
            height=552,

        },
        {
            -- neutral
            x=530,
            y=552,
            width=530,
            height=552,

        },
        {
            -- right
            x=1060,
            y=0,
            width=530,
            height=552,

        },
    },
    
    sheetContentWidth = 1590,
    sheetContentHeight = 1104
}

SheetInfo.frameIndex =
{

    ["hit"] = 1,
    ["left"] = 2,
    ["miss"] = 3,
    ["neutral"] = 4,
    ["right"] = 5,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
