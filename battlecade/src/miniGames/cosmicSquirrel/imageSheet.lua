--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4fe5838c073470b2595e822e8db7e19d:99f0a04c2d936c48768d34c9e7f7b075:51eadd9eb612090d216e3ba3d4272adf$
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
            -- acorn
            x=1041,
            y=130,
            width=97,
            height=97,

        },
        {
            -- alien_00
            x=1311,
            y=76,
            width=130,
            height=130,

        },
        {
            -- alien_01
            x=1441,
            y=76,
            width=130,
            height=130,

        },
        {
            -- alien_02
            x=1571,
            y=76,
            width=130,
            height=130,

        },
        {
            -- comet_00
            x=0,
            y=0,
            width=347,
            height=76,

        },
        {
            -- comet_01
            x=0,
            y=76,
            width=347,
            height=76,

        },
        {
            -- comet_02
            x=0,
            y=152,
            width=347,
            height=76,

        },
        {
            -- comet_03
            x=347,
            y=0,
            width=347,
            height=76,

        },
        {
            -- comet_04
            x=347,
            y=76,
            width=347,
            height=76,

        },
        {
            -- comet_05
            x=347,
            y=152,
            width=347,
            height=76,

        },
        {
            -- comet_06
            x=694,
            y=0,
            width=347,
            height=76,

        },
        {
            -- comet_07
            x=694,
            y=76,
            width=347,
            height=76,

        },
        {
            -- comet_08
            x=694,
            y=152,
            width=347,
            height=76,

        },
        {
            -- comet_09
            x=1041,
            y=0,
            width=347,
            height=76,

        },
        {
            -- comet_10
            x=1388,
            y=0,
            width=347,
            height=76,

        },
        {
            -- ship_00
            x=1735,
            y=0,
            width=173,
            height=130,

        },
        {
            -- ship_01
            x=1138,
            y=76,
            width=173,
            height=130,

        },
        {
            -- squirrel_00
            x=1701,
            y=130,
            width=97,
            height=97,

        },
        {
            -- squirrel_01
            x=1798,
            y=130,
            width=97,
            height=97,

        },
    },
    
    sheetContentWidth = 1931,
    sheetContentHeight = 228
}

SheetInfo.frameIndex =
{

    ["acorn"] = 1,
    ["alien_00"] = 2,
    ["alien_01"] = 3,
    ["alien_02"] = 4,
    ["comet_00"] = 5,
    ["comet_01"] = 6,
    ["comet_02"] = 7,
    ["comet_03"] = 8,
    ["comet_04"] = 9,
    ["comet_05"] = 10,
    ["comet_06"] = 11,
    ["comet_07"] = 12,
    ["comet_08"] = 13,
    ["comet_09"] = 14,
    ["comet_10"] = 15,
    ["ship_00"] = 16,
    ["ship_01"] = 17,
    ["squirrel_00"] = 18,
    ["squirrel_01"] = 19,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
