--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:0a5c5248cfe6b4bb4c82450195cbd8cf$
--
-- local sheetInfo = require("myExportedImageSheet") -- lua file that Texture packer published
--
-- local myImageSheet = graphics.newImageSheet( "ImageSheet.png", sheetInfo:getSheet() ) -- ImageSheet.png is the image Texture packer published
--
-- local myImage1 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name1"))
-- local myImage2 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name2"))
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- tile_01
            x=1750,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_02
            x=1500,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_03
            x=1750,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_04
            x=1500,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_05
            x=1250,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_06
            x=1250,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_07
            x=1000,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_08
            x=1000,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_09
            x=750,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_10
            x=750,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_11
            x=500,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_12
            x=500,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_13
            x=250,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_14
            x=250,
            y=0,
            width=250,
            height=400,

        },
        {
            -- tile_15
            x=0,
            y=400,
            width=250,
            height=400,

        },
        {
            -- tile_empty
            x=0,
            y=0,
            width=250,
            height=400,

        },
    },
    
    sheetContentWidth = 2000,
    sheetContentHeight = 800
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
    ["tile_empty"] = 16,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
