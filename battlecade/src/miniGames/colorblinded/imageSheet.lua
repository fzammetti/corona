--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:6c3690cc56136f7cad0e8dd2489846fe:82f73e604c93221547496c338f55a81b:51eadd9eb612090d216e3ba3d4272adf$
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
            -- blue
            x=0,
            y=0,
            width=180,
            height=180,

        },
        {
            -- green
            x=180,
            y=0,
            width=180,
            height=180,

        },
        {
            -- happy
            x=360,
            y=0,
            width=180,
            height=180,

        },
        {
            -- purple
            x=540,
            y=0,
            width=180,
            height=180,

        },
        {
            -- red
            x=720,
            y=0,
            width=180,
            height=180,

        },
        {
            -- sad
            x=900,
            y=0,
            width=180,
            height=180,

        },
        {
            -- yellow
            x=1080,
            y=0,
            width=180,
            height=180,

        },
    },
    
    sheetContentWidth = 1260,
    sheetContentHeight = 180
}

SheetInfo.frameIndex =
{

    ["blue"] = 1,
    ["green"] = 2,
    ["happy"] = 3,
    ["purple"] = 4,
    ["red"] = 5,
    ["sad"] = 6,
    ["yellow"] = 7,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
