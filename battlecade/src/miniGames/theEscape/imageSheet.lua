--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:70da944c56ae1e73772e4d7fef47582b:68b7a656c117157bb486eeaf11a5b195:51eadd9eb612090d216e3ba3d4272adf$
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
            -- destpad
            x=0,
            y=0,
            width=108,
            height=160,

        },
        {
            -- player_down
            x=0,
            y=160,
            width=108,
            height=160,

        },
        {
            -- player_left
            x=0,
            y=320,
            width=108,
            height=160,

        },
        {
            -- player_right
            x=0,
            y=480,
            width=108,
            height=160,

        },
        {
            -- player_still
            x=0,
            y=640,
            width=108,
            height=160,

        },
        {
            -- player_up
            x=0,
            y=800,
            width=108,
            height=160,

        },
        {
            -- rock
            x=0,
            y=960,
            width=108,
            height=160,

        },
        {
            -- skull
            x=0,
            y=1120,
            width=108,
            height=160,

        },
        {
            -- wall
            x=0,
            y=1280,
            width=108,
            height=160,

        },
    },
    
    sheetContentWidth = 108,
    sheetContentHeight = 1440
}

SheetInfo.frameIndex =
{

    ["destpad"] = 1,
    ["player_down"] = 2,
    ["player_left"] = 3,
    ["player_right"] = 4,
    ["player_still"] = 5,
    ["player_up"] = 6,
    ["rock"] = 7,
    ["skull"] = 8,
    ["wall"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
