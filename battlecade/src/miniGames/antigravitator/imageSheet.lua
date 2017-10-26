--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:af188b865f05f602b14f098c10f7088e:ca471156e3401a4d71fb625529a52681:51eadd9eb612090d216e3ba3d4272adf$
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
            -- enemy_00
            x=520,
            y=1296,
            width=40,
            height=79,

        },
        {
            -- enemy_01
            x=480,
            y=1296,
            width=40,
            height=80,

        },
        {
            -- gravpit_00
            x=80,
            y=1296,
            width=200,
            height=84,

        },
        {
            -- gravpit_01
            x=280,
            y=1296,
            width=200,
            height=84,

        },
        {
            -- gun
            x=0,
            y=1296,
            width=80,
            height=120,

        },
        {
            -- ship_00
            x=0,
            y=0,
            width=1080,
            height=216,

        },
        {
            -- ship_01
            x=0,
            y=216,
            width=1080,
            height=216,

        },
        {
            -- ship_02
            x=0,
            y=432,
            width=1080,
            height=216,

        },
        {
            -- ship_03
            x=0,
            y=648,
            width=1080,
            height=216,

        },
        {
            -- ship_04
            x=0,
            y=864,
            width=1080,
            height=216,

        },
        {
            -- ship_05
            x=0,
            y=1080,
            width=1080,
            height=216,

        },
    },
    
    sheetContentWidth = 1080,
    sheetContentHeight = 1416
}

SheetInfo.frameIndex =
{

    ["enemy_00"] = 1,
    ["enemy_01"] = 2,
    ["gravpit_00"] = 3,
    ["gravpit_01"] = 4,
    ["gun"] = 5,
    ["ship_00"] = 6,
    ["ship_01"] = 7,
    ["ship_02"] = 8,
    ["ship_03"] = 9,
    ["ship_04"] = 10,
    ["ship_05"] = 11,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
