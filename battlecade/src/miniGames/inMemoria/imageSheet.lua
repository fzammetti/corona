--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:6492cd9d439792bd9df1d7746272c999:5604a1f62eb1c3936235aea31efff0b9:51eadd9eb612090d216e3ba3d4272adf$
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
            -- tile_01
            x=0,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_02
            x=0,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_03
            x=136,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_04
            x=136,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_05
            x=272,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_06
            x=272,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_07
            x=408,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_08
            x=408,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_09
            x=544,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_10
            x=544,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_11
            x=680,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_12
            x=680,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_13
            x=816,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_14
            x=816,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_15
            x=952,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_16
            x=952,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_17
            x=1088,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_18
            x=1088,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_19
            x=1224,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_20
            x=1224,
            y=204,
            width=136,
            height=204,

        },
        {
            -- tile_21
            x=1360,
            y=0,
            width=136,
            height=204,

        },
        {
            -- tile_unflipped
            x=1360,
            y=204,
            width=136,
            height=204,

        },
    },
    
    sheetContentWidth = 1496,
    sheetContentHeight = 408
}

SheetInfo.frameIndex =
{

    ["tile_01"] = 1,
    ["tile_02"] = 2,
    ["tile_03"] = 3,
    ["tile_04"] = 4,
    ["tile_05"] = 5,
    ["tile_06"] = 6,
    ["tile_07"] = 7,
    ["tile_08"] = 8,
    ["tile_09"] = 9,
    ["tile_10"] = 10,
    ["tile_11"] = 11,
    ["tile_12"] = 12,
    ["tile_13"] = 13,
    ["tile_14"] = 14,
    ["tile_15"] = 15,
    ["tile_16"] = 16,
    ["tile_17"] = 17,
    ["tile_18"] = 18,
    ["tile_19"] = 19,
    ["tile_20"] = 20,
    ["tile_21"] = 21,
    ["tile_unflipped"] = 22,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
