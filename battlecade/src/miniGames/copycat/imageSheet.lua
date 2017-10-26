--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2442f4e29bad1707a0e944cdb69ed30e:22720e9c13e90b04d5a05cca4f0132c7:51eadd9eb612090d216e3ba3d4272adf$
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
            -- icon1_0
            x=0,
            y=0,
            width=500,
            height=500,

        },
        {
            -- icon1_1
            x=500,
            y=0,
            width=500,
            height=500,

        },
        {
            -- icon2_0
            x=1000,
            y=0,
            width=500,
            height=500,

        },
        {
            -- icon2_1
            x=0,
            y=500,
            width=500,
            height=500,

        },
        {
            -- icon3_0
            x=0,
            y=1000,
            width=500,
            height=500,

        },
        {
            -- icon3_1
            x=0,
            y=1500,
            width=500,
            height=500,

        },
        {
            -- icon4_0
            x=500,
            y=500,
            width=500,
            height=500,

        },
        {
            -- icon4_1
            x=1000,
            y=500,
            width=500,
            height=500,

        },
        {
            -- icon5_0
            x=500,
            y=1000,
            width=500,
            height=500,

        },
        {
            -- icon5_1
            x=500,
            y=1500,
            width=500,
            height=500,

        },
        {
            -- icon6_0
            x=1000,
            y=1000,
            width=500,
            height=500,

        },
        {
            -- icon6_1
            x=1000,
            y=1500,
            width=500,
            height=500,

        },
    },
    
    sheetContentWidth = 1500,
    sheetContentHeight = 2000
}

SheetInfo.frameIndex =
{

    ["icon1_0"] = 1,
    ["icon1_1"] = 2,
    ["icon2_0"] = 3,
    ["icon2_1"] = 4,
    ["icon3_0"] = 5,
    ["icon3_1"] = 6,
    ["icon4_0"] = 7,
    ["icon4_1"] = 8,
    ["icon5_0"] = 9,
    ["icon5_1"] = 10,
    ["icon6_0"] = 11,
    ["icon6_1"] = 12,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
