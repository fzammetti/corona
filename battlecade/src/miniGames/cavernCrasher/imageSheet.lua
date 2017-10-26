--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:ee5bed59fbcfc924e16288b49224c70d:1a7bf05da5649be0cfe6db17ec9cb8e1:51eadd9eb612090d216e3ba3d4272adf$
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
            -- boulder
            x=0,
            y=959,
            width=108,
            height=100,

        },
        {
            -- ship_00
            x=0,
            y=699,
            width=173,
            height=130,

        },
        {
            -- ship_01
            x=0,
            y=829,
            width=173,
            height=130,

        },
        {
            -- stalagmite
            x=0,
            y=0,
            width=219,
            height=699,

        },
    },
    
    sheetContentWidth = 219,
    sheetContentHeight = 1059
}

SheetInfo.frameIndex =
{

    ["boulder"] = 1,
    ["ship_00"] = 2,
    ["ship_01"] = 3,
    ["stalagmite"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
